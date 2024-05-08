if exists("b:current_syntax")
    finish
endif

syn case match

syn keyword slnKeyword Project EndProject Global EndGlobal
syn keyword slnSection GlobalSection EndGlobalSection ProjectSection EndProjectSection
syn keyword slnStorage preProject postProject preSolution postSolution

syn match slnConfiguration /\(Debug\|Release\)[[:alnum:]-]*|\(Any CPU\|\(amd64\|Win32\|x64\|arm\|ppc\)[[:alnum:]-]*\)/

syn match slnGUID /{[0-9A-Fa-f]\{8\}-[0-9A-Fa-f]\{4\}-[0-9A-Fa-f]\{4\}-[0-9A-Fa-f]\{4\}-[0-9A-Fa-f]\{12\}}/
syn region slnString start='"' end='"' contains=slnGUID
syn match slnNumber /\d\+\(\.\d\+\)*/

syn match slnHeader /Microsoft Visual Studio Solution File, Format Version [0-9.]\+/ contains=slnNumber
syn match slnHeader /# Visual Studio Version [0-9.]\+/ contains=slnNumber
syn keyword slnHeaderVariable VisualStudioVersion MinimumVisualStudioVersion

highlight link slnHeader  Special
highlight link slnHeaderVariable  Special
highlight link slnKeyword Keyword
highlight link slnSection Function
highlight link slnString  String
highlight link slnNumber  Number
highlight link slnStorage StorageClass
highlight link slnGUID    Type
highlight link slnConfiguration Constant
