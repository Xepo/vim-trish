function! trish#date_jumper#jump(direction) abort
	let l:date = expand("%")
	if l:date !~ '^daily/\d\d\d\d-\d\d-\d\d.md$'
		let l:date = "daily/" . strftime('%Y-%m-%d') . ".md"
	endif

	echo l:date
	let l:files=sort(glob('daily/*.md', 1,1))
	let l:prev = l:files[0]
	let l:next = l:files[1]

	for i in l:files
		let l:next = i
		if i > l:date
			break
		endif
		if i != l:date
			let l:prev = i
		endif
	endfor

	if a:direction == -1
		return l:prev
	else
		if l:next < l:date
			return l:date
		else
			return l:next
		endif
	endif
endfunction

function s:BufferIsEmpty() abort
	return line('$') == 1 && getline('.') == ''
endfunction

" Start of transclusions
"function! trish#date_jumper#replace_pull() abort
"	let l:pull = substitute(getline('.'), 's/^.*pull: \(.*\)', '\1', '')
"	let l:components = split(l:pull, '//')
"	if len(l:components) == 2
"		let l:file = trish#tag#filename_for_tag(components[0])
"		let l:section = l:components[1]
"
"		if filereadable(l:file)
"			:exe "r!grep -A20 " . l:file
"		endif
"	endif
"endfunction

function! trish#date_jumper#go_to_today() abort
	let l:date = strftime('%Y-%m-%d')
	let l:file = 'daily/' . l:date . '.md'

	exe ':e ' . l:file

	" TODO:  Get rid of this in favor of the new_md autocommand
	if s:BufferIsEmpty()
		:0r templates/daily template.md
		exe ':%s;{{date:YYYY-MM-DD}};' . l:date . ';g'
		:%g/^$/d
		normal gg
	endif
endfunction
"function! ListNearbyDates() abort
"	let l:date = expand("%")
"	if l:date !~ '^daily/\d\d\d\d-\d\d-\d\d.md$'
"		let l:date = "daily/" . strftime('%Y-%m-%d') . ".md"
"	endif
"
"	let l:files=sort(glob('daily/*.md', 1,1))
"	let l:prev = l:files[0]
"	let l:next = l:files[1]
"
"	for i in l:files
"		let l:next = i
"		if i > l:date
"			break
"		endif
"		if i != l:date
"			let l:prev = i
"		endif
"	endfor
"
"
"endfunction

