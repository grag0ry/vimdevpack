@echo off
setlocal
set file_original=%~1
set file_modified=%~2
set file_base=%~3
set file_merged=%~4

set label_original=%~5
set label_modified=%~6
set label_base=%~7
set label_merged=%~8

start /wait "" "C:\Program Files\Neovim\bin\nvim-qt.exe" -- -c "wincmd J|buffer 2|setlocal ro nomodifiable buftype=nofile|file SOURCE|buffer 3|setlocal ro nomodifiable buftype=nofile|file TARGET|buffer 1|setlocal buftype=nofile|file $label_merged" -d "%file_base%" "%file_original%" "%file_modified%"

endlocal
