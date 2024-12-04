forceload add 29999987 482035
execute unless loaded 29999987 -63 482035 run schedule function mcfunky:\
    concat_full 1t
execute if loaded 29999987 -63 482035 run function mcfunky:concat_full_1