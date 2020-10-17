using BinaryBuilder

name = "TetGen"
version = v"1.5.1"

#
# For 1.5.1 use the same source as in tetgenbuilder
# 
sources = [
    GitSource("https://github.com/ufz/tetgen.git","9c4b70d479c6f67cb9e16dbe65f81ec3b821acad"),
    DirectorySource("cwrapper",target="cwrapper")
    # Tentative upstream source for 1.6, this may change.
    #    "http://www.tetgen.org/1.5/src/tetgen1.6.0.zip" => "e7bbbb4fb8f47f0adc3b46b26ab172557ebb90808c06e21b902b2166717af582"
]



script = raw"""
# This will be used for 1.6
# zipname=tetgen1.6.0
# cd $WORKSPACE/srcdir/$zipname

cd $WORKSPACE/srcdir/tetgen

#
# Patch tetgen.h  with operators delegating new/delete to malloc/free for C/Julia compatibility
#
mv tetgen.h tmp.h
sed -e "s/class tetgenio {/class tetgenio { void * operator new(size_t n) {  return malloc(n);} void operator delete(void* p) noexcept {free(p);} /g" tmp.h > tetgen.h

# Compile and link with C wrapper
${CXX} -c -fPIC -std=c++11 -O3 -c -DTETLIBRARY -I. ${WORKSPACE}/srcdir/cwrapper/cwrapper.cxx -o cwrapper.o
${CXX} -c -fPIC -std=c++11 -O3 -c -DTETLIBRARY tetgen.cxx -o tetgen.o
${CXX} -c -fPIC -std=c++11 -O3 -c -DTETLIBRARY predicates.cxx -o predicates.o

libdir="lib"
if [[ ${target} == *-mingw32 ]]; then     libdir="bin"; else     libdir="lib"; fi
mkdir ${prefix}/${libdir}

${CXX} $LDFLAGS -shared -fPIC tetgen.o predicates.o  cwrapper.o -o ${prefix}/${libdir}/libtet.${dlext} 

install_license LICENSE
"""

platforms = supported_platforms()
#platforms=[Linux(:x86_64, libc=:glibc)]
           
products = [
    LibraryProduct("libtet", :libtet)
]
dependencies = Dependency[]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

