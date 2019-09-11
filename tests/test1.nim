import funchook

proc my_add(a, b: int): int = a + b


var add_func = my_add

proc hook_add(a, b: int): int =
  echo "original my_add called inside hook_add: ", add_func(a, b)
  result = a * b

var
  h = initHook()
  rv: FUNCHOOK_ERROR

if h == nil:
  quit("create funchook failed")

rv = h.prepare(addr add_func, hook_add)
if rv != SUCCESS:
  echo h.errorMessage()

assert my_add(4, 5) == 9, "pre-hook"

rv = h.install(0)
if rv != SUCCESS:
  echo h.errorMessage()

assert my_add(4, 5) == 20, "post-hook"