function! trish#indent#indent(in_or_out)
	let g:db =  virtcol('.') . 'a' . virtcol('$')
	let l:wv = winsaveview()
	let l:startline=line('.')
	let l:line = l:startline+1
	let l:indent = indent(l:startline)

	" Empty line shouldn't indent its children
	if getline('.') =~ '^\s*-\?\s*$'
		let l:indent = 10000
	endif

	while (indent(l:line) > l:indent)
		let l:line+=1
	endwhile
	let l:cmd=":" . l:startline . "," . (l:line - 1) . a:in_or_out
	exe l:cmd
	if a:in_or_out == ">"
		let l:wv['col'] += 1
	else
		let l:wv['col'] -= 1
	endif
	call winrestview(l:wv)
	let g:db .=  virtcol('.') . 'a' . virtcol('$')
endfunction

function! trish#indent#should_tab_complete() 
	if col('.') == 1
		return v:false
	endif

	let l:line = getline('.')
	let l:ch = l:line[col('.')-2]
	let g:ln = l:line
	let g:ch = l:ch
	return l:ch =~ '[#a-zA-Z0-9/-]'
endfunction

function! trish#indent#tab_behavior(shifted)
	if pumvisible()
		if a:shifted
			return ''
		else
			return ''
		endif
	endif

	if a:shifted
		return ':call trish#indent#indent("<")'
	elseif trish#indent#should_tab_complete()
		return ''
	else
		return ':call trish#indent#indent(">")'
	endif
endfunction
