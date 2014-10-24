when defined(windows):
    const soname = "libsndfile.dll"
elif defined(macosx):
    const soname = "libsndfile.dylib"
else:
    const soname = "libsndfile.so(|.1)"

{.pragma: libsnd, cdecl, dynlib: soname.}


type
    TSNDFILE* = cint

    TFILE_MODE* = enum
        READ    = cint(0x10),
        WRITE   = cint(0x20),
        RDWR    = cint(0x30)

    TCOUNT* = int64

    TINFO* {.pure final.} = object
        frames*: TCOUNT
        samplerate*: cint
        channels*: cint
        format*: cint
        sections*: cint
        seekable*: cint

    TBOOL* = enum
        SF_FALSE    = cint(0),
        SF_TRUE     = cint(1)

    TWHENCE* = enum
        SEEK_SET    = cint(0), # The offset is set to the start of the audio data plus offset (multichannel) frames.
        SEEK_CUR    = cint(1), # The offset is set to its current location plus offset (multichannel) frames.
        SEEK_END    = cint(2)  # The offset is set to the end of the data plus offset (multichannel) frames.


proc open*(path: cstring, mode: TFILE_MODE, sfinfo: ptr TINFO): ptr TSNDFILE  {.libsnd, importc: "sf_open".}

proc format_check*(info: ptr TINFO): TBOOL {.libsnd, importc: "sf_format_check".}

proc seek*(sndfile: ptr TSNDFILE, frames: TCOUNT, whence: TWHENCE): TCOUNT {.libsnd, importc: "sf_seek".}

proc read_int*(sndfile: ptr TSNDFILE, buffer_ptr: ptr cint, items: TCOUNT): TCOUNT {.libsnd, importc: "sf_read_int".}

proc readf_short*(sndfile: ptr TSNDFILE, buffer_ptr: ptr cshort, frames: TCOUNT): TCOUNT {.libsnd, importc: "sf_readf_short".}

proc read_float*(sndfile: ptr TSNDFILE, buffer_ptr: ptr cfloat, items: TCOUNT): TCOUNT {.libsnd, importc: "sf_read_float".}

proc error*(sndfile: ptr TSNDFILE): cint {.libsnd, importc: "sf_error".}

proc strerror*(sndfile: ptr TSNDFILE): cstring {.libsnd, importc: "sf_strerror".}


when isMainModule:
    var info: TINFO
    var sndfile: ptr TSNDFILE
    info.format = 0

    snd_file = open("test.wav", READ, cast[ptr TINFO](info.addr))
    
    echo info
    # expect info to match snd file header
    echo format_check(cast[ptr TINFO](info.addr))
    
    # expect 5
    echo seek(snd_file, 5, SEEK_SET)
    discard seek(snd_File, 0, SEEK_SET)
    
    let num_items = cast[cint](info.channels * info.frames)
    echo num_items
    var buffer = newSeq[cint](num_items)
    let items_read = read_int(snd_file, buffer[0].addr, num_items)
    echo items_read

