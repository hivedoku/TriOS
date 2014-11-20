{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                               Propeller Signal Generator v1.2 (C) 2012 Johannes Ahlebrand                                    │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                    TERMS OF USE: Parallax Object Exchange License                                            │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}
CON MUTE = 14, SAW = 16, TRIANGLE = 18, SQUARE = 22, NOISE = 25, SINE = 32, USER = 42, PW50 = 1<<31, PW25 = 1<<30, PW12_5 = 1<<29, freqRef = 536870912 
  
VAR                 
  byte cog
  long waveform, frequency, damplevel, pulseWidth, userWaveformP, userWaveformSize

PUB start(outPin, invertedPin, syncPin)
' ┌──────────────────────────────────────────────────────────────┐
' │                  Starts PSG in a single cog                  │
' ├──────────────────────────────────────────────────────────────┤ 
' │ outPin      - The pin to output the signal on                │
' │ invertedPin - The pin to output the inverted signal on       │
' │ syncPin     - The pin to output the synchronization signal on│
' └──────────────────────────────────────────────────────────────┘
  stop
  waveform   := MUTE  
  regCounter := $1C000000 | outPin | (invertedPin<<9)
  noiseValue := $10000000 '| syncPin
  delayLine  := (1<<invertedPin) | (1<<outPin) '| (1<<syncPin)
  cog        := cognew(@PSG, @waveform) + 1
       
PUB stop
' ┌──────────────────────────────────────────────────────────────┐
' │                         Stops PSG                            │
' └──────────────────────────────────────────────────────────────┘
  if cog
    cogstop(cog~ -1)
    cog := 0

PUB setWaveform(waveformType)
' ┌──────────────────────────────────────────────────────────────┐
' │                      Set waveform type                       │
' ├──────────────────────────────────────────────────────────────┤
' │ waveformType - Which waveform from the list below to use     │
' │                                                              │ 
' │ #MUTE     = No signal                                        │
' │ #SAW      = Saw wave                                         │
' │ #TRIANGLE = Triangle wave                                    │
' │ #SQUARE   = Square wave                                      │
' │ #NOISE    = Noise wave                                       │
' │ #SINE     = Sine wave                                        │ 
' │ #USER     = User definable waveform                          │
' └──────────────────────────────────────────────────────────────┘
  waveform := waveformType

PUB setFrequency(freq)
' ┌──────────────────────────────────────────────────────────────┐
' │                       Set frequency                          │
' ├──────────────────────────────────────────────────────────────┤
' │ freq - The frequency in hertz (0 Hz to 7500000 Hz)           │
' └──────────────────────────────────────────────────────────────┘
  setFrequencyCentiHertz(freq * 100)

PUB setFrequencyCentiHertz(freq)
' ┌──────────────────────────────────────────────────────────────┐
' │                       Set frequency                          │
' ├──────────────────────────────────────────────────────────────┤
' │ freq - The frequency in centi hertz (0 Hz to 750000000 cHz)  │
' └──────────────────────────────────────────────────────────────┘
  frequency := freqRef / (1000000000 / freq)
  
PUB setPulseWidth(pulseWidthVal)
' ┌──────────────────────────────────────────────────────────────┐
' │               Set the pulse width (square only)              │
' ├──────────────────────────────────────────────────────────────┤
' │ pulseWidthVal - The 32 bit pulse width value                 │
' │                                                              │
' │ Predefined pulse widths                                      │
' │ ───────────────────────                                      │
' │ #PW50   = 50%    (1<<31)                                     │
' │ #PW25   = 25%    (1<<30)                                     │
' │ #PW12_5 = 12.5%  (1<<29)                                     │
' └──────────────────────────────────────────────────────────────┘
  pulseWidth := pulseWidthVal

PUB setDampLevel(dampLev)
' ┌──────────────────────────────────────────────────────────────┐
' │                       Set damp level                         │
' ├──────────────────────────────────────────────────────────────┤ 
' │ dampLev - The damp level (Each step equals 6 dB)             │
' └──────────────────────────────────────────────────────────────┘
  damplevel := dampLev

PUB setUserWaveform(address, size)
' ┌──────────────────────────────────────────────────────────────┐
' │                 Set user definable waveform                  │
' ├──────────────────────────────────────────────────────────────┤ 
' │ address - The address to the waveform in memory              │
' │ size    - The size of the waveform (2^size)                  │
' └──────────────────────────────────────────────────────────────┘
  userWaveformP    := address
  userWaveformSize := 31 - size

PUB setParameters(waveformType, frequencyInHertz, dampLev, pulseWidthValue)
' ┌──────────────────────────────────────────────────────────────┐
' │       A convenient method to set all parametes at once       │
' └──────────────────────────────────────────────────────────────┘
  setWaveform(waveformType)
  setFrequency(frequencyInHertz)
  setPulseWidth(pulseWidthValue)
  setDampLevel(dampLev)

DAT           org 0
PSG           mov       ctra, regCounter                   
out           mov       ctrb, noiseValue
waitCounter   mov       dira, delayLine
'─────────────────────────────────────────────────────────── 
mainLoop      cmp       :par, stopValue                   wz
        if_z  movd      :par, #waveform_
        if_z  mov       regCounter, par                    
:par          rdlong    waveform_ + 6, regCounter        
              add       :par, val512                        
              add       regCounter, #4   
              sar       out, damplevel_                     
              add       out, dcOffset   
              mov       frqa, out                          
              mov       frqb, frequency_               
              jmp       waveform_                       
'───────────────────────────────────────────────────────────
Mute_         mov       out, #0                             
              jmp       #mainLoop
Saw_          mov       out, phsb                
              jmp       #mainLoop
Triangle_     absneg    out, phsb                
              shl       out, #1                           wc
              sub       out, dcOffset
              jmp       #mainLoop
Square_       sub       pulseWidth_, phsb             nr, wc   
              negc      out, maxAmplitude                     
              jmp       #mainLoop
Noise_        mov       out, noiseValue
              mov       delayLine, phsb               nr, wc
              rcr       delayLine, #16         
              cmp       delayLine, cmpVal                 wz
        if_z  add       noiseValue, cnt
        if_z  ror       noiseValue, noiseValue
              jmp       #mainLoop
Sine_         mov       out, phsb                         wc
              shr       out, #19            
              test      out, sin_90                       wz      
              negnz     out, out             
              or        out, sin_table      
              shl       out, #1            
              rdword    out, out         
              negc      out, out            
              shl       out, #15
              jmp       #mainLoop               
User_         mov       out, phsb            
              shr       out, userWaveformSize_           
              add       out, userWaveformP_      
              rdword    out, out         
              shl       out, #16
              jmp       #mainLoop
'─────────────────────────────────────────────────────────── 
stopValue               rdlong waveform_ + 6, regCounter   
sin_90                  long $0800
sin_table               long $E000>>1
cmpVal                  long $FFFF
dcOffset                long 1<<31
maxAmplitude            long(1<<31)-1
val512                  long 1<<9 
regCounter              long 1                         
noiseValue              long 1                                
delayLine               long 1
waveform_               res  1 
frequency_              res  1
damplevel_              res  1
pulseWidth_             res  1
userWaveformP_          res  1
userWaveformSize_       res  1
