" Trish backlinks.vim

function! s:get_root_files() abort
	return readdir('.', {n -> n !~ '^\.' && n != 'archive' && (isdirectory(n) || n =~ '.md$')}) 
endfunction

function! trish#backlinks#cache_file() abort
	return "backlinks-cache.tmp"
endfunction

function! trish#backlinks#cache_error_file() abort
	return "backlinks-cache-errors.tmp"
endfunction

let g:trish_in_retry = 0

function! trish#backlinks#updatecache_callback(job, exit_status) abort
	if a:exit_status != 0
		if g:trish_in_retry 
			let g:trish_in_retry = 0
			echoerr "Updating backlinks cache failed.  For more info, see: " . trish#backlinks#cache_error_file()
			return
		else
			let g:trish_in_retry = 1
			call trish#backlinks#updatecache()
		endif
	else
		let g:trish_in_retry = 0
		call trish#tag#update_all_tags()
	endif
endfunction

function! trish#backlinks#updatecache() abort
	let l:files = s:get_root_files()
	let l:expression = '#[a-z]'
	if has("ios")
		" For whatever reason, iVim seems to require extra quoting for this
		let l:expression = "'" . l:expression . "'"
	endif
	let l:cmd = ['egrep', '-H', '-n', '--directories=recurse', '-e', l:expression] + l:files
	call job_start(l:cmd, {'out_io':'file' , 'out_name':trish#backlinks#cache_file() , 'err_io':'file' , 'err_name':trish#backlinks#cache_error_file() , 'exit_cb': 'trish#backlinks#updatecache_callback' })
endfunction

function! trish#backlinks#backlinks_for_tags(tags) abort
	let l:tags = filter(copy(a:tags), 'v:val =~ "^#"')

	if len(l:tags) == 0
		return []
	endif

	call writefile(l:tags, 'tag-search.tmp') 
	let l:ret = systemlist('fgrep -f tag-search.tmp ' . shellescape(trish#backlinks#cache_file()))

	let l:filename = trish#tag#filename_for_tag(l:tags[0])
	call filter(l:ret, 'split(v:val, ":")[0] != l:filename')

	return l:ret
endfunction

function! trish#backlinks#backlinks_for_tag(tag) abort
	let l:ret = systemlist('grep ' . shellescape(a:tag) . ' ' . shellescape(trish#backlinks#cache_file()))
	let l:filename = trish#tag#filename_for_tag(a:tag)
	call filter(l:ret, 'split(v:val, ":")[0] != l:filename')
	return l:ret
endfunction

function trish#backlinks#jump_to_adjacent_usage(dir)
	let l:tag = trish#tag#get_tag_under_before_or_after_cursor()
	if l:tag == ""
		return
	endif

	let l:ret = systemlist('grep ' . shellescape(l:tag) . ' ' . shellescape(trish#backlinks#cache_file()))

	if expand('%') =~ 'daily' 
		let l:compareto = expand('%') . ':' . line('.')
	else
		let l:compareto = strftime('daily/%Y-%m-%d.md:999999')
	endif

	let l:ret = sort(l:ret)
	let l:i = 0
	while l:i < len(l:ret) && l:ret[l:i] < l:compareto
		let l:i+=1
	endwhile
	" Note l:i might == len(l:ret).  Clamp below will fix it.
	let l:target = l:i + a:dir
	let l:target = max([0, min([len(l:ret)-1, l:target])])

	let l:file = split(l:ret[l:target], ':')
	:exe ':e +' . l:file[1] . ' ' . l:file[0]
	call search(l:tag, 'ceW', l:file[1]) 
endfunction

function! trish#backlinks#setup() abort
	augroup trishbacklinks
	au!
	autocmd BufWritePost	*.md keepjumps lockmarks call trish#backlinks#updatecache()
	augroup END
endfunction
