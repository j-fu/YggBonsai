#!/bin/sh
exec julia --color=yes build_tarballs_vtk90.jl --verbose --debug --deploy=j-fu/VTKMinimal_jll.jl
