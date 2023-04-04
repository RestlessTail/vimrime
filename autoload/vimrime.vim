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
inoremap <expr><silent> 1 vimrime#SimulateKeyInput('1')
inoremap <expr><silent> 2 vimrime#SimulateKeyInput('2')
inoremap <expr><silent> 3 vimrime#SimulateKeyInput('3')
inoremap <expr><silent> 4 vimrime#SimulateKeyInput('4')
inoremap <expr><silent> 5 vimrime#SimulateKeyInput('5')
inoremap <expr><silent> = vimrime#SimulateKeyInput('=')
inoremap <expr><silent> - vimrime#SimulateKeyInput('-')
inoremap <expr><silent> <a-k> vimrime#SimulateKeyInput('{BackSpace}')
inoremap <expr><silent> <a-j> vimrime#SimulateKeyInput(' ')

function! vimrime#Init()
	let l:options = {}
	let l:options['out_io'] = 'pipe'
	let l:options['pty'] = 1
	let l:options['out_mode'] = 'nl'
	let l:options['cwd'] = g:vimrimeDictDir
	let g:vimrimeServerJob = job_start(g:vimrimeServerBin, options)
	let g:vimrimeServerChannel = job_getchannel(g:vimrimeServerJob)
	let g:vimrimeStatus = 'starting up'
	let g:vimrimeRunning = 0
endfunction

function! vimrime#UpdateUI()
	let l:preeditSize = strlen(g:vimrimeRes['composition']['preedit'])
	let l:msg = ""
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
	if len(g:vimrimeRes['menu']['candidates'])
		let l:size = len(g:vimrimeRes)
		for i in range(1, l:size - 1)
			let l:msg = l:msg . i . '. ' . g:vimrimeRes['menu']['candidates'][i - 1] . ', '
		endfor
		let l:msg = l:msg . l:size . '. ' . g:vimrimeRes['menu']['candidates'][l:size - 1]
		echo l:msg
	endif
endfunction

function! vimrime#SimulateKeyInput(key)
	if g:vimrimeEnabled
		call ch_evalraw(g:vimrimeServerChannel, a:key . "\n")
		let g:vimrimeRes = vimrime_minijson#ParseJSON(ch_readraw(g:vimrimeServerChannel))
		call vimrime#UpdateUI()
		return g:vimrimeRes["commit"]
	else
		return a:key
	endif
endfunction

