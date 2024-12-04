execute unless data storage mcfunky:io line_read run schedule function mcfunky:wait_for_line 1t
execute if data storage mcfunky:io line_read run data modify storage mcfunky:io line_read_saved set from storage mcfunky:io line_read
execute if data storage mcfunky:io line_read run function mcfunky:exec1 with storage mcfunky:io line_read_exec
execute if data storage mcfunky:io line_read run data remove storage mcfunky:io line_read