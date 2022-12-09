function! trish#tag#get_tag_before_or_under_cursor()
	let l:str=getline('.')
	let l:str = matchstr(getline('.'), '#[^#]*\%'.(col('.')+1) . 'c[^#]*')
	let l:tag = substitute(l:str, '[^#]*\(#[a-z0-9/-]*\)[^#]*', '\1', 'g')
	if len(l:tag) <= 2  
		return ""
	else
		let g:tag_under=l:tag
		return l:tag
	endif
endfunction

function trish#tag#extract_tags_from_string(str) abort
	let l:lst = []
	let l:tags = substitute(a:str, '#[a-z0-9/-][a-z0-9/-]*', '\=add(l:lst, submatch(0))', 'g')
	return l:lst
endfunction


function trish#tag#grab_file_and_num_under_cursor() abort
	let l:str = trim(expand('<cWORD>'), '=:')
	let g:filedbg = l:str
	if l:str =~ '^[a-z0-9/.-]*:\d*$'
		return split(l:str,':')
	else
		return []
	endif
endfunction

function trish#tag#update_all_tags() abort
	let l:referenced_tags = sort(uniq(systemlist('egrep -o "#[a-zA-Z0-9][a-zA-Z0-9/-]*" ' . shellescape(trish#backlinks#cache_file()))))
	let l:all_filenames = map(filter(systemlist('find * -name "*.md" -type f -o -type d'), {k,n -> n !~ ' '}), {k,n -> '#' . substitute(n, '\.md$', '', '')})
	let g:trish#tag#all_tags = l:referenced_tags + l:all_filenames
	call sort(uniq(g:trish#tag#all_tags))

	let l:tag_file_lines = map(copy(g:trish#tag#all_tags), 'substitute(v:val, "^#\\(.*\\)$", "#\\1\t\\1.md\t1", "")')
	call writefile(l:tag_file_lines, 'tags.tmp')
	call rename('tags.tmp', 'tags')
endfunction

" Start of transclusions
"function! trish#tag#get_section_lines(tag, section)
"	let l:file = trish#tag#filename_for_tag(a:tag)
"	if !filereadable(l:file)
"		return []
"	endif
"
"	let l:lines = readfile(l:file)
"
"	let l:insection = 0
"	let l:section_lines = []
"	for l:i in l:lines
"		let l:header = substitute(l:i, '^\(\s\|-\)*#\s\(.*\)', '\2', '')
"		if l:header == l:i
"			let l:header = ''
"		endif
"
"		if l:insection && l:header != ''
"			break
"		endif
"
"		if l:insection 
"			let l:section_lines += ['> ' . l:i]
"		endif
"
"		if l:header == a:section
"			let l:insection = 1
"		endif
"	endfor
"
"	if l:insection
"		return ['---# ' . a:tag . '//' . a:section, l:section_lines, '---']
"	else
"		return ['ERR:no such section in ' . a:tag]
"	endif
"endfunction
"
function! trish#tag#tagfunc(pattern, flags, info)
	if a:flags == 'c'
		let l:loc = trish#tag#grab_file_and_num_under_cursor()
		
		if !empty(l:loc) 
			return [{'name':l:loc[0], 'filename':l:loc[0], 'cmd':l:loc[1]}]
		endif

		let l:w = expand('<cWORD>')
		if l:w =~ '%[a-z0-9/-]\+'
			return taglist('#' . trim(l:w, '%'))
		endif
	endif

	return v:null
endfun

function trish#tag#filename_for_tag(tag)
	return trim(a:tag, '#') . '.md'
endfunction

function trish#tag#runtests()
	return assert_equal(trish#tag#extract_tags_from_string('#asdf #c/sdf-wer # #sdf-sdf werwer cvdsf'), ['#asdf', '#c/sdf-wer', '#sdf-sdf'])
endfunction
