# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder
using Pkg

name = "vtkfig"
version = v"0.24.4"

# Collection of sources required to build vtkfig
sources = [
    GitSource("https://github.com/j-fu/vtkfig.git","2e6db0d75e3273933705e356cf1018c521885b6a")
]


# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
EXTRA_VARS=()
if [[ "${target}" == *-linux-* ]] || [[ "${target}" == *-freebsd* ]]; then
    # On Linux and FreeBSD this variable by default does `-L/usr/lib`
    EXTRA_VARS+=(LDFLAGS.EXTRA="")
fi

# workaround for finding installed targets
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


# These are the platforms where we have the X11 stuff and VTKMinimal
platforms = [p for p in supported_platforms() if p isa Union{Linux,FreeBSD}]

# Stick to cxx11 
platforms = [p for p in expand_cxxstring_abis(platforms) if p.compiler_abi==CompilerABI(cxxstring_abi=:cxx11) ]


# The products that we will ensure are always built
products = [
    LibraryProduct("libvtkfig",:libvtkfig),
]

# Dependencies that must be installed before this package can be built
# jll and general version numbering are not compatible:
# see https://github.com/JuliaLang/Pkg.jl/issues/1568,
# so we resolve this by fixing the commit hash of the dependency

dependencies=[
#    Dependency(PackageSpec(name="VTKMinimal_jll",rev="530a89e35ca3b95a770f37f7115da8aec6e441a0")) # 9.0.0+0
#    Dependency(PackageSpec(name="VTKMinimal_jll",rev="c139fdc88bb8c328304062940dd4c8fcc1fa5414")) # 9.0.0+1 
    Dependency(PackageSpec(name="VTKMinimal_jll",rev="4941d11da3e5101ef56b8f68df0392c76d29cb42")) # 9.0.0+2 vtk 9.0.0.rc2
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies, preferred_gcc_version=v"6")

