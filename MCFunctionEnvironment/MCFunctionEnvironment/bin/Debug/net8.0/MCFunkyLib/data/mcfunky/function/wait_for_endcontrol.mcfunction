execute unless data storage mcfunky:core {endcontrol:1} run \
    schedule function mcfunky:wait_for_endcontrol 1t
execute if data storage mcfunky:core {endcontrol:1} run \
    function mcfunky:exec2 {\
        c1:"data modify storage mcfunky:core endcontrol set value 0",\
        c2:"function mcfunky:exec1 with storage mcfunky:core endcontrol_wait_exec"}