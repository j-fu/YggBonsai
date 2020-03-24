#!/bin/sh

#exec julia --color=yes build_tarballs.jl --verbose --debug 
exec julia --color=yes build_tarballs.jl --verbose --debug --deploy=j-fu/vtkfig_jll.jl
