execute if data storage mcfunky:core {startup:1} run function mcfunky:exec2 {\
    c1:"data modify storage mcfunky:core startup set value 0",\
    c2:"data modify storage test-project:io state set value 0"}

execute if data storage test-project:io {state:0} run say out|Hello, I am a \
    Minecraft program.
execute if data storage test-project:io {state:0} run say outl| A new \
    sentence with a new line!
execute if data storage test-project:io {state:0} run say err|This going to \
    stderr.
execute if data storage test-project:io {state:0} run say errl| And a new line.
execute if data storage test-project:io {state:0} run say outb|33
execute if data storage test-project:io {state:0} run say outb|33
execute if data storage test-project:io {state:0} run say outb|33
execute if data storage test-project:io {state:0} run say outl|
execute if data storage test-project:io {state:0} run say errb|64
execute if data storage test-project:io {state:0} run say errb|64
execute if data storage test-project:io {state:0} run say errb|64
execute if data storage test-project:io {state:0} run say errl|
execute if data storage test-project:io {state:0} run say out|Now gimme a line!
execute if data storage test-project:io {state:0} run say inl
execute if data storage test-project:io {state:0} run data modify storage \
    mcfunky:io line_read_exec set value {c1:"function mcfunky:exec2 {c1:'data \
    modify storage test-project:io state set value 1',c2:'function test-\
    project:io'}"}
execute if data storage test-project:io {state:0} run function mcfunky:wait_\
    for_line
execute if data storage test-project:io {state:1} run data modify storage \
    test-project:io out set value {}
execute if data storage test-project:io {state:1} run data modify storage \
    test-project:io out.s2 set from storage mcfunky:io line_read_saved
execute if data storage test-project:io {state:1} run data modify storage \
    test-project:io out.s1 set value "outl|"
execute if data storage test-project:io {state:1} run function mcfunky:say2 \
    with storage test-project:io out
execute if data storage test-project:io {state:1} run say outl|
execute if data storage test-project:io {state:1} run say out|Now gimme a byte:
execute if data storage test-project:io {state:1} run say outb|32
execute if data storage test-project:io {state:1} run say inb
execute if data storage test-project:io {state:1} run data modify storage \
    mcfunky:io byte_read_exec set value {c1:"function mcfunky:exec2 {c1:'data \
    modify storage test-project:io state set value 2',c2:'function test-\
    project:io'}"}
execute if data storage test-project:io {state:1} run function mcfunky:\
    wait_for_byte
execute if data storage test-project:io {state:2} run data modify storage \
    test-project:io out.s2 set from storage mcfunky:io byte_read_saved
execute if data storage test-project:io {state:2} run data modify storage \
    test-project:io out.s1 set value "outl|"
execute if data storage test-project:io {state:2} run function mcfunky:say2 \
    with storage test-project:io out
execute if data storage test-project:io {state:2} run say outl|
execute if data storage test-project:io {state:2} run say outl|Thank you!
execute if data storage test-project:io {state:2} run say exit