
function! trish#setup#hashtag_highlighting() abort
	syntax clear
	syntax match hashtag /\(#[a-z0-9/-]\+\)/
	syntax match hashtag /\(%[a-z0-9/-]\+\)/
	hi hashtag ctermfg=LightBlue guifg=LightBlue
	syntax match userhashtag ^\(#u/[a-z0-9/-]*\)^
	hi userhashtag ctermfg=Green guifg=Green
	syntax match header /^\(\s\|-\)*\zs#\s.*/
	syntax match header /^---.*/
	hi header term=underline gui=underline
endfunction

function trish#setup#ios_specific_maps() abort
	if has("ios")
		vnoremap <buffer> <leader>df "zy:vert diffsp <c-r>=trim(@z)<CR><CR>
		noremap <buffer> <leader>df "zyy:vert diffsp <c-r>=trim(@z)<CR><CR>
		nnoremap <buffer> <D-u> :exe 'iopenurl shareddocuments:/' . substitute(expand('%:p:h'), ' ', '%20', 'g')<CR>
	endif
endfunction

function! trish#setup#bufreadmd()
	set iskeyword=@,48-57,-,#,/
	call trish#setup#hashtag_highlighting()
	call trish#setup#ios_specific_maps()

	setlocal autowrite
	setlocal autowriteall
	setlocal autoindent
	setlocal ts=4 shiftwidth=4

	inoreabbrev <buffer> #tdt #daily/<c-r>=strftime('%Y-%m-%d')<CR>
	" This mapping used to have <c-]> at the beginningo f it, before the
	" <space><c-o>, but I can't figure out why I put it there.  Try removing
	" it
	inoremap <buffer> <space> <space><c-o>:silent call trish#preview#update()<CR>
	nnoremap <buffer> <CR> :update<CR>:call trish#preview#update()<CR>
	nnoremap <buffer> <S-Tab> :call trish#indent#indent('<')<CR>
	nnoremap <buffer> <Tab> :call trish#indent#indent('>')<CR>

	inoremap <buffer> <expr> <Tab> trish#indent#tab_behavior(v:false)
	inoremap <buffer> <expr> <S-Tab> trish#indent#tab_behavior(v:true)

	nnoremap <buffer> [[ :call search('\m^\(\s\\|-\)*#\s\\|^---', 'bsW' )<CR>
	nnoremap <buffer> ]] :call search('\m^\(\s\\|-\)*#\s\\|^---', 'sW' )<CR>

	nnoremap <buffer> [1 :call search('\m^\(\s\\|-\)*#\s\\|^---', 'bsW' )<CR>
	nnoremap <buffer> ]1 :call search('\m^\(\s\\|-\)*#\s\\|^---', 'sW' )<CR>

	nnoremap <buffer> [2 :call search('\m^\(\s\\|-\)*##\s\\|^---', 'bsW' )<CR>
	nnoremap <buffer> ]2 :call search('\m^\(\s\\|-\)*##\s\\|^---', 'sW' )<CR>

	nnoremap <buffer> - :call trish#backlinks#jump_to_adjacent_usage(-1)<CR>
	nnoremap <buffer> + :call trish#backlinks#jump_to_adjacent_usage(1)<CR>

	if !exists('g:trish_autodash') || g:trish_autodash == 'y'
		inoremap <buffer> <buffer> <CR> <CR>-<Space>
	endif
endfunction

function trish#setup#load_template_if_needed()
	let l:template_name = 'templates/' . trim(expand('%:h'), '/') . '.md'
	if filereadable(l:template_name)
		let l:date = expand('%:t:r')
		if l:date !~ '\d\d\d\d-\d\d-\d\d'
			let l:date = strftime('%Y-%m-%d')
		endif

		exe "0r " . l:template_name
		exe ':%s;{{date:YYYY-MM-DD}};' . l:date . ';ge'

		let l:tag = trish#tag#tag_for_filename(expand('%'))

		exe ':%s;{{tagname}};' . l:tag . ';ge'
		%g/^$/d _
		normal gg
	endif
endfunction

function trish#setup#new_md()
	call trish#setup#load_template_if_needed()
	call trish#addendum#append()
	call trish#setup#bufreadmd()
endfunction

function trish#setup#runtests() abort
	let l:ret = 0
	let l:ret += trish#tag#runtests()
	let l:ret += trish#addendum#runtests()
	if l:ret > 0
		throw "Trish unit tests failed: " . string(v:errors)
	endif
endfunction

function trish#setup#new_md_if_needed() abort
	if line('$') == 1 && trim(getline(1)) == ''
		call trish#setup#new_md()
	endif
endfunction

function trish#setup#setup(dir) abort
	call trish#setup#runtests()

	" A lot of code here is dependent on the current directory being your
	" notes root.  I've tried to rewrite it, but weirdnesses on the iPad have
	" fought me on it.
	set noautochdir 

	exe 'cd ' . a:dir
	let l:dir = fnamemodify(a:dir, ':p')
	let g:trish#dir = l:dir

	call trish#addendum#setup()
	call trish#backlinks#setup()

	nnoremap <leader>t :call trish#date_jumper#go_to_today()<CR>
	nnoremap <leader>p :exe ":e " . trish#date_jumper#jump(-1)<CR>
	nnoremap <leader>n :exe ":e " . trish#date_jumper#jump(1)<CR>

	augroup trishmd
	au!
	au filetype markdown call trish#setup#bufreadmd()
	autocmd BufWritePre	*.md call mkdir(expand("%:h"), 'p')
	autocmd BufNewFile	*.md lockmarks keepjumps call trish#setup#new_md()
	autocmd BufReadPost	*.md lockmarks keepjumps call trish#setup#new_md_if_needed()

	" When opening file, put cursor in last place it was when it was closed.
	" Lifted from the vim help manual
    autocmd BufReadPost *.md
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif

	augroup END


	set tagfunc=trish#tag#tagfunc
	set tagcase=ignore

	set completefunc=trish#tag#complete
	let g:SuperTabDefaultCompletionType = '<c-x><c-u>'

	call trish#aliases#load()
	call trish#backlinks#updatecache()
endfunction
