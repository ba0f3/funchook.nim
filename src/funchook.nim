import os

when defined(FUNCHOOK_DYNAMIC_LINK):
  {.passL: "-lfunchook".}
else:
  const LIB_DIR = currentSourcePath().splitPath.head & "/private"
  when hostCPU == "i386":
    const SUFFIX = "32"
  else:
    const SUFFIX = "64"
  {.passL: "-L" & LIB_DIR & " -lfunchook" & SUFFIX.}

{.pragma: fh, discardable, cdecl, importc.}

type
  funchook_t {.final, pure.} = object
  FuncHook* = ptr funchook_t


  FUNCHOOK_ERROR* = enum
    INTERNAL_ERROR = -1
    SUCCESS = 0
    OUT_OF_MEMORY
    ALREADY_INSTALLED
    DISASSEMBLY
    IP_RELATIVE_OFFSET
    CANNOT_FIX_IP_RELATIVE
    FOUND_BACK_JUMP
    TOO_SHORT_INSTRUCTIONS
    MEMORY_ALLOCATION
    MEMORY_FUNCTION
    NOT_INSTALLED

converter toPointer*(x: int): pointer = cast[pointer](x)

proc funchook_create*(): FuncHook {.fh.} ## Create a funchook handle, return nil when out-of-memory.
proc funchook_prepare*(hook: FuncHook, src: ptr pointer, dst: pointer): FUNCHOOK_ERROR {.fh.} ## Prepare hooking
proc funchook_install*(hook: FuncHook, flags: int): FUNCHOOK_ERROR {.fh.} ## Install hooks prepared by funchook_prepare().
proc funchook_uninstall*(hook: FuncHook, flags: int): FUNCHOOK_ERROR {.fh.} ## Uninstall hooks installed by funchook_install().
proc funchook_destroy*(hook: FuncHook): FUNCHOOK_ERROR {.fh.} ## Destroy a funchook handle
proc funchook_error_message*(hook: FuncHook): cstring  {.fh.} ## Get error message
proc funchook_set_debug_file*(name: cstring): FUNCHOOK_ERROR {.fh.} ## Set log file name to debug funchook itself.


template initHook*(): FuncHook = funchook_create()
template prepare*(fh: FuncHook, src: ptr any, dst: pointer): FUNCHOOK_ERROR = funchook_prepare(fh, cast[ptr pointer](src), dst)
template install*(fh: FuncHook, flags = 0): FUNCHOOK_ERROR = funchook_install(fh, flags)
template uninstall*(fh: FuncHook, flags = 0): FUNCHOOK_ERROR = funchook_uninstall(fh, flags)
template destroy*(fh: FuncHook): FUNCHOOK_ERROR = funchook_destroy(fh)
template errorMessage*(fh: FuncHook): string = $funchook_error_message(fh)
template setDebugFile*(filename: string): FUNCHOOK_ERROR = funchook_set_debug_file(filename.cstring)
