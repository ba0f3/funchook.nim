import funchook

proc my_add(a, b: int): int = a + b
proc hook_add(a, b: int): int = a * b

var
  h = initHook()
  rv: FUNCHOOK_ERROR

if h == nil:
  quit("create funchook failed")

var add_func = my_add

rv = h.prepare(addr add_func, hook_add)
if rv != SUCCESS:
  echo h.errorMessage()

echo "Before hook: ", my_add(4, 5)
assert my_add(4, 5) == 9

rv = h.install(0)
if rv != SUCCESS:
  echo h.errorMessage()

echo "After hook: ", my_add(4, 5)
assert my_add(4, 5) == 20