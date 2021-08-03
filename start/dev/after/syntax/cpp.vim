syn match cppException /\(\<throw\>\s\+\(::\)\{,1}\(\w\+::\)*\)\@<=\w\+\(\s*[(;]\)\@=/
syn match cppAttribute /\[\[[a-zA-Z_0-9:()]\+\]\]/

