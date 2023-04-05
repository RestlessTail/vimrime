" Vim plugin for pinyin input
" Last Change:  2021 Dec 30
" Maintainer:   RestlessTail <1826930551@qq.com>
" License:      Apache 2.0

if exists("g:loaded_vimrime")
	finish
endif
let g:loaded_vimrime = 1

"默认为禁用状态（即输入英文）
if exists("g:vimrimeActive") == 0
	let g:vimrimeActive = 0
endif

"vimrimeserver二进制文件位置
"默认使用自带的预编译版本
if exists("g:vimrimeServerBin") == 0
	let g:vimrimeServerBin = expand('<script>:p:h:h') . '/server/bin/vimrimeserver'
endif

"rime词库位置
"默认自带了rime的官方词库
if exists("g:vimrimeDictDir") == 0
	let g:vimrimeDictDir = expand('<script>:p:h:h') . '/dict'
endif

"是否加载vimrime
if exists("g:vimrimeEnabled") == 0
	finish
elseif g:vimrimeEnabled
	call vimrime#Init()
else
	finish
endif

