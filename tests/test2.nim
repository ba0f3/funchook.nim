import funchook
from strutils import stripLineEnd


var stripLineEnd_func = stripLineEnd

proc stripLineEnd_hook(s: var string) =
  echo "stripLineEnd_hook ", s
  stripLineEnd_func(s)


discard setDebugFile("funchook.log")

var
  h = initHook()
  rv: FUNCHOOK_ERROR

if h == nil:
  quit("create funchook failed")

rv = h.prepare(addr stripLineEnd_func, stripLineEnd_hook)
if rv != SUCCESS:
  echo h.errorMessage()

rv = h.install(0)
if rv != SUCCESS:
  echo h.errorMessage()

var greating = "hello\n"
greating.stripLineEnd
echo greating