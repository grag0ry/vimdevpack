let g:OmniSharp_start_server = 0

if g:OS == 'linux' || $VIM_OMNI_NET6
    let g:OmniSharp_server_use_net6 = 1
    let g:OmniSharp_server_path = g:JoinPath(g:PackCachePath, 'omnisharp', 'net6', 'OmniSharp')
elseif g:OS == 'wsl' || g:OS == 'cygwin'
"    let g:OmniSharp_translate_cygwin_wsl = 1
"    let g:OmniSharp_server_path = g:JoinPath(g:PackCachePath, 'omnisharp', 'wsl', 'OmniSharp.exe')
    let g:OmniSharp_server_use_net6 = 1
    let g:OmniSharp_server_path = g:JoinPath(g:PackCachePath, 'omnisharp', 'net6', 'OmniSharp')
endif

let g:OmniSharp_selector_ui = 'ctrlp'
let g:syntastic_cs_checkers = ['code_checker']
let g:OmniSharp_highlight_groups = {
    \ 'Comment'               : 'Normal',
    \ 'ExcludedCode'          : 'Normal',
    \ 'Identifier'            : 'Normal',
    \ 'Keyword'               : 'Normal',
    \ 'ControlKeyword'        : 'Normal',
    \ 'NumericLiteral'        : 'Normal',
    \ 'Operator'              : 'Normal',
    \ 'OperatorOverloaded'    : 'Normal',
    \ 'PreprocessorKeyword'   : 'Normal',
    \ 'StringLiteral'         : 'Normal',
    \ 'WhiteSpace'            : 'Normal',
    \ 'Text'                  : 'Normal',
    \ 'StaticSymbol'          : 'Normal',
    \ 'PreprocessorText'      : 'Normal',
    \ 'Punctuation'           : 'Normal',
    \ 'VerbatimStringLiteral' : 'Normal',
    \ 'StringEscapeCharacter' : 'Normal',
    \ 'ClassName'             : 'Type',
    \ 'DelegateName'          : 'Normal',
    \ 'EnumName'              : 'Type',
    \ 'InterfaceName'         : 'Normal',
    \ 'ModuleName'            : 'cppSTLnamespace',
    \ 'StructName'            : 'Type',
    \ 'TypeParameterName'     : 'Normal',
    \ 'FieldName'             : 'PreProc',
    \ 'EnumMemberName'        : 'Constant',
    \ 'ConstantName'          : 'Constant',
    \ 'LocalName'             : 'Normal',
\ 'ParameterName'         : 'Float',
    \ 'MethodName'            : 'Function',
    \ 'ExtensionMethodName'   : 'Function',
    \ 'PropertyName'          : 'PreProc',
    \ 'EventName'             : 'Type',
    \ 'NamespaceName'         : 'cppSTLnamespace',
    \ 'LabelName'             : 'Type',
    \ 'XmlDocCommentAttributeName'         : 'Normal',
    \ 'XmlDocCommentAttributeQuotes'       : 'Normal',
    \ 'XmlDocCommentAttributeValue'        : 'Normal',
    \ 'XmlDocCommentCDataSection'          : 'Normal',
    \ 'XmlDocCommentComment'               : 'Normal',
    \ 'XmlDocCommentDelimiter'             : 'Normal',
    \ 'XmlDocCommentEntityReference'       : 'Normal',
    \ 'XmlDocCommentName'                  : 'Normal',
    \ 'XmlDocCommentProcessingInstruction' : 'Normal',
    \ 'XmlDocCommentText'                  : 'Normal',
    \ 'XmlLiteralAttributeName'            : 'Normal',
    \ 'XmlLiteralAttributeQuotes'          : 'Normal',
    \ 'XmlLiteralAttributeValue'           : 'Normal',
    \ 'XmlLiteralCDataSection'             : 'Normal',
    \ 'XmlLiteralComment'                  : 'Normal',
    \ 'XmlLiteralDelimiter'                : 'Normal',
    \ 'XmlLiteralEmbeddedExpression'       : 'Normal',
    \ 'XmlLiteralEntityReference'          : 'Normal',
    \ 'XmlLiteralName'                     : 'Normal',
    \ 'XmlLiteralProcessingInstruction'    : 'Normal',
    \ 'XmlLiteralText'                     : 'Normal',
    \ 'RegexComment'              : 'Normal',
    \ 'RegexCharacterClass'       : 'Normal',
    \ 'RegexAnchor'               : 'Normal',
    \ 'RegexQuantifier'           : 'Normal',
    \ 'RegexGrouping'             : 'Normal',
    \ 'RegexAlternation'          : 'Normal',
    \ 'RegexText'                 : 'Normal',
    \ 'RegexSelfEscapedCharacter' : 'Normal',
    \ 'RegexOtherEscape'          : 'Normal',
\ }
