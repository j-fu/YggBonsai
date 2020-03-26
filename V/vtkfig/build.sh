#!/bin/sh

#exec julia --color=yes build_tarballs.jl --verbose --debug 
exec julia --color=yes build_tarballs.jl --verbose --debug --deploy-jll=j-fu/vtkfig_jll.jl
