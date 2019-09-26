# funchook.nim
[funchook][] wrapper for [Nim][]

The project contains static libraries for Linux, for Windows and other OS please build `funchook` manually and enable `FUNCHOOK_DYNAMIC_LINK` switch

Note: need help to build static libraries for other OSes/compilers

### Installation
```shell
nimble install funchook
```

### Usage

```nim
import funchook

proc my_add(a, b: int): int = a + b
  ## original proc to be hooked

var add_func = my_add

proc hook_add(a, b: int): int =
  ## proc to replace my_add

  # call original proc with trampoline
  echo add_func(a, b)

  result = a * b

var
  h = initHook()
  rv: FUNCHOOK_ERROR

if h == nil:
  quit("Error: create funchook failed")

rv = h.prepare(addr add_func, hook_add)
if rv != SUCCESS:
  quit("Error: " & h.errorMessage())

assert my_add(4, 5) == 9, "pre-hook"

rv = h.install(0)
if rv != SUCCESS:
  quit("Error: " & h.errorMessage())

assert my_add(4, 5) == 20, "post-hook"
```


[Nim]: https://nim-lang.org
[funchook]: https://github.com/kubo/funchook