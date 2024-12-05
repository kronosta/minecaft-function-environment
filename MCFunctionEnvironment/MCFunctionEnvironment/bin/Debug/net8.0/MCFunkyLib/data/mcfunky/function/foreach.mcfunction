$data modify storage mcfunky:flow foreach_array_$(v) set from $(a)
$data modify storage mcfunky:flow foreach_exec_$(v) set value {\
    c1:"data modify $(d) set from storage mcfunky:flow foreach_array_$(v)[0]",\
    c2:"data remove storage mcfunky:flow foreach_array_$(v)[0]",\
    c3:"$(c)"}
$data modify storage mcfunky:flow foreach_repeatargs_$(v) set value \
    {v:"XXForEach0$(v)",c:"function mcfunky:exec3 with storage mcfunky:flow foreach_exec_$(v)"}
$execute store result storage mcfunky:flow foreach_repeatargs_$(v).n int 1.0 \
    run data get storage mcfunky:flow foreach_array_$(v)
$function mcfunky:repeat with storage mcfunky:flow foreach_repeatargs_$(v)
$data remove storage mcfunky:flow foreach_array_$(v)
$data remove storage mcfunky:flow foreach_exec_$(v)
$data remove storage mcfunky:flow foreach_repeatargs_$(v)