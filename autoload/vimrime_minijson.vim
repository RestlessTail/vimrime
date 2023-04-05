"将JSON字符串解析为vim对象
"这是JSON的一个子集，不能有空格，只支持对象、列表、字符串和整数
"不要用在别的地方！

function! vimrime_minijson#ParseJSON(str)
	let s:rawJson = a:str
	let s:pos = 0
	return s:ParsePrimary()
endfunction

function! s:ParsePrimary()
	if s:rawJson[s:pos] == '{'
		return s:ParseObject()
	elseif s:rawJson[s:pos] == '['
		return s:ParseArray()
	elseif s:rawJson[s:pos] == '"'
		return s:ParseString()
	else
		return s:ParseNum()
	endif
endfunction

function! s:ParseString()
	let s:pos += 1
	let l:endPos = match(s:rawJson, '"', s:pos)
	let l:ret = s:rawJson[s:pos:(l:endPos - 1)]
	let s:pos = l:endPos + 1
	return l:ret
endfunction

function! s:ParseNum()
	let l:endPos = s:pos
	while s:rawJson[l:endPos] != '}' && s:rawJson[l:endPos] != ',' 
		let l:endPos = l:endPos + 1
	endwhile
	let l:ret = str2nr(s:rawJson[s:pos:(l:endPos - 1)])
	let s:pos = l:endPos
	return l:ret
endfunction

function s:ParseObject()
	let s:pos += 1
	let l:ret = {}
	while s:rawJson[s:pos] != '}'
		let l:key = s:ParseString()
		let s:pos = s:pos + 1
		let l:ret[l:key] = s:ParsePrimary()
		if s:rawJson[s:pos] ==# ',' 
			let s:pos = s:pos + 1
		endif
	endwhile
	let s:pos = s:pos + 1
	return l:ret
endfunction

function s:ParseArray()
	let s:pos += 1
	let l:ret = []
	while s:rawJson[s:pos] != ']'
		call add(ret, s:ParsePrimary())
		if s:rawJson[s:pos] ==# ','
			let s:pos = s:pos + 1
		endif
	endwhile
	let s:pos = s:pos + 1
	return l:ret
endfunction

