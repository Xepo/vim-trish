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

function! trish#backlinks#updatecache_callback(job, exit_status) abort
	if a:exit_status != 0
		echoerr "Updating backlinks cache failed.  For more info, see: " . trish#backlinks#cache_error_file()
		return
	else
		call trish#tag#update_all_tags()
	endif
endfunction

function! trish#backlinks#updatecache() abort
	let l:files = s:get_root_files()
	let l:cmd = ['egrep', '-H', '-n', '--directories=recurse', '-e', "'#[a-z]'"] + l:files
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

function! trish#backlinks#setup() abort
	augroup trishbacklinks
	au!
	autocmd BufWritePost	*.md keepjumps lockmarks call trish#backlinks#updatecache()
	augroup END
endfunction
