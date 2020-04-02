# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "VTKMinimal"
version = v"9.0.0"

#
# Build a minimal subset of VTK sufficient for rendering purposes (see vtkfig_jll, VTKView.jl)
# Notably, this leaves  out HDF5 and MPI, thus creating fewer clash points for transient linking problems.
# Building the full version on BinaryBuilder seems to be feasible, though.      
#
# The platform constraint to linux + FreeBSD comes from the constraints on the X11 libs etc.
# Currently, this depends on the Xorg libraries, therefore it is not available for Mac+Win,
# this situation may change though with Qt.
#
# A couple of libraries (eigen, doubleconversion, ogg, theora) is used in the
# vtk built-in version. It appears to be possible to replace them by jlls upon availability of those.
# Though there is Ogg_jll, the vtktheora does not go well with it.
#
# Generally it seems to be a good idea not to use the vtk built-in versions as this could create
# transient linking clashes if other packages use the same lib from a jll.
# 
# (c) Jürgen Fuhrmann (@j-fu)

# Grab the source directly from the vtk website
sources = [
    # "https://www.vtk.org/files/release/9.0/VTK-9.0.0.rc1.tar.gz" => "7dbedd58a1ae144b98a4534b9badac683c88e5aa4a959a57856680f00258d268"

    # Version with possibility to switch off wrapping tools. Will be in 9.0.0 final.
    ArchiveSource("file:///home/fuhrmann/Downloads/vtk-496e01f755421cc12dc52d40d8143299af9c6325.tar.gz","b051a4c81cee1a6f4a96b8bdd3731a71b686776c20951d72c90dfefa6f7c06aa")
]

# Adapt tarname to the source
tarname="VTK-9.0.0.rc1"
tarname="vtk-496e01f755421cc12dc52d40d8143299af9c6325"

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


#
# Mock test result for large file support for compiling toolchain
# we might  set  this to 1 for 64bit ?
#
cat <<EOF  > DefaultTryRunResults.cmake
set( CMAKE_REQUIRE_LARGE_FILE_SUPPORT 
     "0"
     CACHE STRING "Result from TRY_RUN" FORCE)

set( CMAKE_REQUIRE_LARGE_FILE_SUPPORT__TRYRUN_OUTPUT 
     ""
     CACHE STRING "Output from TRY_RUN" FORCE)
EOF


cmake -C DefaultTryRunResults.cmake\
     -DVTK_CUSTOM_LIBRARY_SUFFIX=""\
     -DCMAKE_REQUIRE_LARGE_FILE_SUPPORT=0\
     -DBUILD_SHARED_LIBS=ON\
     -DVTK_ENABLE_WRAPPING=OFF\
     -DVTK_ENABLE_LOGGING=OFF\
     -DVTK_FORBID_DOWNLOADS=YES\
     -DVTK_GROUP_ENABLE_Rendering=YES\
     -DVTK_GROUP_ENABLE_StandAlone=YES\
     -DVTK_GROUP_ENABLE_Imaging=NO\
     -DVTK_GROUP_ENABLE_MPI=NO\
     -DVTK_GROUP_ENABLE_Qt=NO\
     -DVTK_USE_X:BOOL=YES\
     -DVTK_GROUP_ENABLE_Views=NO\
     -DVTK_GROUP_ENABLE_Web=NO\
     -DVTK_MODULE_ENABLE_VTK_ViewsQt:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_RenderingContextOpenGL2=YES\
     -DVTK_MODULE_ENABLE_VTK_GUISupportQtSQL:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_AcceleratorsVTKm:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_InfovisBoost:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_InfovisBoostGraphAlgorithms:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_InfovisCore:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_InfovisLayout:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_TestingCore:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_TestingGenericBridge:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_TestingIOSQL:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_TestingRendering:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_UtilitiesBenchmarks:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_DomainsChemistry:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_DomainsChemistryOpenGL2:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_DomainsMicroscopy:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_DomainsParallelChemistry:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_GeovisCore:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_GeovisGDAL:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_RenderingOpenVR:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_RenderingMatplotlib:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_RenderingParallel:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_RenderingParallelLIC:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_RenderingVtkJS:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_RenderingRayTracing:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_RenderingSceneGraph:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_RenderingVolumeAMR:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_FiltersParallelMPI:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_ViewsInfovis:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_ChartsCore:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_FiltersAMR:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_h5part:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_hdf5:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOADIOS2:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOAMR:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOAsynchronous:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOCityGML:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOEnSight:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOExodus:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOExport:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOExportGL2PS:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOExportPDF:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOFFMPEG:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOGDAL:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOGeoJSON:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOGeometry:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOH5part:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOImport:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOInfovis:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOLAS:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOLSDyna:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOMINC:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOMPIImage:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOMPIParallel:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOMotionFX:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOMySQL:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IONetCDF:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOODBC:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOPDAL:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOPIO:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOPLY:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOParallel:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOParallelExodus:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOParallelLSDyna:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOParallelNetCDF:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOParallelXML:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOParallelXdmf3:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOPostgreSQL:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOSQL:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOSegY:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOTRUCHAS:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOTecplotTable:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOVPIC:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOVeraOut:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOVideo:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOXdmf2:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_IOXdmf3:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_WrappingTools:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_WrappingPythonCore:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_PythonInterpreter:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_pegtl:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_sqlite:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_verdict:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_FiltersParallelVerdict:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_FiltersVerdict:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_verdict:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_vpic:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_vtkDICOM:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_xdmf2:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_xdmf3:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_zfp:STRING=NO\
     -DVTK_MODULE_ENABLE_VTK_vtkm:STRING=NO\
     -DVTK_MODULE_USE_EXTERNAL_VTK_glew:BOOL=ON\
     -DVTK_MODULE_USE_EXTERNAL_VTK_zlib:BOOL=ON\
     -DVTK_MODULE_USE_EXTERNAL_VTK_jpeg:BOOL=ON\
     -DVTK_MODULE_USE_EXTERNAL_VTK_tiff:BOOL=ON\
     -DVTK_MODULE_USE_EXTERNAL_VTK_freetype:BOOL=ON\
     -DVTK_MODULE_USE_EXTERNAL_VTK_expat:BOOL=ON\
     -DVTK_MODULE_USE_EXTERNAL_VTK_lz4:BOOL=ON\
     -DVTK_MODULE_USE_EXTERNAL_VTK_lzma:BOOL=ON\
     -DVTK_MODULE_USE_EXTERNAL_VTK_png:BOOL=ON\
     -DCMAKE_INSTALL_PREFIX=$prefix\
     -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TARGET_TOOLCHAIN}\
     -DCMAKE_BUILD_TYPE=Release\
     ../${tarname}/

make -j${nproc}

make install

"""

# These are the platforms where we have the X11 stuff
platforms = [p for p in supported_platforms() if p isa Union{Linux,FreeBSD} && p.arch !=:powerpc64le]

# Stick to cxx11 in the sense of "moving forward"
platforms = [p for p in expand_cxxstring_abis(platforms) if p.compiler_abi==CompilerABI(cxxstring_abi=:cxx11) ]


# for testing during development
# platforms=[Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(;cxxstring_abi=:cxx11))]
# platforms=[Linux(:i686, libc=:glibc, compiler_abi=CompilerABI(cxxstring_abi=:cxx11))]
# platforms=[Linux(:aarch64, libc=:glibc, compiler_abi=CompilerABI(cxxstring_abi=:cxx11))]
# platforms=[Linux(:aarch64, libc=:musl, compiler_abi=CompilerABI(cxxstring_abi=:cxx11))]


# The products that we will ensure are always built
products = [
    LibraryProduct("libvtkCommonColor",:libvtkCommonColor),                                               
    LibraryProduct("libvtkCommonComputationalGeometry",:libvtkCommonComputationalGeometry),
    LibraryProduct("libvtkCommonCore",:libvtkCommonCore),
    LibraryProduct("libvtkCommonDataModel",:libvtkCommonDataModel),
    LibraryProduct("libvtkCommonExecutionModel",:libvtkCommonExecutionModel),
    LibraryProduct("libvtkCommonMath",:libvtkCommonMath),
    LibraryProduct("libvtkCommonMisc",:libvtkCommonMisc),
    LibraryProduct("libvtkCommonSystem",:libvtkCommonSystem),
    LibraryProduct("libvtkCommonTransforms",:libvtkCommonTransforms),
    LibraryProduct("libvtkDICOMParser",:libvtkDICOMParser),
    LibraryProduct("libvtkdoubleconversion",:libvtkdoubleconversion),
    LibraryProduct("libvtkFiltersCore",:libvtkFiltersCore),
    LibraryProduct("libvtkFiltersExtraction",:libvtkFiltersExtraction),
    LibraryProduct("libvtkFiltersFlowPaths",:libvtkFiltersFlowPaths),
    LibraryProduct("libvtkFiltersGeneral",:libvtkFiltersGeneral),
    LibraryProduct("libvtkFiltersGeneric",:libvtkFiltersGeneric),
    LibraryProduct("libvtkFiltersGeometry",:libvtkFiltersGeometry),
    LibraryProduct("libvtkFiltersHybrid",:libvtkFiltersHybrid),
    LibraryProduct("libvtkFiltersHyperTree",:libvtkFiltersHyperTree),
    LibraryProduct("libvtkFiltersImaging",:libvtkFiltersImaging),
    LibraryProduct("libvtkFiltersModeling",:libvtkFiltersModeling),
    LibraryProduct("libvtkFiltersParallel",:libvtkFiltersParallel),
    LibraryProduct("libvtkFiltersParallelImaging",:libvtkFiltersParallelImaging),
    LibraryProduct("libvtkFiltersPoints",:libvtkFiltersPoints),
    LibraryProduct("libvtkFiltersProgrammable",:libvtkFiltersProgrammable),
    LibraryProduct("libvtkFiltersSelection",:libvtkFiltersSelection),
    LibraryProduct("libvtkFiltersSMP",:libvtkFiltersSMP),
    LibraryProduct("libvtkFiltersSources",:libvtkFiltersSources),
    LibraryProduct("libvtkFiltersStatistics",:libvtkFiltersStatistics),
    LibraryProduct("libvtkFiltersTexture",:libvtkFiltersTexture),
    LibraryProduct("libvtkFiltersTopology",:libvtkFiltersTopology),
    LibraryProduct("libvtkImagingColor",:libvtkImagingColor),
    LibraryProduct("libvtkImagingCore",:libvtkImagingCore),
    LibraryProduct("libvtkImagingFourier",:libvtkImagingFourier),
    LibraryProduct("libvtkImagingGeneral",:libvtkImagingGeneral),
    LibraryProduct("libvtkImagingHybrid",:libvtkImagingHybrid),
    LibraryProduct("libvtkImagingMath",:libvtkImagingMath),
    LibraryProduct("libvtkImagingMorphological",:libvtkImagingMorphological),
    LibraryProduct("libvtkImagingSources",:libvtkImagingSources),
    LibraryProduct("libvtkImagingStatistics",:libvtkImagingStatistics),
    LibraryProduct("libvtkImagingStencil",:libvtkImagingStencil),
    LibraryProduct("libvtkInteractionImage",:libvtkInteractionImage),
    LibraryProduct("libvtkInteractionStyle",:libvtkInteractionStyle),
    LibraryProduct("libvtkInteractionWidgets",:libvtkInteractionWidgets),
    LibraryProduct("libvtkIOCore",:libvtkIOCore),
    LibraryProduct("libvtkIOImage",:libvtkIOImage),
    LibraryProduct("libvtkIOLegacy",:libvtkIOLegacy),
    LibraryProduct("libvtkIOMovie",:libvtkIOMovie),
    LibraryProduct("libvtkIOOggTheora",:libvtkIOOggTheora),
    LibraryProduct("libvtkIOXML",:libvtkIOXML),
    LibraryProduct("libvtkIOXMLParser",:libvtkIOXMLParser),
    LibraryProduct("libvtkmetaio",:libvtkmetaio),
    LibraryProduct("libvtkogg",:libvtkogg),
    LibraryProduct("libvtkParallelCore",:libvtkParallelCore),
    LibraryProduct("libvtkParallelDIY",:libvtkParallelDIY),
    LibraryProduct("libvtkpugixml",:libvtkpugixml),
    LibraryProduct("libvtkRenderingAnnotation",:libvtkRenderingAnnotation),
    LibraryProduct("libvtkRenderingContext2D",:libvtkRenderingContext2D),
    LibraryProduct("libvtkRenderingContextOpenGL2",:libvtkRenderingContextOpenGL2),
    LibraryProduct("libvtkRenderingCore",:libvtkRenderingCore),
    LibraryProduct("libvtkRenderingFreeType",:libvtkRenderingFreeType),
    LibraryProduct("libvtkRenderingImage",:libvtkRenderingImage),
    LibraryProduct("libvtkRenderingLabel",:libvtkRenderingLabel),
    LibraryProduct("libvtkRenderingLOD",:libvtkRenderingLOD),
    LibraryProduct("libvtkRenderingOpenGL2",:libvtkRenderingOpenGL2),
    LibraryProduct("libvtkRenderingUI",:libvtkRenderingUI),
    LibraryProduct("libvtkRenderingVolume",:libvtkRenderingVolume),
    LibraryProduct("libvtkRenderingVolumeOpenGL2",:libvtkRenderingVolumeOpenGL2),
    LibraryProduct("libvtksys",:libvtksys),
    LibraryProduct("libvtktheora",:libvtktheora),
    LibraryProduct("libvtkViewsCore",:libvtkViewsCore)
    #    LibraryProduct("libvtkloguru",:libvtkloguru): logging is off.
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "GLEW_jll",
    "Xorg_libXi_jll",
    "Xorg_libXtst_jll",
    "Xorg_libXt_jll",
    "Xorg_libICE_jll",
    "Xorg_libSM_jll",
    "Libtiff_jll",
    "JpegTurbo_jll",
    "libpng_jll",
    "Zlib_jll",
    "FreeType2_jll",
    "Expat_jll",
    "Lz4_jll",
    "XZ_jll",
]

# Build the tarballs, and possibly a `build.jl` as well.
# On older compiler versions there were errors when cross-compiling.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies,
               preferred_gcc_version=v"9")
 
