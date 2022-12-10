
let s:last_updated_highlight_tag = ''
let s:last_updated_tags_time = 0

function s:preview_filename_if_under_cursor()
	  let l:word = trim(expand('<cWORD>'), '=')
	  if l:word =~ '^[a-z0-9 /-]*.md:[0-9]*:'
		  let l:args = split(l:word, ':')
		  let l:file = l:args[0]
		  let l:lnum = l:args[1]
		  exe ":topleft pedit +" . l:lnum . " " . l:file
	  endif
endfunction

function trish#preview#update()
  let l:highlight_tag = trish#tag#get_tag_before_or_under_cursor()
  let l:now = localtime()
  let l:is_preview=&previewwindow
  let g:ln = line('.') . 'q'

  if l:highlight_tag == ''
	  call s:preview_filename_if_under_cursor()
	  return
  endif

  let l:highlight_tag = trish#aliases#apply_if_needed(l:highlight_tag)

  let l:highlight_tag = substitute(l:highlight_tag, '^#','','')
  if s:last_updated_highlight_tag == l:highlight_tag && s:last_updated_tags_time + 360 > l:now
    return 
  endif

  let s:last_updated_highlight_tag = l:highlight_tag
  let s:last_updated_tags_time = localtime()

  let l:view=winsaveview()
  let l:winnr = win_getid()
  if len(l:highlight_tag) >= 3
	  if !l:is_preview 
		  let l:file=fnameescape(l:highlight_tag . ".md")
		  silent exe ":topleft pedit " . fnameescape(l:highlight_tag . ".md")
	  endif
  endif

  call win_gotoid(l:winnr)
  exe "wincmd ="
  call winrestview(l:view)
  let g:ln .= ',' . line('.')
endfun

