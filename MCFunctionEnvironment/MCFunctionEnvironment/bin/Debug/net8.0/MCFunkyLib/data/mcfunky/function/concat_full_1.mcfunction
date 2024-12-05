fill 29999986 -63 482035 29999987 319 482035 minecraft:air
setblock 29999987 315 482035 minecraft:stone
summon minecraft:boat 29999987 316 482035 {UUID:[I;-484819734,114509258,\
    -1120772864,-149157018]}
setblock 29999987 314 482035 minecraft:command_block[conditional=false,\
    facing=west]{TrackOutput:1b,LastOutput:"",conditionMet:1b,UpdateLastExecution:0b}
setblock 29999986 314 482035 minecraft:chain_command_block[conditional=false,\
    facing=west]{auto:1b,conditionMet:1b,UpdateLastExecution:0b,Command:'\
    function mcfunky:exec10 {c1:"data modify storage mcfunky:string enchant_\
    text set string block 29999987 314 482035 LastOutput 106 -21",c2:"data \
    modify storage mcfunky:string to_unescape set value {}",c3:"data modify \
    storage mcfunky:string to_unescape.s1 set from storage mcfunky:string \
    enchant_text",c4:"function mcfunky:unescape with storage mcfunky:string \
    to_unescape",c5:"data modify storage mcfunky:string concat_result set \
    from storage mcfunky:string unescape_result",c6:"\
    kill e31a3cea-06d3-45ca-bd32-5d00f71c0b66",c7:"data remove storage \
    mcfunky:string enchant_text",c8:"data remove storage mcfunky:string to_\
    unescape",c9:"data remove storage mcfunky:string unescape_result",c10:"\
    function mcfunky:exec1 with storage mcfunky:string when_concat_finished"}'}
setblock 29999987 311 482035 minecraft:stone
setblock 29999987 312 482035 minecraft:oak_sign
data modify block 29999987 312 482035 front_text.messages[0] set value \
    '{"nbt":"to_concat[]","storage":"mcfunky:string","interpret":false,"separator":""}'
data modify entity e31a3cea-06d3-45ca-bd32-5d00f71c0b66 CustomName set from \
    block 29999987 312 482035 front_text.messages[0]
data modify block 29999987 314 482035 Command set value "enchant \
    e31a3cea-06d3-45ca-bd32-5d00f71c0b66 minecraft:aqua_affinity"
setblock 29999988 314 482035 minecraft:redstone_block
setblock 29999988 314 482035 minecraft:air
