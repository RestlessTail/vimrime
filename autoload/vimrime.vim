inoremap <expr><silent> a SimulateKeyInput('a')
inoremap <expr><silent> b SimulateKeyInput('b')
inoremap <expr><silent> c SimulateKeyInput('c')
inoremap <expr><silent> d SimulateKeyInput('d')
inoremap <expr><silent> e SimulateKeyInput('e')
inoremap <expr><silent> f SimulateKeyInput('f')
inoremap <expr><silent> g SimulateKeyInput('g')
inoremap <expr><silent> h SimulateKeyInput('h')
inoremap <expr><silent> i SimulateKeyInput('i')
inoremap <expr><silent> j SimulateKeyInput('j')
inoremap <expr><silent> k SimulateKeyInput('k')
inoremap <expr><silent> l SimulateKeyInput('l')
inoremap <expr><silent> m SimulateKeyInput('m')
inoremap <expr><silent> n SimulateKeyInput('n')
inoremap <expr><silent> o SimulateKeyInput('o')
inoremap <expr><silent> p SimulateKeyInput('p')
inoremap <expr><silent> q SimulateKeyInput('q')
inoremap <expr><silent> r SimulateKeyInput('r')
inoremap <expr><silent> s SimulateKeyInput('s')
inoremap <expr><silent> t SimulateKeyInput('t')
inoremap <expr><silent> u SimulateKeyInput('u')
inoremap <expr><silent> v SimulateKeyInput('v')
inoremap <expr><silent> w SimulateKeyInput('w')
inoremap <expr><silent> x SimulateKeyInput('x')
inoremap <expr><silent> y SimulateKeyInput('y')
inoremap <expr><silent> z SimulateKeyInput('z')
inoremap <expr><silent> 1 SimulateKeyInput('1')
inoremap <expr><silent> 2 SimulateKeyInput('2')
inoremap <expr><silent> 3 SimulateKeyInput('3')
inoremap <expr><silent> 4 SimulateKeyInput('4')
inoremap <expr><silent> 5 SimulateKeyInput('5')
inoremap <expr><silent> = SimulateKeyInput('=')
inoremap <expr><silent> - SimulateKeyInput('-')

function! Init()
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

function! UpdateUI()
	if len(g:vimrimeRes["menu"]["candidates"])
		let l:msg = ""
		let l:size = len(g:vimrimeRes)
		for i in range(1, l:size - 1)
			let l:msg = l:msg . i . '. ' . g:vimrimeRes["menu"]["candidates"][i - 1] . ', '
		endfor
		let l:msg = l:msg . l:size . '. ' . g:vimrimeRes["menu"]["candidates"][l:size - 1]
		echo l:msg
	endif
endfunction

function! SimulateKeyInput(key)
	if g:vimrimeEnabled
		call ch_evalraw(g:vimrimeServerChannel, a:key . "\n")
		let g:vimrimeRes = vimrime_minijson#ParseJSON(ch_readraw(g:vimrimeServerChannel))
		call UpdateUI()
		return g:vimrimeRes["commit"]
	else
		return a:key
	endif
endfunction

call Init()
message

