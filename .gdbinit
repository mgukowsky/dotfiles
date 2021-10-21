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

# # TUI styling
# set style tui-active-border foreground green
# set style tui-active-border background black

# set style tui-border foreground green
# set style tui-border background none

# set tui compact-source on
# set tui tab-width 2

# # Turn on TUI
# tui enable
