# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder
using Pkg

name = "vtkfig"
version = v"0.24.0"

# Collection of sources required to build vtkfig
sources = [
    GitSource("https://github.com/j-fu/vtkfig.git","4c13a4cdcce88b477d1356979f2a53b67673a115")
]



# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
EXTRA_VARS=()
if [[ "${target}" == *-linux-* ]] || [[ "${target}" == *-freebsd* ]]; then
    # On Linux and FreeBSD this variable by default does `-L/usr/lib`
    EXTRA_VARS+=(LDFLAGS.EXTRA="")
fi


mkdir build
cd build
cmake -DVTKFIG_BUILD_EXAMPLES:BOOL=False  -DCMAKE_INSTALL_PREFIX=$prefix  -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN}  -DCMAKE_BUILD_TYPE=Release ../vtkfig
make -j${nproc} 
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
#platforms = supported_platforms()

platforms=[Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(;cxxstring_abi=:cxx11))]

# The products that we will ensure are always built
products = [
    LibraryProduct("libvtkfig",:libvtkfig),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "VTKMinimal_jll"
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

