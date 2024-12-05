say outl|Start!
function mcfunky:repeat {n:5,v:"MainLoop",c:\
    "function mcfunky:exec4 {\
        c1:'data modify storage test-project:repeat outstrings set value {s1:\\\"outl|Repeat Loop #\\\"}',\
        c2:'execute store result storage test-project:repeat counter int 1.0 run scoreboard \
            players get #Repeat.Counter.MainLoop MCFunky.Vars',\
        c3:'data modify storage test-project:repeat outstrings.s2 set string storage \
            test-project:repeat counter',\
        c4:'function mcfunky:say2 with storage test-project:repeat outstrings'}"}
say outl|End!
say exit