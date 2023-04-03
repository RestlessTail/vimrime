function! ParseJSON(str)
	let s:rawJson = a:str
	let s:pos = 0
	return ParsePrimary()
endfunction

function! ParsePrimary()
	if s:rawJson[s:pos] == '{'
		return ParseObject()
	elseif s:rawJson[s:pos] == '['
		return ParseArray()
	elseif s:rawJson[s:pos] == '"'
		return ParseString()
	else
		return ParseNum()
	endif
endfunction

function! ParseString()
	let s:pos += 1
	let endPos = match(s:rawJson, '"', s:pos)
	let ret = s:rawJson[s:pos:(endPos - 1)]
	let s:pos = endPos + 1
	return ret
endfunction

function! ParseNum()
	let endPos = s:pos
	while s:rawJson[endPos] != '}' && s:rawJson[endPos] != ',' 
		let endPos = endPos + 1
	endwhile
	let ret = str2nr(s:rawJson[s:pos:(endPos - 1)])
	let s:pos = endPos
	return ret
endfunction

function ParseObject()
	let s:pos += 1
	let ret = {}
	while s:rawJson[s:pos] != '}'
		let key = ParseString()
		let s:pos = s:pos + 1
		let ret[key] = ParsePrimary()
		if s:rawJson[s:pos] ==# ',' 
			let s:pos = s:pos + 1
		endif
	endwhile
	let s:pos = s:pos + 1
	return ret
endfunction

function ParseArray()
	let s:pos += 1
	let ret = []
	while s:rawJson[s:pos] != ']'
		call add(ret, ParsePrimary())
		if s:rawJson[s:pos] ==# ','
			let s:pos = s:pos + 1
		endif
	endwhile
	let s:pos = s:pos + 1
	return ret
endfunction

