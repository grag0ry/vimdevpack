if !exists("g:AutoDelExtraWhitespace")
    let g:AutoDelExtraWhitespace = 1
endif

if g:AutoDelExtraWhitespace == 1
    autocmd BufWritePre * :DelExtraWhitespace
endif
