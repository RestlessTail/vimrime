" Vim plugin for pinyin input
" Last Change:  2021 Dec 30
" Maintainer:   RestlessTail <1826930551@qq.com>
" License:      Apache 2.0

if exists("g:loaded_vimrime")
	finish
endif
let g:loaded_vimrime = 1

if exists("g:vimrimeServerBin") == 0
	let g:vimrimeServerBin = 'vimrimeserver'
endif

if exists("g:vimrimeDictDir") == 0
	let g:vimrimeDictDir = ""
endif

if exists("g:vimrimeEnabled") == 0
	finish
elseif g:vimrimeEnabled
	call vimrime#Init()
else
	finish
endif

