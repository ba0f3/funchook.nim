import funchook

proc my_add(a, b: int): int = a + b
proc hook_add(a, b: int): int = a * b

var
  h = funchook_create()
  rv: FUNCHOOK_ERROR

if h == nil:
  quit("create funchook failed")

var add_func = my_add

rv = funchook_prepare(h, addr add_func, hook_add)
if rv != SUCCESS:
  echo h.funchook_error_message()

echo "Before hook: ", my_add(4, 5)
assert my_add(4, 5) == 9

rv = funchook_install(h, 0)
if rv != SUCCESS:
  echo h.funchook_error_message()

echo "After hook: ", my_add(4, 5)
assert my_add(4, 5) == 20