module Theremin

#--------------------- Imports ----------------#
using FileIO: load, save, loadstreaming, savestreaming
using LibSndFile
using SampledSignals
using DSP
using Statistics

include("base.jl")



export load_aud, mono, resample
export getduration
export getsamplerate
export getnframes
export trim
export addsilence
export addnoise


end # module
