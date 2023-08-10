
function Assert(x, str)
	if !a:x 
		throw a:str
	endif
endfunction

function Assert_regex(x, reg, str)
	call Assert(a:x =~ a:reg, a:str . ". " . a:x . " should =~ " . a:reg)
endfunction

function trish#fulltest#run() abort
	let l:dir = tempname()
	call mkdir(l:dir)
	exe "TrishSetup " . l:dir
	call mkdir('templates')
	e templates/daily.md
	normal oFOO
	normal \t
	call Assert_regex(expand("%"), 'daily/\d\d\d\d-\d\d-\d\d.md', "\\t didn't open right file")
	call Assert(searchpos('FOO')[0] != 0, "Template didn't work")
	exe "normal obarbaz#music/wilco "
	wincmd P
	call Assert_regex(expand("%"), 'music/wilco.md', "Preview window didn't open right")
	wincmd w
	exe "normal o#music/wilco/yankee-hotel-foxtrot"
	exe "normal \<CR>"
	exe "normal \<c-w>PoA nice album, released September 18th, 2001"
	exe "normal \<CR>\<c-w>w"
	exe "normal k$\<CR>"
	wincmd P
	call Assert(searchpos('barbaz')[0]!=0, "Backlinks work")
	call Assert(searchpos('Children\n#music/wilco/yankee-hotel-foxtrot')[0]!=0, "Children work")
	exe "normal j\<c-]>"
	"TODO: Add wait for jobs to finish
	call Assert_regex(expand("%"), 'music/wilco/yankee-hotel-foxtrot.md', "Jumping to tag didn't work")
endfunction
