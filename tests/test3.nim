import funchook, ba0f3/fptr
from strutils import stripLineEnd


proc NI_stripLineEnd(s: var string) {.fptr, cdecl.} = stripLineEnd

proc stripLineEnd_hook(s: var string) {.gcsafe.} =
  echo "stripLineEnd_hook ", s
  NI_stripLineEnd(s)

discard setDebugFile("funchook.log")

var
  h = initHook()
  rv: FUNCHOOK_ERROR

if h == nil:
  quit("create funchook failed")

rv = h.prepare(faddr NI_stripLineEnd, stripLineEnd_hook)
if rv != SUCCESS:
  echo h.errorMessage()

rv = h.install(0)
if rv != SUCCESS:
  echo h.errorMessage()

var greating = "hello\n"
greating.stripLineEnd
echo greating