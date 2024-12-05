data modify storage mcfunky:string to_concat set value ["hello ","world! ","\"\"", "double, ","''single \\backslash"]
data modify storage mcfunky:string when_concat_finished set value {c1:"function mcfunky:exec4 {\
    c1:'data modify storage test-project:concat_test strings set value {s1:\"outl|\"}',\
    c2:'data modify storage test-project:concat_test strings.s2 set from storage mcfunky:string concat_result',\
    c3:'function mcfunky:say2 with storage test-project:concat_test strings',\
    c4:'say exit'}"}
function mcfunky:concat_full