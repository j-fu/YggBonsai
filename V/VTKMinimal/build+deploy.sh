#!/bin/sh
exec julia --color=yes build_tarballs.jl --verbose --debug --deploy=j-fu/VTKMinimal_jll.jl

