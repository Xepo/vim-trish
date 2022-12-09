
let g:trish#aliases#aliases = {}

" on replacement, it moves cursor from loc to within tag if sub tag is longer.  should figure out how to retain relative position
function! trish#aliases#load() abort
	let l:aliases_file = 'tag-aliases.cfg'

	if !filereadable(l:aliases_file)
		return
	endif

	let l:new_aliases = {}
	let l:file = readfile(l:aliases_file)
	for i in l:file
		let l:same_tags = split(i, ' \+')
		if len(l:same_tags) == 0
			continue
		endif
		let l:final_tag = l:same_tags[0]
		for l:tag in l:same_tags[1:-1]
			let l:new_aliases[l:tag] = l:final_tag
		endfor
	endfor

	let g:trish#aliases#aliases = l:new_aliases
endfunction

function! trish#aliases#find(tag) abort
	if has_key(g:trish#aliases#aliases, a:tag)
		return g:trish#aliases#aliases[a:tag]
	endif
	return ''
endfunction

function trish#aliases#apply_if_needed(highlight_tag)
	let l:highlight_tag = a:highlight_tag
	let l:replacement = trish#aliases#find(l:highlight_tag)
	if l:replacement == ''
		return l:highlight_tag
	else
		let l:curs=getcurpos()
		keeppatterns exe ':s;' . l:highlight_tag . ';' . l:replacement . ';ge'
		let l:curs[2] += len(l:replacement) - len(l:highlight_tag)
		let l:curs[4] += len(l:replacement) - len(l:highlight_tag)
		call setpos('.',l:curs)

		return l:replacement
	endif 
endfunction

augroup reload_aliases
au reload_aliases BufWritePost tag-aliases.cfg :call trish#aliases#load()  
augroup END

