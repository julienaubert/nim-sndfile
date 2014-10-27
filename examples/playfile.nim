# Read a audio file (e.g. WAV or Ogg Vorbis) with libsndfile and play it with sdl2

import sndfile
import sdl2, sdl2/audio
import os, math

if paramCount() != 1:
  echo("Usage: playfile <filename>")
  quit(-1)
var 
  Filename = paramStr(1)

# Get libsndfile version

var s: array[20, char]
discard command(nil, SFC_GET_LIB_VERSION, s[0].addr, 20)
echo("Version: " & $s)

# Open the file
  
var Info: TINFO
var File = sndfile.open(Filename, sndfile.READ, Info.addr)
if File == nil:
  echo($file.strerror())
  quit(-1)

echo("Channels: " & $Info.channels)
echo("Frames: " & $Info.frames)
echo("Samplerate: " & $Info.samplerate)
echo("Format: " & $Info.format)

# Callback procedure for audio playback

const BufferSizeInSamples = 4096
proc AudioCallback(userdata: pointer; stream: ptr uint8; len: cint) {.cdecl.} = 
  var buffer: array[BufferSizeInSamples, cfloat]
  let count = file.read_float(addr(buffer[0]), BufferSizeInSamples)
  if count == 0:
    echo("End of file reached")
    quit(0)
  for i in 0..count - 1:
    cast[ptr int16](cast[int](stream) + i * 2)[] = int16(round(buffer[i] / 1.25 * 32760))
    # Without the divisor of 1.25, the sound gets distorted for my ogg example file

# Init audio playback

if Init(INIT_AUDIO) != SdlSuccess:
  echo("Couldn't initialize SDL")
  quit(-1)
var AudioSpec: TAudioSpec
AudioSpec.freq = Info.samplerate
AudioSpec.format = AUDIO_S16
AudioSpec.channels = Info.channels.uint8
AudioSpec.samples = BufferSizeInSamples
AudioSpec.padding = 0
AudioSpec.callback = AudioCallback
AudioSpec.userdata = nil
if OpenAudio(addr(audioSpec), nil) != 0:
  echo("Couldn't open audio device. " & $GetError() & "\n")
  quit(-1)

# Start playback and wait in a loop
PauseAudio(0)
echo("Playing...")
while true:
  Delay(100)
