say outl|Start!
data modify storage test-project:foreach arr set value \
    ["apple","orange","banana","kiwi","blueberry","grapes"]
function mcfunky:foreach {\
    a:"storage test-project:foreach arr",\
    d:"storage test-project:foreach elem",\
    v:"MainLoop",\
    c:"function mcfunky:exec3 {\
        c1:'data modify storage test-project:foreach outstrings set value \
            {s1:\\\"outl|Element: \\\"}',\
        c2:'data modify storage test-project:foreach outstrings.s2 set \
            from storage test-project:foreach elem',\
        c3:'function mcfunky:say2 with storage test-project:foreach outstrings'}"}
say outl|End!
say exit