# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder
using Pkg

name = "vtkfig"
version = v"0.24.1"

# Collection of sources required to build vtkfig
sources = [
    GitSource("https://github.com/j-fu/vtkfig.git","b44c3f0879d4b660bb3b1de6db248def0fde7366")
]



# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
EXTRA_VARS=()
if [[ "${target}" == *-linux-* ]] || [[ "${target}" == *-freebsd* ]]; then
    # On Linux and FreeBSD this variable by default does `-L/usr/lib`
    EXTRA_VARS+=(LDFLAGS.EXTRA="")
fi

USR_LOCAL=`grep CMAKE_SYSROOT $CMAKE_TARGET_TOOLCHAIN | sed -e 's/set(CMAKE\_SYSROOT//g' -e 's/)//g'`/usr/local
ln -s $prefix/bin/  $USR_LOCAL/bin
ln -s $prefix/include/  $USR_LOCAL/include

mkdir build
cd build
cmake -DVTKFIG_BUILD_EXAMPLES:BOOL=False\
      -DVTKFIG_BUILD_BINARIES:BOOL=False\
      -DCMAKE_INSTALL_PREFIX=$prefix\
      -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN}\
      -DCMAKE_BUILD_TYPE=Release\
       ../vtkfig

make -j${nproc} 
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
# platforms = supported_platforms()

platforms=[Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(;cxxstring_abi=:cxx11))]

# The products that we will ensure are always built
products = [
    LibraryProduct("libvtkfig",:libvtkfig),
]

# Dependencies that must be installed before this package can be built
# jll and general version numbering are not compatible:
# see https://github.com/JuliaLang/Pkg.jl/issues/1568

dependencies=[
    Dependency(PackageSpec(name="VTKMinimal_jll",rev="d77d859d1a15d445ea8f4dab7c26652463dfa00b")) # 8.2.0+1
]


# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies, preferred_gcc_version=v"9")

