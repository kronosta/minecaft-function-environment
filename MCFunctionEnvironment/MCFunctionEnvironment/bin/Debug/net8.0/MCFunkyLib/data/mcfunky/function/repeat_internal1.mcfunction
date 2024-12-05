#say outl|mcfunky:repeat_internal1 called
$execute unless score #Repeat.Counter.$(v) MCFunky.Vars matches 0 \
    run function mcfunky:exec1 with storage mcfunky:flow repeat_exec_$(v)
$execute unless score #Repeat.Counter.$(v) MCFunky.Vars matches 0 \
    run scoreboard players remove #Repeat.Counter.$(v) MCFunky.Vars 1
$execute unless score #Repeat.Counter.$(v) MCFunky.Vars matches 0 \
    run function mcfunky:repeat_internal1 {v:"$(v)"}
#say control