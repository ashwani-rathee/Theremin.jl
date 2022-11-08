
"""
    load_aud(
        filename::String,
        sr::Int = 44100,
        monocheck::Bool = true,
        offset = 0.0, #0.2
        duration = nothing,
        dtype = Float32,
    )

Supported formats: OGG,Flac, WAV and need to check others
returns a matrix of audio data and its samplerate

### Arguments
- `filename`: the path to the audio file
- `sr`: the desired samplerate
- `monocheck`: if true, the function will check if the file is mono or stereo
- `offset`: the offset in seconds to start reading the audio file
- `duration`: the duration in seconds to read the audio file, this will be till offset+ duration 
- `dtype`: the desired data type of the audio data

### Example
```jl
using Theremin

y, sr = load_aud("test/testaudios/test_440left_880right_0.5amp.wav", 22100)
```
## write about supported formats
## possible inputs
"""
function load_aud(
    filename::String,
    sr::Int = 44100,
    monocheck::Bool = true,
    offset = 0.0, #in seconds
    duration = nothing,
    dtype = Float32,
)
    audio = load(filename)
    # @info "Number of channels in audio: $(nchannels(audio))"

    start = Int64.(offset * sr) + 1

    # to end decide
    if duration === nothing
        end1 = size(audio.data)[1]
    elseif duration !== nothing && duration < length(audio.data) && duration > 1
        end1 = Int64.(offset * sr + duration * sr)
    else
        end1 = size(length(audio.data))[1]
    end

    y = dtype.(audio.data)[start:end1, :]
    initsr = audio.samplerate

    # check if we need to convert to mono
    if monocheck == true && nchannels(y) > 1
        y = mono(y)
    end

    # check if we need to resample
    if initsr != sr && nchannels(y) == 1
        # this will fail when the audio is not mono
        @show "Resampling from $(initsr) to $(sr)"
        y = resample(y[:], sr)
        initsr = sr
    end

    audio = nothing
    return y, initsr
end

"""
    resample(audio, samplerate)

returns resample audio according to samplerate

### Arguments
- `audio`: the audio data received from load_aud
- `samplerate`: the desired samplerate

```jl
using Theremin

y, sr = load_aud("test/testaudios/test_440left_880right_0.5amp.wav")
y = resample(y, sr/2)
```
"""
function resample(y, samplerate)
    data = DSP.resample(y, samplerate)
    return data
end

"""
    mono(y)

returns mono audio from stereo audio by averaging the samples from the channels

### Arguments
- `y`: the audio data received from load_aud

### Example
```jl
using Theremin
y,sr = load_aud("test/testaudios/test_440left_880right_0.5amp.wav", 22100, false) # get stereo audio

y = mono(y)
````
"""
function mono(y)
    monodata = mean(y, dims = 2)
    return monodata
end

"""
    getduration(filename)

returns the duration of the audio in seconds from a filename

### Arguments
- `filename`: the path to the audio file

### Example

```jl
using Theremin

dur = getduration("test/testaudios/test_440left_880right_0.5amp.wav")
```
"""
function getduration(filename)
    audio = load(filename)
    return size(audio.data)[1] / audio.samplerate
end


"""
    getduration(y, sr)

returns duration of the file from y and samplerate


### Arguments
- `filename`: the path to the audio file

### Example

```jl
using Theremin

dur = getduration(y, sr) # results in seconds
```
"""
function getduration(y, sr)
    return size(y)[1] / sr
end

"""
    getsamplerate(filename::string)

returns the sample rate of the audio file

### Arguments
- `filename`: the path to the audio file

### Example

```jl
using Theremin

dur = getsamplerate("test/testaudios/test_440left_880right_0.5amp.wav") #results in hertz
```

"""
function getsamplerate(filename)
    audio = load(filename)
    return audio.samplerate
end


"""
    getnframes(filename)

returns the number of frames in the audio file

### Arguments
- `filename`: the path to the audio file

### Example

```jl
using Theremin

frames = getnframes("test/testaudios/test_440left_880right_0.5amp.wav") #100 in this one
```

"""
function getnframes(filename::String)
    audio = load(filename)
    return nframes(audio)
end

"""
    getnframes(y::Array)

returns number of frames in a audio array

### Arguments
- `y`: the audio data received from load_aud

### Example

```jl
using Theremin

y,sr = load_aud("test/testaudios/test_440left_880right_0.5amp.wav", 22100, false)
frames = getnframes(y) #100 in this one
```

"""
function getnframes(y::Array)
    return size(y)[1]
end

"""
    trim(y, sr, duration)

returns trimmed audio from y and sr with given duration

### Arguments
- `y`: the audio data received from load_aud
- `sr`: the samplerate of the audio
- `duration`: the duration in seconds to trim to

### Example

```jl
using Theremin

y,sr = load_aud("test/testaudios/test_440left_880right_0.5amp.wav")
y1 = trim(y, 44100, 0.001) # half the time of the original
y2 = trim(y, 44100, 0.005) # time more than y length
```
"""
function trim(y, sr, duration)
    if duration > 0.0 && duration * sr < getnframes(y)
        start = 1
        end1 = Int64.(floor(duration * sr))
        y = y[start:end1, :]
        return y
    else
        return y
    end
end

"""
    trim(y, sr, t1, t2)

returns trimmed audio from y and sr with given duration from t1 and t2

### Arguments
- `y`: the audio data received from load_aud
- `sr`: the samplerate of the audio
- `y1`: the start time in seconds
- `y2`: the end time in seconds

### Example

```jl
using Theremin

y,sr = load_aud("test/testaudios/test_440left_880right_0.5amp.wav")
y = trim(y,sr, 0.0015, 0.002)
```
"""
function trim(y, sr, t1, t2)
    if t2 > 0.0 && t2 * sr < getnframes(y) && t1 > 0.0 && t1 < t2
        start = Int64.(floor(t1 * sr))
        end1 = Int64.(floor(t2 * sr))
        y = y[start:end1, :]
        return y
    else
        return y
    end
end

"""
    addsilence(y, sr, loc="back", duration)

## Restricted this to mono channel inputs
returns audio y with added silence at the back or front

### Arguments
- `y`: the audio data received from load_aud
- `sr`: the samplerate of the audio
- `loc`: the location to add the silence
- `duration`: the duration in seconds for final audio

### Example
```jl
using Theremin

y, sr = load_aud("test/testaudios/test_440left_880right_0.5amp.wav")
silend = addsilence(y, sr, 0.003, "back") # adds to end of audio
silfront =  addsilence(y, sr,0.003, "front") # adds to front of audio
```
"""
function addsilence(y, sr, duration, loc = "back")
    if loc == "back" && duration * sr > getnframes(y) && nchannels(y) == 1
        left = duration * sr - getnframes(y)
        frontadd = reshape(zeros(Float32, Int64.(floor(left))), :, 1)
        y = vcat(y, frontadd)
    elseif loc == "front" && duration * sr > getnframes(y) && nchannels(y) == 1
        left = duration * sr - getnframes(y)
        frontadd = reshape(zeros(Float32, Int64.(floor(left))), :, 1)
        y = vcat(frontadd, y)
    else
        return y
    end
end

"""
    addnoise(y, sr, duration, loc="back")

returns audio y with added noise at the back or front and works on mono only rn

### Arguments
- `y`: the audio data received from load_aud
- `sr`: the samplerate of the audio
- `loc`: the location to add the noise
- `duration`: the duration in seconds for final audio

### Example

```jl
using Theremin

y, sr = load_aud("test/testaudios/test_440left_880right_0.5amp.wav")
noise = addnoise(y, sr, 0.003, "back") # adds to end of audio
noisefront =  addnoise(y, sr,0.003, "front") # adds to front of audio

```
"""
function addnoise(y, sr, duration, loc = "back")
    if loc == "back" && duration * sr > getnframes(y) && nchannels(y) == 1
        left = duration * sr - getnframes(y)
        frontadd = rand(Float32, (Int64.(floor(left)), 1))
        y = vcat(y, frontadd)
    elseif loc == "front" && duration * sr > getnframes(y) && nchannels(y) == 1
        left = duration * sr - getnframes(y)
        frontadd = rand(Float32, (Int64.(floor(left)), 1))
        y = vcat(frontadd, y)
    else
        return y
    end
end
