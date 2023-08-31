# Inspired in part by https://interrupt.memfault.com/blog/advanced-gdb
# Remember commands between sessions
set history save on
set history size 10000
set history filename ~/.cache/.gdb_history
set history remove-duplicates 100

# Show 20 lines by default
set listsize 20

# When hitting a breakpoint, show disassembly if source is unavailable
set disassemble-next-line auto

set disassembly-flavor intel

set backtrace past-entry on
set backtrace past-main on

set debuginfod enabled on

# Turn on GEF; assumes that the script has been appropriately symlinked
source ~/.local/bin/gef.py
