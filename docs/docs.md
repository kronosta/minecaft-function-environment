# Setup
MCFunctionEnvironment must be run in a folder containing these files:
- The executable, if any
- `MCFunctionEnvironment.dll`
- `MCFunctionEnvironment.deps.json`
- `MCFunctionEnvironment.pdb`
- `MCFunctionEnvironment.runtimeconfig.json`
- `base_pack.mcmeta` (the pack.mcmeta file automatically copied to the datapack
  folder for the directory provided with the -d option)
- The `MCFunkyLib` folder containing the standard library
- The `mc` folder, which you must provide yourself and must contain a working copy
  of some Minecraft server with the jar file named `minecraft_server.jar`.
  This jar file should be at least 1.20.2, but it can have various versions between them,
  and can also work with any modded version that keeps the console output the same.
  For example I think Fabric modloader might work, but I haven't tested that and I'm not
  100% sure if the console output is unaltered but I think it probably is fine.
  Also if not you can just modify the regexes to accept input differently.

Essentially, the way this works is that the Minecraft server is free, while the client isn't.
The server can run just fine without any players, though some mechanics such as random ticks
and some entity spawning requires a player to be nearby, so those won't happen, though
you can just achieve those effects with commands, like /summon-ing entities.

This environment gives the mcfunctions almost full access to Minecraft's features.
You get a full set of dimensions with all the blocks (and you can even put custom dimensions
in your datapack). The blocks all update like normal, redstone works, command blocks 
and structure blocks can be activated in various ways. 

However due to random ticking not happening, plants won't grow, ice won't melt,
snow won't cover the ground, etc. But these aren't super useful to mcfunctions anyway.

Also, currently the code has a custom server.properties file written in a string, this isn't currently
used and it will be the usual default instead.

# Command line usage
```
MCFunctionEnvironment -f<function> -d<dir> [-m<macroparams>] [-p]
    [-a<action>]

Options will not work if their parameters are in separate command line arguments.
So use -fmy-project:main, not -f my-project:main

<function>: namespaced ID of main function to run
<dir>: Directory of datapack's 'data' folder (the pack.mcmeta is generated automatically so you can't include it)
<macroparams>: Minecraft compound tag SNBT syntax for the macro parameters of <function>

This program generates a brand new world each time for a clean slate. The -p option adds a file
named '__KEEP' to the world which tells this program not to delete it on launch. This also might
speed up start times.

The -a flag adds a few special actions. -arun is how it normally behaves without the -a flag.
-areset deletes the world even if it is persistent.
-aresetrun deletes the world and then runs your program with a new world.
```

# Assorted behavior
- Before your program starts, in the storage `mcfunky:core`, `startup` is set to 1.
  You can use this for single-function programs by checking `startup` for value 1,
  then setting some state variable to its initial value, and then setting `startup` to 0.
  The state variable is necessary for single-function programs since a lot of essential functionality
  requires functions to run later, so with only one function it needs to know what to do separately
  on each section. The state might not be constantly incrementing, looping or conditionals could
  make this more complicated but it should always be possible to keep track by dividing
  on conditional and loop boundaries and reinvokations/waits. See the `test-project:io` function
  [here](MCFunctionEnvironment/MCFunctionEnvironment/bin/Debug/net8.0/test-project/test-project/function/io.mcfunction)
  for a basic example of this strategy.

# MCFunction external commands
One of the few ways an MCFunction can get arbitrary data outputted to the server console is the /say command,
which outputs it directly to the console with a bit of stuff before that. To allow the /say command to do multiple
things, the /say command does different actions depending on what you output. You'll only see the output using
certain actions, the others take input/exit the program/etc.

Each /say command has its output broken up into multiple segments separated by a vertical bar (`|`).
The first segment names the action and the rest are the arguments. Some actions, like the output commands,
treat all vertical bars apart from the first literally.

The actions are as follows:
- `out|[text]`
  - The text may contain vertical bars. This outputs the text to the wider MCFunctionEnvironment console.
- `outl|[text]`
  - Same as `out|[text]` but prints a newline afterwards. You can just write `say outl|` to print a newline alone.
- `outb|[byte]` where [byte] is a decimal number from 0-255
  - Prints [byte] as a literal byte to standard output. Useful for binary I/O. If [byte] is invalid it does nothing
- `err|[text]`, `errl|[text]`, and `errb|[byte]`
  - Like `out|[text]`, `outl|[text]`, and `outb|[byte]`, respectively, but print it to standard error instead of standard out.
- `inl`
  - Takes a line of input and puts it into the storage `mcfunky:io` in `line_read`. This will NOT be set immediately
    and your code WILL NOT stop running to wait for it. To deal with this, put a string in the storage `mcfunky:io` at
    `line_read_exec.c1` with a command you'd like to run when the line is received, then run the standard library 
    function `mcfunky:wait_for_line`. The result will be in `line_read_saved` rather than `line_read`, still in storage
    `mcfunky:io`. You still have to run `say inl` yourself before doing this.
    Also note you might want to run multiple commands when the line is received, you can use
    the standard library functions `mcfunky:exec[1-20]` for that. You also probably want to call an entire function
    of your own to get more than 20 commands, so use the Minecraft /function command.
- `inb`
  - Takes a single byte of input and puts it into the storage `mcfunky:io` in `byte_read`. This will NOT be set
    immediately and your code WILL NOT stop running to wait for it. To deal with this, put a string in the storage 
    `mcfunky:io` at `byte_read_exec.c1` with a command you'd like to run when the line is received, then run the 
    standard library function `mcfunky:wait_for_byte`. The result will be in `byte_read_saved` rather than `byte_read`, 
    still in storage `mcfunky:io`. You still have to run `say inb` yourself before doing this.
    Also note you might want to run multiple commands when the line is received, you can 
    use the standard library functions `mcfunky:exec[1-20]` for that. You also probably want to call an entire function
    of your own to get more than 20 commands, so use the Minecraft /function command.
- `exit`, `exit|[int]`
  - Exits the Minecraft server and the MCFunction environment. If an argument is given the exit code is the argument,
    otherwise the exit code is 0. If the argument is present and invalid the program will still exit but will show
    an error message and exit with code 2.

A lot of times you may want to do these with dynamic arguments which the /say command doesn't normally support.
However with function macros and string concatenation (see Standard library functions section) this can be done
fine, and you don't even need to define a dynamic say function since the standard library already provides 
`mcfunky:say1` and `mcfunky:say2`.

# Standard library functions
- `mcfunky:exec[1-20]`
  - Takes macro arguments `c[1-20]`, treats them as commands and executes them in sequence. Note that due to
    the limitation on NBT strings each individual command must not be longer than approximately 32,000 characters.
- `mcfunky:say1`
  - Takes a macro argument `s1` and runs the /say command on it.
- `mcfunky:say2`
  - Takes two macro arguments, `s1` and `s2`, and runs the /say command on their concatenation.
    This function is mainly meant for simple cases with one constant argument and one command.
    If you want more concatenation on output you'll have to use the concat functions and put the output
    into a storage, then run `mcfunky:say1` or `mcfunky:say2` with an NBT storage path.
- `mcfunky:wait_for_line`
  - Waits for an input line to appear in storage `mcfunky:io` at `line_read`, then places it into
    `line_read_saved` and executes the single command string in `mcfunky:io` at `line_read_exec`.
    Also deletes the contents of `line_read` so that the next call to this function works.
    This doesn't actually read the line, which means it's possible for something else, such as
    a command-block or scheduled function, to override the input as long as the user hasn't typed it in yet.
- `mcfunky:wait_for_byte`
  - Waits for a byte to appear in storage `mcfunky:io` at `byte_read`, then places it into
    `byte_read_saved` and executes the single command string in `mcfunky:io` at `byte_read_exec`.
    Also deletes the contents of `byte_read` so that the next call to this function works.
    This doesn't actually read the byte, which means it's possible for something else, such as
    a command-block or scheduled function, to override the input as long as the user hasn't typed it in yet.
- `mcfunky:unescape`
  - Takes in a macro parameter `s1` which should be a string, and unescapes double-quoted escapes such as `\"` and `\\`.
    Currently there is no such thing for single-quote escapes.
- `mcfunky:concat_full`
  - The first call to this might be slow since it has to load a chunk to do the concatenation in.
    The chunk will stay loaded though so subsequent calls will be fine.
    In storage `mcfunky:string` the array of strings `to_concat` will be concatenated in a way that
    any character should work fine. After the concatenation has finished (which will be one or more ticks
    in the future), the command string `when_concat_finished` in storage `mcfunky:string` will be
    executed. The concatenation result is accessible in storage `mcfunky:string` at `concat_result`.
    Because this function is so expensive, it is recommended that you use the other concatenation functions
    whenever possible, though they have some limitations on quotes and backslashes.
- `mcfunky:concat[2-20]d`
  - Takes in multiple macro parameters called `s[1-20]`, concatenates them except that double quotes
    and backslashes won't work.
- `mcfunky:concat[2-20]s`
  - Takes in multiple macro parameters called `s[1-20]`, concatenates them except that single quotes
    and backslashes won't work.
- `mcfunky:concat[2-20]d_sep`
  - Takes in multiple macro parameters called `s[1-20]`, concatenates them with double quotes between them,
    except that double quotes and backslashes won't work in the components.
- `mcfunky:concat[2-20]s_sep`
  - Takes in multiple macro parameters called `s[1-20]`, concatenates them with single quotes between them,
    except that single quotes and backslashes won't work in the components.