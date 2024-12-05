#say outl|mcfunky:repeat called
$data modify storage mcfunky:flow repeat_exec_$(v) set value {c1:"$(c)"}
$scoreboard players set #Repeat.Counter.$(v) MCFunky.Vars $(n)
$function mcfunky:repeat_internal1 {v:"$(v)"}
$data remove storage mcfunky:flow repeat_exec_$(v)
$scoreboard players reset #Repeat.Counter.$(v) MCFunky.Vars