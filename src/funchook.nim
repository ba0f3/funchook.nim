import os, distorm3

const PATH = currentSourcePath.splitPath.head

when defined(windows):
   const FUNCHOOK_OS = "windows"
elif defined(linux):
  const FUNCHOOK_OS = "unix"
else:
  {.error: "Unsupported OS".}

when hostCPU == "i386" or hostCPU == "amd64":
  const FUNCHOOK_CPU = "x86"
#elif hostPCU = "arm64":
#  const FUNCHOOK_CPU = "arm64"
else:
  {.error: "Unsupported CPU".}

{.passC: "-I " & PATH & "/private/include -I " & PATH & "/private/funchook/include".}
{.passC: "-DDISASM_DISTORM=1 -DSIZEOF_VOID_P=" & $sizeof(int).}

when FUNCHOOK_OS == "unix":
  {.passC: "-D_GNU_SOURCE -DGNU_SPECIFIC_STRERROR_R=1".}
elif FUNCHOOK_OS == "windows":
  {.passL: "-lpsapi".}

{.compile: PATH & "/private/funchook/src/funchook.c".}
{.compile: PATH & "/private/funchook/src/funchook_" & FUNCHOOK_CPU & ".c".}
{.compile: PATH & "/private/funchook/src/funchook_" & FUNCHOOK_OS & ".c".}
{.compile: PATH & "/private/funchook/src/disasm_distorm.c".}


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
