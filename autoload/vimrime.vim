"如果是初次使用插件，因为需要编译词库
"需要不少时间才能正式开始输入
"因此注册此回调函数，当服务器准备完毕时
"才启动vimrime，并在准备完毕时显示提示信息
function! StartUp(channel, msg)
	if g:vimrimeReady == 0
		let l:res = vimrime_minijson#ParseJSON(a:msg)
		if l:res["status"] == 'ready'
			echo 'vimrime ready.'
			let g:vimrimeReady = 1
		else
			echo 'vimrime failed.'
			let g:vimrimeReady = 0
		endif
	endif
endfunction

"初始化vimrime，建立与服务器的通信
function! vimrime#Init()
	let l:options = {}
	let l:options['out_io'] = 'pipe'
	let l:options['err_io'] = 'null'
	let l:options['pty'] = 1
	let l:options['out_mode'] = 'nl'
	let l:options['callback'] = function('StartUp')
	let l:options['cwd'] = g:vimrimeDictDir
	let g:vimrimeRes = {}
	let g:vimrimeReady = 0
	let g:vimrimeServerJob = job_start(g:vimrimeServerBin, options)
	let g:vimrimeServerChannel = job_getchannel(g:vimrimeServerJob)
	call s:MapKeys()
endfunction

"打印输入法菜单
function! vimrime#UpdateUI()
	let l:preeditSize = strlen(g:vimrimeRes['composition']['preedit'])
	if l:preeditSize == 0
		echo ''
		return
	endif
	let l:msg = ''
	for i in range(0, l:preeditSize)
		if i == g:vimrimeRes['composition']['start']
			let l:msg = l:msg . '['
		elseif i == g:vimrimeRes['composition']['end']
			let l:msg = l:msg . ']'
		elseif i == g:vimrimeRes['composition']['cursor']
			let l:msg = l:msg . '|'
		endif
		let l:msg = l:msg . g:vimrimeRes['composition']['preedit'][i]
	endfor
	let l:msg = l:msg . "  "
	let l:candidateSize = len(g:vimrimeRes['menu']['candidates'])
	if l:candidateSize
		for i in range(1, l:candidateSize - 1)
			let l:msg = l:msg . i . '. ' . g:vimrimeRes['menu']['candidates'][i - 1] . ', '
		endfor
		let l:msg = l:msg . l:candidateSize . '. ' . g:vimrimeRes['menu']['candidates'][l:candidateSize - 1]
	endif
	echo l:msg
endfunction

"常规的按键映射，当vimrime激活时
"这些按键将全部由输入法接管
function! vimrime#SimulateKeyInput(key)
	if g:vimrimeEnabled && g:vimrimeActive && g:vimrimeReady
		call ch_evalraw(g:vimrimeServerChannel, a:key . "\n")
		let g:vimrimeRes = vimrime_minijson#ParseJSON(ch_readraw(g:vimrimeServerChannel))
		call vimrime#UpdateUI()
		return g:vimrimeRes["commit"]
	else
		return a:key
	endif
endfunction

"特殊的按键映射，如果输入法不处于候选状态，就返回alt
"反之，这些按键将被发送给输入法
"主要用于<Space>、<CR>、<Left>、<Right>等按键
function! vimrime#SimulateSpecial(key, alt)
	if has_key(g:vimrimeRes, 'composition') == 0
		return a:alt
	endif
	if g:vimrimeEnabled && g:vimrimeActive && g:vimrimeReady && strlen(g:vimrimeRes['composition']['preedit'])
		call ch_evalraw(g:vimrimeServerChannel, a:key . "\n")
		let g:vimrimeRes = vimrime_minijson#ParseJSON(ch_readraw(g:vimrimeServerChannel))
		call vimrime#UpdateUI()
		return g:vimrimeRes["commit"]
	else
		return a:alt
	endif
endfunction

"切换vimrime的激活状态
"用于切换中英文
function! vimrime#Switch()
	let g:vimrimeActive = g:vimrimeActive ? 0 : 1
endfunction

"特殊的键绑定
"这些映射如果不加上<buffer>选项，实际使用过程中会失效
"因此在每次进入buffer时必须重新执行一次绑定（使用autocmd BufEnter * 实现）
"尽量不要在这个函数里放太多东西，尤其是耗时的步骤
function! s:SpecialBinding()
	inoremap <buffer><expr><silent> <Space> vimrime#SimulateSpecial(' ', ' ')
	inoremap <buffer><expr><silent> <BS> vimrime#SimulateSpecial('{BackSpace}', "\<BS>")
	inoremap <buffer><expr><silent> <CR> vimrime#SimulateSpecial('{Return}', "\<CR>")
endfunction

"执行映射
function s:MapKeys()
	inoremap <expr><silent> a vimrime#SimulateKeyInput('a')
	inoremap <expr><silent> b vimrime#SimulateKeyInput('b')
	inoremap <expr><silent> c vimrime#SimulateKeyInput('c')
	inoremap <expr><silent> d vimrime#SimulateKeyInput('d')
	inoremap <expr><silent> e vimrime#SimulateKeyInput('e')
	inoremap <expr><silent> f vimrime#SimulateKeyInput('f')
	inoremap <expr><silent> g vimrime#SimulateKeyInput('g')
	inoremap <expr><silent> h vimrime#SimulateKeyInput('h')
	inoremap <expr><silent> i vimrime#SimulateKeyInput('i')
	inoremap <expr><silent> j vimrime#SimulateKeyInput('j')
	inoremap <expr><silent> k vimrime#SimulateKeyInput('k')
	inoremap <expr><silent> l vimrime#SimulateKeyInput('l')
	inoremap <expr><silent> m vimrime#SimulateKeyInput('m')
	inoremap <expr><silent> n vimrime#SimulateKeyInput('n')
	inoremap <expr><silent> o vimrime#SimulateKeyInput('o')
	inoremap <expr><silent> p vimrime#SimulateKeyInput('p')
	inoremap <expr><silent> q vimrime#SimulateKeyInput('q')
	inoremap <expr><silent> r vimrime#SimulateKeyInput('r')
	inoremap <expr><silent> s vimrime#SimulateKeyInput('s')
	inoremap <expr><silent> t vimrime#SimulateKeyInput('t')
	inoremap <expr><silent> u vimrime#SimulateKeyInput('u')
	inoremap <expr><silent> v vimrime#SimulateKeyInput('v')
	inoremap <expr><silent> w vimrime#SimulateKeyInput('w')
	inoremap <expr><silent> x vimrime#SimulateKeyInput('x')
	inoremap <expr><silent> y vimrime#SimulateKeyInput('y')
	inoremap <expr><silent> z vimrime#SimulateKeyInput('z')
	inoremap <expr><silent> A vimrime#SimulateKeyInput('A')
	inoremap <expr><silent> B vimrime#SimulateKeyInput('B')
	inoremap <expr><silent> C vimrime#SimulateKeyInput('C')
	inoremap <expr><silent> D vimrime#SimulateKeyInput('D')
	inoremap <expr><silent> E vimrime#SimulateKeyInput('E')
	inoremap <expr><silent> F vimrime#SimulateKeyInput('F')
	inoremap <expr><silent> G vimrime#SimulateKeyInput('G')
	inoremap <expr><silent> H vimrime#SimulateKeyInput('H')
	inoremap <expr><silent> I vimrime#SimulateKeyInput('I')
	inoremap <expr><silent> J vimrime#SimulateKeyInput('J')
	inoremap <expr><silent> K vimrime#SimulateKeyInput('K')
	inoremap <expr><silent> L vimrime#SimulateKeyInput('L')
	inoremap <expr><silent> M vimrime#SimulateKeyInput('M')
	inoremap <expr><silent> N vimrime#SimulateKeyInput('N')
	inoremap <expr><silent> O vimrime#SimulateKeyInput('O')
	inoremap <expr><silent> P vimrime#SimulateKeyInput('P')
	inoremap <expr><silent> Q vimrime#SimulateKeyInput('Q')
	inoremap <expr><silent> R vimrime#SimulateKeyInput('R')
	inoremap <expr><silent> S vimrime#SimulateKeyInput('S')
	inoremap <expr><silent> T vimrime#SimulateKeyInput('T')
	inoremap <expr><silent> U vimrime#SimulateKeyInput('U')
	inoremap <expr><silent> V vimrime#SimulateKeyInput('V')
	inoremap <expr><silent> W vimrime#SimulateKeyInput('W')
	inoremap <expr><silent> X vimrime#SimulateKeyInput('X')
	inoremap <expr><silent> Y vimrime#SimulateKeyInput('Y')
	inoremap <expr><silent> Z vimrime#SimulateKeyInput('Z')
	inoremap <expr><silent> 1 vimrime#SimulateKeyInput('1')
	inoremap <expr><silent> 2 vimrime#SimulateKeyInput('2')
	inoremap <expr><silent> 3 vimrime#SimulateKeyInput('3')
	inoremap <expr><silent> 4 vimrime#SimulateKeyInput('4')
	inoremap <expr><silent> 5 vimrime#SimulateKeyInput('5')
	inoremap <expr><silent> 6 vimrime#SimulateKeyInput('6')
	inoremap <expr><silent> 7 vimrime#SimulateKeyInput('7')
	inoremap <expr><silent> 8 vimrime#SimulateKeyInput('8')
	inoremap <expr><silent> 9 vimrime#SimulateKeyInput('9')
	inoremap <expr><silent> <Left> vimrime#SimulateSpecial('{Left}', "\<Left>")
	inoremap <expr><silent> <Right> vimrime#SimulateSpecial('{Right}', "\<Right>")
	inoremap <expr><silent> <ESC> vimrime#SimulateSpecial('{Escape}', "\<Esc>")
	autocmd BufEnter * call s:SpecialBinding()
	inoremap <expr><silent> - vimrime#SimulateKeyInput('-')
	inoremap <expr><silent> = vimrime#SimulateKeyInput('=')
	inoremap <expr><silent> ! vimrime#SimulateKeyInput('!')
	inoremap <expr><silent> @ vimrime#SimulateKeyInput('@')
	inoremap <expr><silent> # vimrime#SimulateKeyInput('#')
	inoremap <expr><silent> $ vimrime#SimulateKeyInput('$')
	inoremap <expr><silent> % vimrime#SimulateKeyInput('%')
	inoremap <expr><silent> ^ vimrime#SimulateKeyInput('^')
	inoremap <expr><silent> & vimrime#SimulateKeyInput('&')
	inoremap <expr><silent> * vimrime#SimulateKeyInput('*')
	inoremap <expr><silent> _ vimrime#SimulateKeyInput('_')
	inoremap <expr><silent> + vimrime#SimulateKeyInput('+')
	inoremap <expr><silent> \ vimrime#SimulateKeyInput('\')
	inoremap <expr><silent> ; vimrime#SimulateKeyInput(';')
	inoremap <expr><silent> . vimrime#SimulateKeyInput('.')
	inoremap <expr><silent> / vimrime#SimulateKeyInput('/')
	inoremap <expr><silent> ? vimrime#SimulateKeyInput('?')
	inoremap <expr><silent> ( vimrime#SimulateKeyInput('(')
	inoremap <expr><silent> ) vimrime#SimulateKeyInput(')')
	inoremap <expr><silent> [ vimrime#SimulateKeyInput('[')
	inoremap <expr><silent> ] vimrime#SimulateKeyInput(']')
	inoremap <expr><silent> { vimrime#SimulateKeyInput('{')
	inoremap <expr><silent> } vimrime#SimulateKeyInput('}')
	inoremap <expr><silent> ' vimrime#SimulateKeyInput("'")
	inoremap <expr><silent> " vimrime#SimulateKeyInput('"')
	inoremap <expr><silent> < vimrime#SimulateKeyInput('<')
	inoremap <expr><silent> > vimrime#SimulateKeyInput('>')
	inoremap <expr><silent> : vimrime#SimulateKeyInput(':')
	inoremap <expr><silent> , vimrime#SimulateKeyInput(',')
	inoremap <expr><silent> \| vimrime#SimulateKeyInput('|')
	inoremap <expr><silent> ` vimrime#SimulateKeyInput('`')
	inoremap <expr><silent> ~ vimrime#SimulateKeyInput('~')
endfunction
