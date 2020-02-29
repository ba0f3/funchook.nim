import os, nimterop/[cimport, build,]

const
  baseDir = currentSourcePath.parentDir()
  srcDir = baseDir/"funchook"

when defined(windows):
  const
    libFunchook = "funchook.lib"
    libDistorm = "distorm.lib"
elif defined(posix):
  const
    libFunchook = "libfunchook.a"
    libDistorm = "libdistorm.a"
else:
  static: doAssert false


static:
  cDebug()
  cDisableCaching()

  gitPull("https://github.com/kubo/funchook.git", outdir = srcDir, checkout = "master")
  when defined(window):
    cmake(srcDir/"build", "CMakeCache.txt", "-DFUNCHOOK_BUILD_SHARED=OFF -DFUNCHOOK_BUILD_TESTS=OFF -G \"Visual Studio 15 2017 Win64\" -DCMAKE_INSTALL_PREFIX="/baseDir & " ..")
    cmake(srcDir/"build", libFunchook, "--build . --config Release --target INSTALL")
  else:
    cmake(srcDir/"build", "CMakeCache.txt", "-DFUNCHOOK_BUILD_SHARED=OFF -DFUNCHOOK_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_INSTALL_PREFIX="/baseDir & " ..")
    make(srcDir/"build", libFunchook)
    make(srcDir/"build", libFunchook, "install")
  cpFile(srcDir/"build"/libDistorm, baseDir/"lib")