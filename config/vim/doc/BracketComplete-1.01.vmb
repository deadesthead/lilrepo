" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
autoload/BracketComplete.vim	[[[1
62
" BracketComplete.vim: Insert mode completion for text inside various brackets.
"
" DEPENDENCIES:
"   - MotionComplete.vim autoload script
"
" Copyright: (C) 2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.001	02-Oct-2012	file creation
let s:save_cpo = &cpo
set cpo&vim

let s:openBrackets  = join(keys(g:BracketComplete_BracketConfig), '')
let s:bracketPattern = printf('[%s][^%s]*\%%#', s:openBrackets, s:openBrackets)
function! BracketComplete#Expr()
    let l:bracketCol = searchpos(s:bracketPattern, 'bnW', line('.'))[1]
    if l:bracketCol == 0
	return "\<C-\>\<C-o>\<Esc>" | " Beep.
    endif

    let l:openBracket = matchstr(getline('.'), '.', l:bracketCol - 1)
    let l:closeBracket = g:BracketComplete_BracketConfig[l:openBracket].opposite
    let l:hasCloseBracket = (search('\%#\_s*\V' . l:closeBracket, 'cnW') != 0)

    let l:textObject = get(g:BracketComplete_BracketConfig[l:openBracket], 'textobject', '')
    if empty(l:textObject)
	" There's no text object for this type of bracket. Always include the
	" opening bracket, and (multi-line-)search for the closing bracket.
	let l:startCol = l:bracketCol
	let l:motion = printf('/%s/%s',
	\   g:BracketComplete_BracketConfig[l:openBracket].opposite,
	\   (l:hasCloseBracket ? '' : 'e')
	\)
    else
	" Use the inner text object when we're just filling in text between
	" existing brackets; otherwise, include the closing bracket in the
	" match.
	let [l:startCol, l:innerOuter] = (l:hasCloseBracket ?
	\   [l:bracketCol + len(l:openBracket), 'i'] :
	\   [l:bracketCol, 'a']
	\)
	let l:motion = l:innerOuter . l:textObject

	if l:textObject ==# 't' && ! l:hasCloseBracket
	    " Special case: For the outer "a tag block" text object, detected by
	    " a ">" opening bracket, we must include the full start tag.
	    let l:startCol = searchpos('<[^<]\+>[^>]*\%#', 'bnW', line('.'))[1]
	    if l:startCol == 0
		return "\<C-\>\<C-o>\<Esc>" | " Beep.
	    endif
	endif
    endif
"****D echomsg '****' string(l:openBracket) string(l:closeBracket) l:hasCloseBracket string(l:motion)
    return MotionComplete#Expr(l:motion, [l:startCol, col('.')])
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
plugin/BracketComplete.vim	[[[1
47
" BracketComplete.vim: Insert mode completion for text inside various brackets.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - BracketComplete.vim autoload script
"
" Copyright: (C) 2012-2013 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.01.002	14-Jan-2013	CHG: Change default mapping to the more
"				intuitive i_CTRL-X_%.
"   1.00.001	02-Oct-2012	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_BracketComplete') || (v:version < 700)
    finish
endif
let g:loaded_BracketComplete = 1
let s:save_cpo = &cpo
set cpo&vim

"- configuration ---------------------------------------------------------------

if ! exists('g:BracketComplete_BracketConfig')
    let g:BracketComplete_BracketConfig = {
    \   '[': {'opposite': ']', 'textobject': '['},
    \   '(': {'opposite': ')', 'textobject': '('},
    \   '{': {'opposite': '}', 'textobject': '{'},
    \   '<': {'opposite': '>', 'textobject': '<'},
    \   '>': {'opposite': '<', 'textobject': 't'}
    \}
endif


"- mappings --------------------------------------------------------------------

inoremap <script> <expr> <Plug>(BracketComplete) BracketComplete#Expr()
if ! hasmapto('<Plug>(BracketComplete)', 'i')
    imap <C-x>% <Plug>(BracketComplete)
endif

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
doc/BracketComplete.txt	[[[1
112
*BracketComplete.txt*   Insert mode completion for text inside various brackets.

		      BRACKET COMPLETE    by Ingo Karkat
							 *BracketComplete.vim*
description			|BracketComplete-description|
usage				|BracketComplete-usage|
installation			|BracketComplete-installation|
configuration			|BracketComplete-configuration|
limitations			|BracketComplete-limitations|
known problems			|BracketComplete-known-problems|
todo				|BracketComplete-todo|
history				|BracketComplete-history|

==============================================================================
DESCRIPTION					 *BracketComplete-description*

Frequently, text inside parentheses, be it a warning "(don't do this)" or
function arguments "(foo, bar, 42)" is repeated. This also applies to other
bracket delimiters, e.g. HTML tags "<img src='banner.jpg' alt=''>" or arrays
"[1, 2, 3]".
This plugin provides a completion mapping that, when you realize you're typing
the same contents of a bracket-delimited text again, completes the entire text
inside the brackets from other matches in the buffer. The completion base
always contains the entire text between the cursor and the previous opening
bracket, so it doesn't matter how far you've already been into retyping this.

SEE ALSO								     *

- Check out the |CompleteHelper.vim| plugin page (vimscript #3914) for a full
  list of insert mode completions powered by it.

==============================================================================
USAGE						       *BracketComplete-usage*

In insert mode, invoke the completion via CTRL-X %.
You can then search forward and backward via CTRL-N / CTRL-P, as usual.

								  *i_CTRL-X_%*
CTRL-X %		Find matches for the text before the cursor, up to the
			previous bracket ( [ { < on the current line, and
			offer matches of the entire text inside the brackets,
			like the |i(| |i[| |i{| |i<| text objects.
			This also works for |tag-blocks| with the |it| text
			object; "<b>f|" will complete to "<b>foo bar</b>".

==============================================================================
INSTALLATION					*BracketComplete-installation*

This script is packaged as a |vimball|. If you have the "gunzip" decompressor
in your PATH, simply edit the *.vmb.gz package in Vim; otherwise, decompress
the archive first, e.g. using WinZip. Inside Vim, install by sourcing the
vimball or via the |:UseVimball| command. >
    vim BracketComplete*.vmb.gz
    :so %
To uninstall, use the |:RmVimball| command.

DEPENDENCIES					*BracketComplete-dependencies*

- Requires Vim 7.0 or higher.
- Requires the |MotionComplete.vim| plugin (vimscript #4265).

==============================================================================
CONFIGURATION				       *BracketComplete-configuration*

The general |MotionComplete-configuration| applies here, too.

For a permanent configuration, put the following commands into your |vimrc|:

					     *g:BracketComplete_BracketConfig*
The recognized bracket types are defined via a Dictionary. Its keys are the
opening brackets, which are mapped to an object that must have an "opposite"
attribute that specifies the closing bracket. If there's a text object, it can
be specified via the "textobject" attribute (without the preceding "a" / "i");
otherwise, a search to the closing bracket is used to retrieve the text.
To add an imaginary bracketing from : to ;, use: >
    runtime plugin/BracketComplete.vim	" Define the default brackets first.
    let g:BracketComplete_BracketConfig[':'] = {'opposite': ';'}
<
						       *BracketComplete-remap*
If you want to use different mapping, map your keys to the
<Plug>(BracketComplete...) mapping target _before_ sourcing the script
(e.g. in your |vimrc|): >
    imap <C-x>% <Plug>(BracketComplete)
<
==============================================================================
LIMITATIONS					 *BracketComplete-limitations*

KNOWN PROBLEMS				      *BracketComplete-known-problems*

TODO							*BracketComplete-todo*

IDEAS						       *BracketComplete-ideas*

==============================================================================
HISTORY						     *BracketComplete-history*

1.01	14-Jan-2013
CHG: Change default mapping to the more intuitive i_CTRL-X_%.

1.00	12-Oct-2012
First published version.

0.01	02-Oct-2012
Started development.

==============================================================================
Copyright: (C) 2012-2013 Ingo Karkat
The VIM LICENSE applies to this script; see |copyright|.

Maintainer:	Ingo Karkat <ingo@karkat.de>
==============================================================================
 vim:tw=78:ts=8:ft=help:norl:
