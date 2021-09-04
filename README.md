# funchook.nim
[funchook](https://github.com/kubo/funchook) wrapper for [Nim](https://nim-lang.org)

This wrapper compiles funchook with diStorm3 disassembler.

Suports both x64 and x86-64 on:

[x] Linux
[x] Windows
[ ] MacOS (not tested yet)

### Installation
```shell
nimble install funchook
```

### Usage

```nim
import funchook

proc my_add(a, b: int): int =
  ## original proc to be hooked
  a + b

var add_func = my_add

proc hook_add(a, b: int): int =
  ## proc to replace my_add
  echo add_func(a, b) # call original proc with trampoline
  a * b

var h = initHook()

if h == nil:
  quit("Error: create funchook failed")

if h.prepare(addr add_func, hook_add) != SUCCESS:
  quit("Error: " & h.errorMessage())

assert my_add(4, 5) == 9, "pre-hook"

if h.install(0) != SUCCESS:
  quit("Error: " & h.errorMessage())

assert my_add(4, 5) == 20, "post-hook"
```
