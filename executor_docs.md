🎮

Console

These are all of the functions revolving the console that Wave supports.

Clear

Copy

<void> rconsoleclear(<void>)

Clears all text from the console.

Close

Copy

<void> rconsoleclose(<void>)

Closes the console.

Alternative: rconsoledestroy

Create

Copy

<void> rconsolecreate(<void>)

Creates a new console window for logging and interaction.

Debug

Copy

<void> rconsoledebug(<string text>)

Prints a debug message to the console in a distinct debug color/style.

Error

Copy

<void> rconsoleerr(<string> text)

Prints text into the console, with [ERROR] written before it.

Info

Copy

<void> rconsoleinfo(<string> text)

Prints text into the console, with [INFO] written before it.

Input

Copy

<string> rconsoleinput(<void>)

Yields the current thread until the user inputs text and presses Enter. Returns the input they put in.

Name

Copy

<void> rconsolename(<string> title)

Sets the console's title to title.

Alternative: rconsolesettitle

Print

Copy

<void> rconsoleprint(<string> text)

Prints text into the console.

Print Console

Copy

<void> printconsole(<string> message, <byte> red, <byte> green, <byte> blue)

Prints message into the internal and integrated console with RGB value.

Console Colors:

Name

Type

Black

@@BLACK@@

Blue

@@BLUE@@

Green

@@GREEN@@

Cyan

@@CYAN@@

Red

@@RED@@

Magenta

@@MAGENTA@@

Light Gray

@@LIGHT_GRAY@@

Dark Gray

@@DARK_GRAY@@

Light Blue

@@LIGHT_BLUE@@

Light Green

@@LIGHT_GREEN@@

Light Cyan

@@LIGHT_CYAN@@

Light Red

@@LIGHT_RED@@

Light Magenta

@@LIGHT_MAGENTA@@

Yellow

@@YELLOW@@

White

@@WHITE@@

Example:

Copy

rconsolename("console") -- Sets the name of the console to 'console'

rconsoleprint("gamer\n")

rconsoleprint("@@YELLOW@@") -- Changes the text color to Yellow

rconsoleprint("gamer but yellow\n")

rconsoleerr("omg error!")

rconsolewarn("omg warning!")

wait(3)

rconsoleclear() -- Clears all text

wait(1)

rconsoleclose() -- Closes the console

You must use \n at the end of rconsoleprint to make a new line.

rconsoleinfo, rconsolewarn, and rconsoleerr do this automatically.





💻Functions

🌎

Environment

These are all of the functions revolving the Roblox environment that Wave supports.

Add Spy Callback

Copy

<void> addspycallback(<function callback>)

Registers a callback that will be executed whenever a RemoteEvent or function is invoked, allowing you to inspect or log the call.

Create Secure Folder

Copy

<void> createsecurefolder(<string> path)

Creates a new secure folder to path.

Note: The folder itself won't be able to be found by the game. This means you don't need to set the security of the instances within it.

Alternative: create_secure_folder

Fire Click Detector

Copy

<void> fireclickdetector(<ClickDetector> ClickDetector, <number?> Distance = 0, <string?>)

Fires the ClickDetector. If no distance supplied, it will default to 0.

Fire Proximity Prompt

Copy

<void> fireproximityprompt(<ProximityPrompt> Prompt)

Fires the ProximityPrompt trigger.

Fire Touch Interest

Copy

<void> firetouchinterest(<BasePart> totouch, <BasePart> Part, <uint?> toggle)

Touches part with totouch.

Actions:

Action

Toggle

Begins the touch.

0

Ends the touch.

1

Get Instances

Copy

<table> getinstances(<void>)

Returns a table with instances.

Alternative: get_instances

Get Nil Instances

Copy

<table> getnilinstances(<void>)

Returns a table with instances parented to nil.

Alternative: get_nil_instances

Is Secured Instance

Copy

<void> issecuredinstance(<Instance> Instance)

Returns true/false if Instance is secured/not secured.

Alternative: is_secured_instance

Protect Instance

Copy

<void> protectinstance(<Instance obj>)

Marks obj as protected, preventing it from being tampered with or detected by certain internal checks.

Set Normal Instance

Copy

<table> setnormalinstance(<Instance> Instance)

Sets Instance back to its normal state. Returns false if Instance is back to normal.

Alternative: set_normal_instance

Set Simulation Radius

Copy

<void> setsimulationradius(<number radius>)

Sets the simulation radius for the local player, controlling how far physics and character updates are processed around the player.

Set Secure Instance

Copy

<table> setsecureinstance(<Instance> Instance)

Secures Instance. Returns false if Instance is secured.

Alternative: set_secure_instance



💻Functions

📂

File System

These are all of the functions revolving the file system that Wave supports.

Append File

Copy

<void> appendfile(<string> path, <string> content)

Appends content to the file contents at path.

Delete File

Copy

<void> delfile(<string> path)

Deletes the file located at path.

Alternative: deletefile

Delete Folder

Copy

<void> delfolder(<string> path)

Deletes the folder located at path.

Alternative: deletefolder

Get Custom Asset

Copy

<string> getcustomasset(<string> path)

Provides a content string suitable for use with GUI elements, sounds, meshes, and other assets to reference an item in the workspace folder.

Is File

Copy

<bool> isfile(<string> path)

Returns true if path is a file.

Is Folder

Copy

<bool> isfolder(<string> path)

Returns true if path is a folder.

List Files

Copy

<table> listfiles(<string> folder)

Returns a table of all files in folder.

Load File

Copy

<function> loadfile(<string> path)

Loads the contents of the file located at path as a Lua function and returns it.

Make Folder

Copy

<void> makefolder(<string> path)

Creates a new folder at path.

Read File

Copy

<string> readfile(<string> path)

Returns the contents of the file located at path.

Write Custom Asset

Copy

<string> writecustomasset(<string filename>, <string data>)

Creates a custom asset file that can be loaded into Roblox, writing the given data into the specified filename.

Write File

Copy

<void> writefile(<string> path, <string> content)

Writes content to the supplied path.

Previous

EnvironmentNext

HookingLast updated 2 months ago



🪝

Hooking

These are all of the functions revolving hooking that Wave supports.

Clone Function

Copy

<function> clonefunction(<function> a1)

Clones function a1.

Alternative: clonefunc

Get Callback Value

Copy

<any> getcallbackvalue(<function fn>)

Retrieves the current value or reference of fn that has been set or hooked.

Hook Function

Copy

<function> hookfunction(<function> old, <function> new)

Hooks function old, replacing it with the function new. The old function is returned, you must use this function in order to call the original function.

Alternative: replaceclosure, hookfunc, replacefunction, replacefunc, detourfunction, replaceclosure, detour_function

Hook Metamethod

Copy

<function> hookmetamethod(<Object> object, <string> metamethod, <function> a1)

Hooks the metamethod passed in object's metatable with a1.

Is Hooked

Copy

<bool> ishooked(<function fn>)

Checks if fn has been hooked (i.e., replaced or wrapped by a hook).

Alternative: isfunctionhooked

Is Our Call Stack

Copy

<bool> isourcallstack(<int level>)

Checks the entire callstack to see if it is from Wave or Roblox.

New C Closure

Copy

<function> newcclosure(<function> a1)

Pushes a new C Closure that invokes the function a1 upon call.

New Lua Closure

Copy

<function> newlclosure(<function fn>)

Pushes a new L Closure that invokes the function fn upon call.

Protect Closure

Copy

<void> protectclosure(<function fn>)

Prevents fn from being hooked or modified by external code.

Alternative: protectfunction

Restore Closure

Copy

<void> restoreclosure(<function fn>)

Restores fn back to its original, unmodified closure.

Alternative: restorefunction, restorefunc

Previous

File SystemNext

InputLast updated 22 days ago

💻Functions

🖱️

Input

These are all of the functions revolving inputs that Wave supports.

Is Roblox Active

Copy

<bool> isrbxactive(<void>)

Returns true if the game window is in focus.

Keyboard

Copy

<void> keydown(<uint> keycode)

Simulates a key press for the specified keycode. You can find a list of codes here.

Alternative: keypress

Copy

<void> keytap(<int keycode>)

Simulates a single press and release of the specified keycode.

Copy

<void> keyup(<uint> key)

Releases key on the keyboard.

Alternative: keyrelease

Left Click

Copy

<void> mouse1click(<void>)

Simulates a full left mouse button press.

Copy

<void> mouse1press(<void>)

Simulates a left mouse button press without releasing it.

Copy

<void> mouse1release(<void>)

Simulates a left mouse button release.

Mouse Movement

Copy

<void> mousescroll(<number> number)

Scrolls the mouse wheel virtually by number pixels.

Copy

<void> mousemoverel(<number> a1, <number> a2)

Moves the mouse cursor relatively to the current mouse position by coordinates a1 and a2.

Copy

<void> mousemoveabs(<number> a1, <number> a2)

Move's your mouse to the a1 and a2 coordinates in pixels from top left of the window.

Right Click

Copy

<void> mouse2click(<void>)

Simulates a full right mouse button press.

Copy

<void> mouse2press(<void>)

Clicks down on the right mouse button.

Copy

<void> mouse2release(<void>)

Simulates a right mouse button release.

Previous

HookingNext

MiscellaneousLast updated 2 months ago





Introduction🌊

Getting Started💻

Functions



🎮

Console🌎

Environment📂

File System🪝

Hooking🖱️

Input💡

Miscellaneous📳

Network🪞

Reflection🕹️

Script📶

Signal📊

Table📚

Libraries



👨‍🎤

Actors🗃️

Cache👾

Crypt🐞

Debug🖍️

Drawing📎

WebSocket✏️

Changelogs📃

Credits

Powered by GitBook

Clear Teleport Queue

Decompile

Get Clipboard

Get Fast Flag

Get FPS Cap

Get Hidden UI

Get HWID

Get Namecall Method

Get Objects

Get Thread Identity

Http Get

Identify Executor

Is Scriptable

Save Instance

Set Clipboard

Set Fast Flag

Set FPS Cap

Set Namecall Method

Set Roblox Clipboard

Set Thread Identity

Message Box

Queue On Teleport

Request

ZSTD Compress

ZSTD Decompress

Copy

💻Functions

💡

Miscellaneous

These are uncategorized/miscellaneous functions Wave supports.

Clear Teleport Queue

Copy

<void> clearteleportqueue(<void>)

Clears all queued teleport requests for the local player.

Alternative: clear_teleport_queue

Decompile

Copy

<string> decompile(<Instance> Script)

Decompiles Script and returns the decompiled output.



WARNING: decompile() is a Premium only function.

Example:

Copy

local LocalPlayer = game:GetService("Players").LocalPlayer

local PlayerModule = LocalPlayer.PlayerScripts.PlayerModule

local Decompiled = decompile(PlayerModule) -- Decompiles PlayerModule

setclipboard(Decompiled) -- Copies the decompiled output to your clipboard

Get Clipboard

Copy

<void> getclipboard(<void>)

Gets the content from your clipboard.

Alternative: fromclipboard

Get Fast Flag

Copy

<bool> getfflag(<string flagName>)

Returns the value of flagName.

Get FPS Cap

Copy

<void> getfpscap(<void>)

Gets your FPS in-game.

Get Hidden UI

Copy

<Instance> gethui(<void>)

Returns the CoreGui service, allowing GUI's being hidden from detection in-game.

Get HWID

Copy

<string> gethwid(<void>)

Gets the hardware ID (HWID) of the local system.

Alternative: get_hwid

Get Namecall Method

Copy

<string> getnamecallmethod(<void>)

Returns the namecall method if the function is called in an __namecall metatable hook.

Get Objects

Copy

<table> getobjects(<string assetIdOrUri>)

Loads instances from assetIdOrUri.

Get Thread Identity

Copy

<void> getthreadidentity(<value> number)

Returns the current thread's identification number.

Alternative: getidentity, getcontext, getthreadcontext, get_thread_context, get_thread_identity

Http Get

Copy

<string> httpget(<string url>)

Sends an HTTP GET request to url and returns the response body as a string.

Identify Executor

Copy

<string, string> identifyexecutor(<void>)

Returns Wave and the version if the current executor is Wave.

Alternative: getexecutorname

Is Scriptable

Copy

<bool> isscriptable(<Instance> object)

Checks if object can be scripted or modified by a script.



WARNING: saveinstance() is a Premium only function.

Save Instance

Copy

<void> saveinstance(<Instance?> Object, <string?> FilePath, <table?> Options)

Saves the current game into your workspace folder as a .RBXL file.

If Object is specified, it will save that object and its descendants as a .RBXM file.

If Object is game, it will be saved as a .RBXL file.

If FilePath is specified, it will write the file to the specified path.

FilePath does not need to contain a file extension, only the name of the file.

Options:

Name

Type

Default

Description

Decompile

Boolean

false

If enabled, LocalScripts and ModuleScripts will be decompiled.

DecompileTimeout

Number

10

If the decompilation run time exceeds this value, it will be canceled. This value is in seconds.

DecompileIgnore

Table

{"Chat", "CoreGui", "CorePackages"}

Scripts that are a descendant of the specified services will be saved but not decompiled.

NilInstances

Boolean

false

If enabled, instances parented to nil will be saved.

RemovePlayerCharacters

Boolean

true

If enabled, player characters will not be saved.

SavePlayers

Boolean

false

If enabled, Player objects and their descendants will be saved.

MaxThreads

Number

3

The number of decompilation threads that can run at once. More threads allow for more scripts to be decompiled at the same time.

ShowStatus

Boolean

true

If enabled, Save Instance progress will be displayed.

IgnoreDefaultProps

Boolean

true

If enabled, default properties will not be saved.

IsolateStarterPlayer

Boolean

true

If enabled, StarterPlayer will be cleared and the saved starter player will be placed into folders.

Example - Saving the game to a custom folder:

Copy

makefolder("MySaves")

saveinstance(game, "MySaves/Cool Game")

Example - Saving a specific object with decompiled scripts:

Copy

saveinstance(workspace.CoolModel, "Cool Model", {

Decompile = true

})

Set Clipboard

Copy

<void> setclipboard(<string> content)

Sets content to the clipboard.

Alternative: toclipboaard

Set Fast Flag

Copy

<void> setfflag(<string> flag, <string> value)

Sets flag's value to value.

You can find a list of all Fast Flags here: FFlag Tracker

Set FPS Cap

Copy

<void> setfpscap(<uint> cap)

Sets the fps cap to cap.

Set Namecall Method

Copy

<void> setnamecallmethod(<string> method)

Sets the current namecall method to the new namecall method. Must be called in a __namecall metatable hook.

Set Roblox Clipboard

Copy

<void> setrbxclipboard(<string> content)

Sets content to the clipboard inside of Roblox.

Set Thread Identity

Copy

<void> setthreadidentity(<value> number)

Sets the current thread's identification number.

Alternative: setidentity, setcontext, setthreadcontext, set_thread_context, set_thread_identity

Message Box

Copy

<uint> messagebox(<string> text, <string> title, <uint> flag)

Creates a message box.

Alternative: messageboxasync

Flags:

Flag

Value

OK

0

OK / Cancel

1

Abort / Retry / Ignore

2

Yes / No / Cancel

3

Yes / No

4

Retry / Cancel

5

Cancel / Try Again / Continue

6

Return Values:

Value

Description

1

OK was clicked.

2

Cancel was clicked.

3

Abort was clicked.

4

Retry was clicked.

5

Ignore was clicked

6

Yes was clicked.

7

No was clicked.

10

Try Again was clicked.

11

Continue was clicked.

Queue On Teleport

Copy

<void> queue_on_teleport(<string> script)

Queues script to be executed after the next teleport.

Alternative queueonteleport

Request

Copy

<table> request(<table> a1, <bool?> Async)

Creates an http request with a1.

Alternative: http_request

ZSTD Compress

Copy

<string> zstdcompress(<string data>)

Compresses data using the Zstandard (ZSTD) compression algorithm.

ZSTD Decompress

Copy

<string> zstddecompress(<string data>)

Decompresses data that was compressed with the Zstandard (ZSTD) algorithm.

Previous

InputNext

NetworkLast updated 2 months ago

💻Functions

🪞

Reflection

These are all of the functions revolving reflections that Wave supports.

Check Caller

Copy

<bool> checkcaller(<void>)

Returns true if the current thread was created by Wave.

Get Hidden Property

Copy

<variant> gethiddenproperty(<Instance> Object, <string> Property)

Returns the value of the property that cannot be accessed through Lua.

Is Executor Closure

Copy

<bool> isexecutorclosure(<function> a1)

Returns true if a1 was created by Wave.

Alternative: isourclosure, is_our_closure, is_executor_closure, checkclosure

Is C Closure

Copy

<bool> iscclosure(<function fn>)

Returns true if fn is a C closure (a function implemented in C, not Lua).

Alternative: is_c_closure

Is Line Info

Copy

<bool> islineinfo(<function fn>)

Checks if fn contains Lua line information (debug metadata such as source file and line numbers).

Is Lua Closure

Copy

<bool> islclosure(<function> a1)

Returns true if a1 is an L closure.

Alternative: is_l_closure

Loadstring

Copy

<function> loadstring(<string> chunk, <string?> chunkName)

Loads chunk as a Lua function with optional chunkName and returns it.

Set Hidden Property

Copy

<void> sethiddenproperty(<Instance> Object, <string> Property, <variant> Value)

Sets the given property to new value.

Set Scriptable

Copy

<void> setscriptable(<Instance> Object, <string> Property, <bool> toggle)

Sets the property's scriptable state to toggle.

💻Functions

🕹️

Script

These are all of the functions revolving scripts that Wave supports.

Filter Garbage Collection

Copy

<table> filtergc(<any search, bool includeTables>)

Searches the garbage collector for objects matching search.

Alternative: filter_gc

Get Calling Script

Copy

<Instance> getcallingscript(<void>)

Gets the script that is calling this function.

Alternative: get_calling_script, getscriptcaller, getcaller

Get Garbage Collection

Copy

<table> getgc(<bool includeTables>)

Returns all objects currently tracked by the garbage collector.

Alternative: get_gc_objects

Get Function Hash

Copy

<string> getfunctionhash(<function fn>)

Returns a hash from fn.

Get Global Environment

Copy

<table> getgenv(<void>)

Returns the environment that will be applied to each script ran by Wave.

Get Loaded Modules

Copy

<table> getloadedmodules(<void>)

Returns a table with all loaded modules currently in game.

Alternative: get_loaded_modules

Get Modules

Copy

<table> getmodules(<Instance parent>)

Returns all ModuleScripts that are children of parent.

Alternative: get_modules

Get Roblox Environment

Copy

<table> getrenv(<void>)

Returns the Roblox environment.

Get Roblox Environment Global

Copy

<any> getrenvglobal(<string name>)

Returns the value of a global variable in the Roblox environment (renv).

Get Roblox Environment Shared

Copy

<any> getrenvshared(<string name>)

Returns the value of a shared variable in the Roblox environment (renv).

Get Running Scripts

Copy

<table> getrunningscripts(<void>)

Returns a list of scripts that are running in the environment. Returns nil if there are no scripts running.

Get Scripts

Copy

<table> getscripts(<void>)

Returns a list of scripts within the global state of the caller.

Alternative: get_scripts

Get Script Bytecode

Copy

<string> getscriptbytecode(<Instance> Script)

Returns the bytecode of the given script. This can be used in a dissassembler.

Alternative: dumpstring

Get Script Closure

Copy

<function> getscriptclosure(<Instance> Script)

Returns the closure from the given script, can be used to gather upvalues or constants.

Alternative: getscriptfunction, get_script_function

Get Script Environment

Copy

<table> getsenv(<LocalScript, ModuleScript> Script)

Returns the global environment of the given script.

Alternative: getmenv

Get Script Hash

Copy

<string> getscripthash(<Instance> Script)

Returns a SHA384 hash of the scripts bytecode. You can use this to detect changes of a script.

Get Table Environment

Copy

<table> gettenv(<void>)

Returns the environment table of the current script.

Alternative: getstateenv

Get Thread Script

Copy

<Instance> getthreadscript(<thread thrd>)

Returns the LocalScript or ModuleScript instance that the given thread originated from.

Is Local Source Container

Copy

<bool> islocalsourcecontainer(<Instance obj>)

Checks if obj is a local source container (like a LocalScript).

Require

Copy

<any> require(<Instance ModuleScript>)

Loads and returns the value of ModuleScript.

Set Closure Identity

Copy

<void> setclosureidentity(<function fn>, <int identity>)

Sets the security identity of a function closure.

Alternative: setclosurecaps

💻Functions

📶

Signal

These are all of the functions revolving around signals that Wave supports.

Can Signal Replicate

Copy

<bool> cansignalreplicate(<RBXScriptSignal signal>)

Checks if RBXScriptSignal is capable of being replicated (i.e., fired to the server or across the client-server boundary).

Disable Connection

Copy

<void> disableconnection(<RBXScriptConnection> Connection)

Disables Connection.

Enable Connection

Copy

<void> enableconnection(<RBXScriptConnection> Connection)

Enables Connection.

Fire Signal

Copy

<void> firesignal(<RBXScriptSignal> Signal, <variant?> Args...)

Fires all signals connected to the signal. If given, the arguments will be used to call the function.

Get All Replicate Signals

Copy

<table> getallreplicatesignals(<void>)

Returns a table containing all RBXScriptSignal objects in the game that are capable of replication.

Get Connections

Copy

<table> getconnections(<RBXScriptSignal> Signal)

Returns a table with all connections to the given signal.

Connections:

Connection

Description

.Function

The function connected to the connection.

:Enable

Enables the connection.

:Disable

Disables the connection.

:Fire

Fires the connection.

Get Signal Arguments

Copy

<table> getsignalarguments(<RBXScriptConnection conn>)

Retrieves the arguments passed to a specific RBXScriptConnection when it was last fired.

Hook Signal

Copy

<void> hooksignal(<RBXScriptSignal> Signal, <function> callback)

Intercepts signal invocations. When the Signal is fired, the callback is called for each Lua connection with an info table and arguments. Returning true from the callback triggers the original connection.

Note: hooksignal cannot intercept C connections or CoreScript Lua connections.

Is Connection Enabled

Copy

<bool> isconnectionenabled(<RBXScriptConnection> Connection)

Returns true if a connection is enabled.

Is Signal Hooked

Copy

<void> issignalhooked(<RBXScriptSignal> Signal)

Returns true if Signal is hooked.

Replicate Signal

Copy

<void> replicatesignal(<RBXScriptSignal signal>, <var ...args>)

Fires a RBXScriptSignal locally, simulating its activation with the provided arguments.

Unhook Signal

Copy

<void> unhooksignal(<RBXScriptSignal> Signal)

Unhooks a signal hooked with hooksignal.

💻Functions

📊

Table

These are all of the functions revolving tables that Wave supports.

Get Raw Metatable

Copy

<table> getrawmetatable(<table> a1)

Returns the __metatable of a1.

Is Read Only

Copy

<bool> isreadonly(<table> a1)

Returns if a1 is read-only.

Is Writable

Copy

<bool> iswritable(<table tbl>)

Checks if tbl is writable, i.e., if its fields can be modified.

Alternative: iswriteable

Make Read Only

Copy

<void> makereadonly(<table tbl>)

Makes tbl read-only, preventing modifications to its fields.

Alternative: make_readonly

Make Writable

Copy

<void> makewritable(<table tbl>)

Makes tbl writable, allowing its fields to be modified.

Alternative: make_writable, make_writeable, makewriteable

Set Raw Metatable

Copy

<bool> setrawmetatable(<table> a1, <table> a2)

Sets the __metatable of a1 to a2.

Set Read Only

Copy

<void> setreadonly(<table> a1, <bool> a2)

Sets the read-only value of a1 to a2.