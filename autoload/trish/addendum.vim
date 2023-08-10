" Trish addendum

function! trish#addendum#sort_backlinks(d1,d2)
	if a:d1 =~ '^daily/' 
		if a:d2 =~ '^daily/'
			return (a:d1 < a:d2) ? 1 : -1
		else
			return -1
		endif
	elseif a:d2 =~ '^daily/'
		return 1
	else
		return (a:d1 < a:d2) ? -1 : 1
	endif
endfunction

function! s:extract_ref_from_string(str) abort
	let l:ref = matchstr(a:str, 'ref:\zs.*')
	let l:ref_tags = trish#tag#extract_tags_from_string(l:ref)
	return l:ref_tags
endfunction

function! s:find_backlinks(tag) abort
	let l:tags_to_lookup = [a:tag]
	let l:tags_to_lookup += s:extract_ref_from_string(getline(1))
	let l:ret = trish#backlinks#backlinks_for_tags(l:tags_to_lookup)
	call sort(l:ret, "trish#addendum#sort_backlinks")
	return l:ret
endfunction

function! s:get_parents(tag) abort
	let l:parents = []
	let l:components = split(a:tag, '/')

	while len(l:components) >= 2
		unlet l:components[-1]
		let l:parents += [join(l:components, '/')]
	endwhile

	if len(l:parents) > 0 && (l:parents[-1] == '#u' || l:parents[-1] == '#daily' || l:parents[-1] == '#p' || l:parents[-1] == '#g' || l:parents[-1] == 'recurring')
		unlet l:parents[-1]
	endif
	return l:parents
endfunction 


let s:addendum_special_line = '----ADDENDUM'

function! s:find_ios_conflicts() abort
	if has('ios')
		let l:conflicts = glob(expand('%:r') . ' ' . '?.md', v:false, v:true)
		let l:conflicts += glob(expand('%:r') . ' ' . '??.md', v:false, v:true)
		call uniq(sort(l:conflicts))
		return l:conflicts
	endif
endfunction

function! s:find_children() abort
	let l:children = glob(expand('%:r') . '/*', v:false, v:true)
	call uniq(sort(map(l:children, '"#" . substitute(v:val, ".md$", "", "")')))
	return l:children
endfunction

function! trish#addendum#remove() abort
	let l:view = winsaveview()
	normal gg
	exe 'silent! :/^\n\?' . s:addendum_special_line . '/,$d _'
	call winrestview(l:view)
endfunction 

function! trish#addendum#append() abort
	call trish#addendum#remove()

	let l:view = winsaveview()
	let l:tag = '#' . expand('%:r')

	" Add header if empty file
	if 0 == search('\S', 'nw') 
		call setline(1, '# ' . l:tag)
	endif

	let l:totalgrep = s:find_backlinks(l:tag)
	let l:children = s:find_children()
	let l:conflicts = s:find_ios_conflicts()
	let l:parents = s:get_parents(l:tag)

	if !empty(l:children)  || !empty(l:conflicts) || !empty(l:parents) || !empty(l:totalgrep)
		call append(line('$'), '')
		call append(line('$'), s:addendum_special_line) "Special line used cutoff for saving

		if !empty(l:conflicts)
			call append(line('$'), '----Conflicts')
			call append(line('$'), l:conflicts)
		endif

		if !empty(l:parents)
			call append(line('$'), '---Parents')
			call append(line('$'), l:parents)
		endif

		if !empty(l:children)
			call append(line('$'), '---Children')
			call append(line('$'), l:children)
		endif

		if !empty(l:totalgrep)
			call append(line('$'), '---Backlinks')
			call append(line('$'), l:totalgrep)
		endif
	endif

	call winrestview(l:view)
endfunction 

function! trish#addendum#setup() abort
	augroup trish_addendum
	au!
	autocmd BufReadPost	*.md lockmarks keepjumps call trish#addendum#append()
	autocmd BufWritePre	*.md keepjumps lockmarks call trish#addendum#remove()
	autocmd BufWritePost	*.md keepjumps lockmarks call trish#addendum#append()
	augroup END
endfunction

function! trish#addendum#runtests() abort
	let l:ret = 0
	let l:ret +=	assert_equal(s:get_parents('#a/b/c'), ['#a/b', '#a'])
	let l:ret +=	assert_equal(s:extract_ref_from_string('asdfasdf #sdf ref: #ab #a/c-d'), ['#ab', '#a/c-d'])
	let l:ret +=	assert_equal(s:extract_ref_from_string('asdfasdf #sdf'), [])

	return l:ret
endfunction
