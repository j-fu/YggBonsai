using BinaryBuilder

name = "TetGen"
version = v"1.5.1"

sources = [
    "https://github.com/ufz/tetgen.git" =>  "9c4b70d479c6f67cb9e16dbe65f81ec3b821acad"
#    "http://www.tetgen.org/1.5/src/tetgen1.6.0.zip" => "e7bbbb4fb8f47f0adc3b46b26ab172557ebb90808c06e21b902b2166717af582"
]



script = raw"""
#zipname=tetgen1.6.0
#cd $WORKSPACE/srcdir/$zipname
cd $WORKSPACE/srcdir/tetgen

cat <<EOF  > cwrapper.cxx

#include "tetgen.h" // Defined tetgenio, tetrahedralize().
extern "C" {
typedef struct {
  int firstnumber; // 0 or 1, default 0.
  int mesh_dim;    // must be 3.

  double *pointlist;
  double *pointattributelist;
  double *pointmtrlist;
  int *pointmarkerlist;
  int numberofpoints;
  int numberofpointattributes;
  int numberofpointmtrs;

  int *tetrahedronlist;
  double *tetrahedronattributelist;
  double *tetrahedronvolumelist;
  int *neighborlist;
  int numberoftetrahedra;
  int numberofcorners;
  int numberoftetrahedronattributes;

  tetgenio::facet *facetlist;
  int *facetmarkerlist;
  int numberoffacets;

  double *holelist;
  int numberofholes;

  double *regionlist;
  int numberofregions;

  double *facetconstraintlist;
  int numberoffacetconstraints;

  double *segmentconstraintlist;
  int numberofsegmentconstraints;

  int *trifacelist;
  int *trifacemarkerlist;
  int numberoftrifaces;

  int *edgelist;
  int *edgemarkerlist;
  int numberofedges;
  } TetGenIOf64;
}

void copy_tetio(tetgenio* in, TetGenIOf64* out){
    out->firstnumber = in->firstnumber;
    out->mesh_dim = in->mesh_dim;

    out->pointlist = in->pointlist;
    out->pointattributelist = in->pointattributelist;
    out->pointmtrlist = in->pointmtrlist;
    out->pointmarkerlist = in->pointmarkerlist;
    out->numberofpoints = in->numberofpoints;
    out->numberofpointattributes = in->numberofpointattributes;
    out->numberofpointmtrs = in->numberofpointmtrs;

    out->tetrahedronlist = in->tetrahedronlist;
    out->tetrahedronattributelist = in->tetrahedronattributelist;
    out->tetrahedronvolumelist = in->tetrahedronvolumelist;
    out->neighborlist = in->neighborlist;
    out->numberoftetrahedra = in->numberoftetrahedra;
    out->numberofcorners = in->numberofcorners;
    out->numberoftetrahedronattributes = in->numberoftetrahedronattributes;

    out->facetlist = in->facetlist;
    out->facetmarkerlist = in->facetmarkerlist;
    out->numberoffacets = in->numberoffacets;

    out->holelist = in->holelist;
    out->numberofholes = in->numberofholes;

    out->regionlist = in->regionlist;
    out->numberofregions = in->numberofregions;

    out->facetconstraintlist = in->facetconstraintlist;
    out->numberoffacetconstraints = in->numberoffacetconstraints;

    out->segmentconstraintlist = in->segmentconstraintlist;
    out->numberofsegmentconstraints = in->numberofsegmentconstraints;

    out->trifacelist = in->trifacelist;
    out->trifacemarkerlist = in->trifacemarkerlist;
    out->numberoftrifaces = in->numberoftrifaces;

    out->edgelist = in->edgelist;
    out->edgemarkerlist = in->edgemarkerlist;
    out->numberofedges = in->numberofedges;

}
void copy_tetio(TetGenIOf64* in, tetgenio* out){
    out->firstnumber = in->firstnumber;
    out->mesh_dim = in->mesh_dim;

    out->pointlist = in->pointlist;
    out->pointattributelist = in->pointattributelist;
    out->pointmtrlist = in->pointmtrlist;
    out->pointmarkerlist = in->pointmarkerlist;
    out->numberofpoints = in->numberofpoints;
    out->numberofpointattributes = in->numberofpointattributes;
    out->numberofpointmtrs = in->numberofpointmtrs;

    out->tetrahedronlist = in->tetrahedronlist;
    out->tetrahedronattributelist = in->tetrahedronattributelist;
    out->tetrahedronvolumelist = in->tetrahedronvolumelist;
    out->neighborlist = in->neighborlist;
    out->numberoftetrahedra = in->numberoftetrahedra;
    out->numberofcorners = in->numberofcorners;
    out->numberoftetrahedronattributes = in->numberoftetrahedronattributes;

    out->facetlist = in->facetlist;
    out->facetmarkerlist = in->facetmarkerlist;
    out->numberoffacets = in->numberoffacets;

    out->holelist = in->holelist;
    out->numberofholes = in->numberofholes;

    out->regionlist = in->regionlist;
    out->numberofregions = in->numberofregions;

    out->facetconstraintlist = in->facetconstraintlist;
    out->numberoffacetconstraints = in->numberoffacetconstraints;

    out->segmentconstraintlist = in->segmentconstraintlist;
    out->numberofsegmentconstraints = in->numberofsegmentconstraints;

    out->trifacelist = in->trifacelist;
    out->trifacemarkerlist = in->trifacemarkerlist;
    out->numberoftrifaces = in->numberoftrifaces;

    out->edgelist = in->edgelist;
    out->edgemarkerlist = in->edgemarkerlist;
    out->numberofedges = in->numberofedges;
}

extern "C" {
  TetGenIOf64 tetrahedralizef64(TetGenIOf64 jl_in, char* command){
    tetgenio in, out;
    copy_tetio(&jl_in, &in);
    tetrahedralize(command, &in, &out);
    TetGenIOf64 jl_out;
    copy_tetio(&out, &jl_out);
    in.initialize(); // don't free pointers from julia!
    out.initialize(); // don't free pointers for julia!
    return jl_out;
  }
}
EOF

mv tetgen.h tmp.h
sed -e "s/class tetgenio {/class tetgenio { void * operator new(size_t n) {  return malloc(n);} void operator delete(void* p) noexcept {free(p);} /g" tmp.h > tetgen.h


${CXX} -c -fPIC -std=c++11 -O3 predicates.cxx -o predicates.o
${CXX} -c -fPIC -std=c++11 -O3 -DTETLIBRARY -c tetgen.cxx -o tetgen.o
${CXX} -c -fPIC -std=c++11 -O3 -DTETLIBRARY -c cwrapper.cxx -o cwrapper.o
libdir="lib"
if [[ ${target} == *-mingw32 ]]; then     libdir="bin"; else     libdir="lib"; fi
mkdir ${prefix}/${libdir}
${CXX} $LDFLAGS -shared -fPIC tetgen.o predicates.o cwrapper.o -DTETLIBRARY -o ${prefix}/${libdir}/libtet.${dlext} 
"""

#platforms = supported_platforms()
platforms=[Linux(:x86_64, libc=:glibc)]
           
products = [
    LibraryProduct("libtet", :libtet)
]
dependencies = Dependency[]

build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)

