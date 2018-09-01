fun! pymode#breakpoint#init() "{{{

    if !g:pymode_breakpoint
        return
    endif

    if g:pymode_breakpoint_cmd == ''
        let g:pymode_breakpoint_cmd = 'import pdb; pdb.set_trace()  # XXX BREAKPOINT'

        if g:pymode_python == 'disable'
            return
        endif

    endif

        PymodePython << EOF

def _find_spec(name):
    try:
        from importlib.util import find_spec
        if find_spec(name) is not None:
            return name
    except ImportError:
        try:
            from imp import find_module
            find_module(name)
            return name
        except ImportError:
            return None

for module in ('wdb', 'pudb', 'ipdb'):
	_mod = _find_spec(module)
	if _mod is not None:
		vim.command('let g:pymode_breakpoint_cmd = "import %s; %s.set_trace()  # XXX BREAKPOINT"' % (module, module))
		break

EOF

endfunction "}}}

fun! pymode#breakpoint#operate(lnum) "{{{
    let line = getline(a:lnum)
    if strridx(line, g:pymode_breakpoint_cmd) != -1
        normal dd
    else
        let plnum = prevnonblank(a:lnum)
        if &expandtab
            let indents = repeat(' ', indent(plnum))
        else
            let indents = repeat("\t", plnum / &shiftwidth)
        endif

        call append(line('.')-1, indents.g:pymode_breakpoint_cmd)
        normal k
    endif

    " Save file without any events
    call pymode#save()

endfunction "}}}
