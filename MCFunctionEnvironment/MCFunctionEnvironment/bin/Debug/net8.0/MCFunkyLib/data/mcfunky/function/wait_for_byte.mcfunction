execute unless data storage mcfunky:io byte_read run schedule function mcfunky:wait_for_byte 1t
execute if data storage mcfunky:io byte_read run data modify storage mcfunky:io byte_read_saved set from storage mcfunky:io byte_read
execute if data storage mcfunky:io byte_read run function mcfunky:exec1 with storage mcfunky:io byte_read_exec
execute if data storage mcfunky:io byte_read run data remove storage mcfunky:io byte_read