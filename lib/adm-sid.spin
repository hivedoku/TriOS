{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                            SIDcog - SID/MOS8580 emulator v1.3 (C) 2012 Johannes Ahlebrand                                    │                                                            
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


Revision History

v0.7 (December 2009) - Initial release

v0.8 (February 2010) - Added support for "combined waveforms"
                     - Optimized code
                     - Fixed bugs
                       
v1.0 (May 2011)      - First OBEX release
                     - Added convenient API methods

v1.2 (August 2011)   - Increased ADSR accuracy  (Almost perfect now; The famous ADSR bug isn't implemented though)
                     - Increased Noise accuracy (As close as we will get without decreasing the sample rate of SIDcog)
                     - Fixed a bug when no waveform was selected
                     - Decreased the "max cutoff frequency" a bit to fix aliasing issues
                     - Made some small optimizations 

v1.3 (April 2012)    - Fixed a bug when noise + any other waveform was selected at the same time
                     - Calibrated the cutoff frequency to better match a real 8580
                     - Cycle optimized code to "make room" for the point below 
                     - Increased resonance accuracy (replaced "4 step logaritmic lookup table" with "16 step bit linear multiplication")
                     - Increased ADSR accuracy a little bit more (the ADSR bug is still not implemented)

} 
CON  PAL = 985248.0, NTSC = 1022727.0, MAXF = 1031000.0, TRIANGLE = 16, SAW = 32, SQUARE = 64, NOISE = 128   
#24,    HBEAT
  C64_CLOCK_FREQ   = PAL
  '                                  ___ 
  RESONANCE_OFFSET = 6'                 │
  RESONANCE_FACTOR = 5'                 │
  CUTOFF_LIMIT     = 1100'              │
  LP_MAX_CUTOFF    = 11'                │ Don't alter these constants unless you know what you are doing! 
  BP_MAX_CUTOFF    = 10'                │
  FILTER_OFFSET    = 12'                │
  START_LOG_LEVEL  = $5d5d5d5d'         │
  DECAY_DIVIDE_REF = $6C6C6C6C'         │   
  ENV_CAL_FACTOR   = 545014038.181330'  │ ENV_CAL_FACTOR = (MaxUint32  / SIDcogSampleFreq) / (1 / SidADSR_1secRomValue)   
  NOISE_ADD        = %1010_1010_101<<23'│ ENV_CAL_FACTOR = (4294967295 / 30789           ) / (1 / 3907                ) = 545014038,181330
  NOISE_TAP        = %100001 << 8'   ___│
LED_OPEN     = HBEAT
PUB start(right, left)
' ┌──────────────────────────────────────────────────────────────┐
' │               Starts SIDcog in a single cog                  │
' ├──────────────────────────────────────────────────────────────┤
' │ Returns a pointer to the first SID register in hub memory    │
' │ on success; otherwise returns 0.                             │
' │                                                              │ 
' │ right - The pin to output the right channel to. 0 = Not used │
' │                                                              │
' │ left - The pin to output the left channel to. 0 = Not used   │
' └──────────────────────────────────────────────────────────────┘
  arg1 := $18000000 | left
  arg2 := $18000000 | right
  r1 := ((1<<right) | (1<<left))&!1
  sampleRate := clkfreq/trunc(C64_CLOCK_FREQ/32.0) 
  combTableAddr := @combinedWaveforms 
  cog := cognew(@SIDEMU, @ch1_frequencyLo) + 1

  if cog
    return @ch1_frequencyLo
  else
    return 0

PUB stop
' ┌──────────────────────────────────────────────────────────────┐
' │                        Stops SIDcog                          │
' └──────────────────────────────────────────────────────────────┘
  if cog
    cogstop(cog~ -1)
    cog := 0

PUB setRegister(reg, val) 
' ┌──────────────────────────────────────────────────────────────┐
' │           Sets a single SID register to a value              │
' ├──────────────────────────────────────────────────────────────┤
' │ reg - The SID register to set.                               │
' │                                                              │
' │ val - The value to set the register to.                      │
' └──────────────────────────────────────────────────────────────┘
  byte[@ch1_frequencyLo + (reg + (reg/7))] := val
  
PUB updateRegisters(source)
' ┌──────────────────────────────────────────────────────────────┐
' │                 Update all 25 SID registers                  │
' ├──────────────────────────────────────────────────────────────┤
' │ source - A pointer to an array containing 25 bytes to update │
' │          the 25 SID registers with.                          │
' └──────────────────────────────────────────────────────────────┘
  bytemove(@ch1_frequencyLo, source, 7) 
  bytemove(@ch1_frequencyLo + 8 , source + 7 , 7)
  bytemove(@ch1_frequencyLo + 16, source + 14, 7)
  bytemove(@ch1_frequencyLo + 24, source + 21, 4)

PUB resetRegisters
' ┌──────────────────────────────────────────────────────────────┐
' │                 Reset all 25 SID registers                   │
' └──────────────────────────────────────────────────────────────┘
  bytefill(@ch1_frequencyLo, 0, 25)
  
PUB setVolume(volumeValue)
' ┌──────────────────────────────────────────────────────────────┐
' │                    Sets the main volume                      │
' ├──────────────────────────────────────────────────────────────┤
' │ value - A value betwen 0 and 15.                             │
' └──────────────────────────────────────────────────────────────┘
  byte[@Volume] := (byte[@Volume]&$F0) | (volumeValue&$0F)  

PUB play(channel, freq, waveform, attack, decay, sustain, release) | offs
' ┌──────────────────────────────────────────────────────────────┐
' │                Plays a tone in a SID channel.                │
' ├──────────────────────────────────────────────────────────────┤
' │ channel - The SID channel to use. (0 - 2)                    │
' │                                                              │
' │ freq - The 16 bit frequency value use. (0 - 65535)           │
' │ (The SID can output tone frequencies from 0 - 3.9 kHz)       │
' │                                                              │
' │ waveform - The waveform combination to use.                  │
' │ e.g. sid.play(x, x, sid#SQUARE | sid#SAW, x, x, x, x)        │
' │                                                              │
' │ attack - The attack value. (0 - 15)                          │
' │                                                              │
' │ decay - The decay value. (0 - 15)                            │
' │                                                              │
' │ sustain - The sustain value. (0 - 15)                        │
' │                                                              │
' │ release - The release value. (0 - 15)                        │
' ├──────────────────────────────────────────────────────────────┤
' │ - When calling this method, the envelope generator enters the│
' │ "attack - decay - sustain" phase. Don't forget to call       │
' │ "noteOff" before using it so the envelope is in release phase│
' └──────────────────────────────────────────────────────────────┘
!outa[LED_OPEN]
  offs := channel<<3
  word[@ch1_frequencyLo + offs] := freq   
  byte[@ch1_attackDecay + offs] := (decay&$F) | ((attack&$F)<<4)
  byte[@ch1_sustainRelease + offs] := (release&$F) | ((sustain&$F)<<4) 
  byte[@ch1_controlRegister + offs] := (byte[@ch1_controlRegister + offs]&$0F) | waveform | 1

PUB noteOn(channel, freq) | offs
' ┌──────────────────────────────────────────────────────────────┐
' │                Plays a tone in a SID channel                 │
' ├──────────────────────────────────────────────────────────────┤
' │ channel - The SID channel to use. (0 - 2)                    │
' │                                                              │
' │ freq - The 16 bit frequency value use. (0 - 65535)           │
' │ (The SID can output tone frequencies from 0 - 3.9 kHz)       │
' ├──────────────────────────────────────────────────────────────┤
' │ - Don't forget to set the envelope values for the channel    │
' │ before using this method.                                    │ 
' │                                                              │
' │ - Make sure you have set the waveform for the channel before │
' │ using this method.                                           │
' │                                                              │ 
' │ - When calling this method, the envelope generator enters the│
' │ "attack - decay - sustain" phase. Don't forget to call       │
' │ "noteOff" before calling this method to set the envelope to  │
' │ release phase.                                               │
' └──────────────────────────────────────────────────────────────┘
!outa[LED_OPEN]
  offs := channel<<3
  byte[@ch1_controlRegister + offs] := (byte[@ch1_controlRegister+offs]&$FE) | 1 
  word[@ch1_frequencyLo + offs] := freq
  
PUB noteOff(channel)
' ┌──────────────────────────────────────────────────────────────┐
' │  Sets the envelope generator of a channel to release phase   │
' ├──────────────────────────────────────────────────────────────┤
' │ channel - The SID channel to use. (0 - 2)                    │
' └──────────────────────────────────────────────────────────────┘
  byte[@ch1_controlRegister + (channel<<3)] &= $FE

PUB setFreq(channel, freq)
' ┌──────────────────────────────────────────────────────────────┐
' │             Sets the frequency of a SID channel              │
' ├──────────────────────────────────────────────────────────────┤
' │ channel - The SID channel to use. (0 - 2)                    │
' │                                                              │ 
' │ freq - The 16 bit frequency value. (0 - 65535)               │
' │ (The SID can output tone frequencies from 0 - 3.9 kHz)       │
' └──────────────────────────────────────────────────────────────┘
  word[@ch1_frequencyLo + (channel<<3)] := freq

PUB setWaveform(channel, waveform) | offs  
' ┌──────────────────────────────────────────────────────────────┐
' │             Sets the waveform of a SID channel               │
' ├──────────────────────────────────────────────────────────────┤
' │ channel - The SID channel to use. (0 - 2)                    │
' │                                                              │ 
' │ waveform - The waveform combination to use.                  │
' │ e.g. sid.setWaveform(x, sid#SQUARE | sid#SAW)                │
' └──────────────────────────────────────────────────────────────┘ 
  offs := channel<<3
  byte[@ch1_controlRegister+offs] := (byte[@ch1_controlRegister + offs]&$0F) | waveform 
      
PUB setPWM(channel, pulseWidth)
' ┌──────────────────────────────────────────────────────────────┐
' │           Sets the pulse width of a SID channel              │
' ├──────────────────────────────────────────────────────────────┤
' │ channel - The SID channel to use. (0 - 2)                    │
' │                                                              │ 
' │ pulseWidth - The 12 bit pulse width value to use. (0 - 4095) │
' │ e.g. sid.setWaveform(x, sid#SQUARE | sid#SAW)                │
' ├──────────────────────────────────────────────────────────────┤  
' │ - The pulse width value affects square waves ONLY.           │
' └──────────────────────────────────────────────────────────────┘ 
  word[@ch1_pulseWidthLo + (channel<<3)] := pulseWidth 
     
PUB setADSR(channel, attack, decay, sustain, release) | offs
' ┌──────────────────────────────────────────────────────────────┐
' │         Sets the envelope values of a SID channel            │
' ├──────────────────────────────────────────────────────────────┤
' │ channel - The SID channel to use. (0 - 2)                    │
' │                                                              │
' │ attack - The attack value. (0 - 15)                          │
' │                                                              │
' │ decay - The decay value. (0 - 15)                            │
' │                                                              │
' │ sustain - The sustain value. (0 - 15)                        │
' │                                                              │
' │ release - The release value. (0 - 15)                        │
' └──────────────────────────────────────────────────────────────┘
  offs := channel<<3
  byte[@ch1_attackDecay + offs] := (decay&$F) | ((attack&$F)<<4)
  byte[@ch1_sustainRelease + offs] := (release&$F) | ((sustain&$F)<<4) 

PUB setResonance(resonanceValue)
' ┌──────────────────────────────────────────────────────────────┐
' │           Sets the resonance value of the filter             │
' ├──────────────────────────────────────────────────────────────┤
' │ resonanceValue - The resonance value to use. (0 - 15)        │
' └──────────────────────────────────────────────────────────────┘
  byte[@Filter3] := (byte[@Filter3]&$0F) | (resonanceValue<<4)
  
PUB setCutoff(cutoffValue)
' ┌──────────────────────────────────────────────────────────────┐
' │          Sets the cutoff frequency of the filter             │
' ├──────────────────────────────────────────────────────────────┤
' │ cutoffValue - The 12 bit cutoff frequency value to use.        │
' └──────────────────────────────────────────────────────────────┘
  byte[@Filter1] := cutoffValue&$07
  byte[@Filter2] := (cutoffValue&$07F8)>>3

PUB setFilterMask(ch1, ch2, ch3)
' ┌──────────────────────────────────────────────────────────────┐
' │             Enable/Disable filtering on channels             │
' ├──────────────────────────────────────────────────────────────┤
' │ ch1 - Enable/Disable filter on channel 1. (True/False)       │
' │                                                              │
' │ ch2 - Enable/Disable filter on channel 2. (True/False)       │   
' │                                                              │
' │ ch3 - Enable/Disable filter on channel 3. (True/False)       │   
' └──────────────────────────────────────────────────────────────┘
  byte[@Filter3] := (byte[@Filter3]&$F0) | (ch1&1) | (ch2&2) | (ch3&4)

PUB setFilterType(lp, bp, hp)
' ┌──────────────────────────────────────────────────────────────┐
' │                 Enable/Disable filter types                  │
' ├──────────────────────────────────────────────────────────────┤
' │ lp - Enable/Disable lowpass filter. (True/False)             │
' │                                                              │
' │ bp - Enable/Disable bandpass filter. (True/False)            │   
' │                                                              │
' │ hp - Enable/Disable highpass filter. (True/False)            │   
' └──────────────────────────────────────────────────────────────┘
  byte[@volume] := (byte[@volume]&$0F) | (lp&16) | (bp&32) | (hp&64) 

PUB enableRingmod(ch1, ch2, ch3)
' ┌──────────────────────────────────────────────────────────────┐
' │          Enable/Disable ring modulation on channels          │
' ├──────────────────────────────────────────────────────────────┤
' │ ch1 - Enable/Disable ring modulation on ch 1. (True/False)   │
' │                                                              │
' │ ch2 - Enable/Disable ring modulation on ch 2. (True/False)   │  
' │                                                              │
' │ ch3 - Enable/Disable ring modulation on ch 3. (True/False)   │   
' ├──────────────────────────────────────────────────────────────┤ 
' │- Channel 3 modulates channel 1                               │
' │                                                              │
' │- Channel 1 modulates channel 2                               │
' │                                                              │ 
' │- Channel 2 modulates channel 3                               │  
' └──────────────────────────────────────────────────────────────┘
  byte[@ch1_controlRegister] := (byte[@ch1_controlRegister]&$FB) | (ch1&4)
  byte[@ch2_controlRegister] := (byte[@ch2_controlRegister]&$FB) | (ch2&4)
  byte[@ch3_controlRegister] := (byte[@ch3_controlRegister]&$FB) | (ch3&4)

PUB enableSynchronization(ch1, ch2, ch3)
' ┌──────────────────────────────────────────────────────────────┐
' │    Enable/Disable oscillator synchronization on channels     │
' ├──────────────────────────────────────────────────────────────┤
' │ ch1 - Enable/Disable synchronization on ch 1. (True/False)   │
' │                                                              │
' │ ch2 - Enable/Disable synchronization on ch 2. (True/False)   │  
' │                                                              │
' │ ch3 - Enable/Disable synchronization on ch 3. (True/False)   │   
' ├──────────────────────────────────────────────────────────────┤
' │- Channel 3 synchronizes channel 1                            │
' │                                                              │
' │- Channel 1 synchronizes channel 2                            │
' │                                                              │ 
' │- Channel 2 synchronizes channel 3                            │  
' └──────────────────────────────────────────────────────────────┘ 
  byte[@ch1_controlRegister] := (byte[@ch1_controlRegister]&$FD) | (ch1&2)
  byte[@ch2_controlRegister] := (byte[@ch2_controlRegister]&$FD) | (ch2&2)
  byte[@ch3_controlRegister] := (byte[@ch3_controlRegister]&$FD) | (ch3&2)
    
DAT org 0
'
'                Assembly SID emulator                      
'
SIDEMU        mov      dira, r1                     
              mov      ctra, arg1                          
              mov      ctrb, arg2
              mov      waitCounter, cnt                    
              add      waitCounter, sampleRate

'
' Read all SID-registers from hub memory and convert
' them to more convenient representations.
'
getRegisters  mov       tempValue, par                     ' Read in first long ( 16bit frequency / 16bit pulse-width )
              rdlong    frequency1, tempValue           
              mov       pulseWidth1, frequency1
              shl       pulseWidth1, #4                    ' Shift in "12 bit" pulse width value( make it 32 bits )
              andn      pulseWidth1, mask20bit 
              and       frequency1, mask16bit              ' Mask out 16 bit frequency value
              shl       frequency1, #13
'----------------------------------------------------------- 
              add       tempValue, #4                      ' Read in next long ( Control register / ADSR )
              rdlong    selectedWaveform1, tempValue
              mov       controlRegister1, selectedWaveform1
'----------------------------------------------------------- 
              mov       arg1, selectedWaveform1            '|   
              shr       arg1, #8                           '|
              call      #getADSR                           '|
              mov       decay1, r1                         '|
              call      #getADSR                           '|
              mov       attack1, r1                        '|  Convert 4bit ADSR "presets" to their corresponding  
              call      #getADSR                           '|  32bit values using attack/decay tables.
              mov       release1, r1                       '|
              mov       sustain1, arg1                     '|
              ror       sustain1, #4                       '|
              or        sustain1, arg1                     '|
              ror       sustain1, #4                       '|
'----------------------------------------------------------- 
              shr       selectedWaveform1, #4              '   Mask out waveform selection
              and       selectedWaveform1, #15 
'----------------------------------------------------------- 
              test      controlRegister1, #1            wc
              cmp       envelopeState1, #2              wz
 if_z_and_c   mov       envelopeState1, #0
 if_nz_and_nc mov       envelopeState1, #2           
 
'───────────────────────────────────────────────────────────
'                        Channel 2  
'───────────────────────────────────────────────────────────
              add       tempValue, #4                      ' Read in first long ( 16bit frequency / 16bit pulse-width )
              rdlong    frequency2, tempValue             
              mov       pulseWidth2, frequency2
              shl       pulseWidth2, #4                    ' Shift in "12 bit" pulse width value( make it 32 bits )
              andn      pulseWidth2, mask20bit  
              and       frequency2, mask16bit              ' Mask out 16 bit frequency value
              shl       frequency2, #13                      
'----------------------------------------------------------- 
              add       tempValue, #4                      ' Read in next long ( Control register / ADSR )
              rdlong    selectedWaveform2, tempValue
              mov       controlRegister2,  selectedWaveform2  
'----------------------------------------------------------- 
              mov       arg1, selectedWaveform2            '|   
              shr       arg1, #8                           '|
              call      #getADSR                           '|
              mov       decay2, r1                         '|
              call      #getADSR                           '|
              mov       attack2, r1                        '|  Convert 4bit ADSR "presets" to their corresponding
              call      #getADSR                           '|  32bit values using attack/decay tables. 
              mov       release2, r1                       '|
              mov       sustain2, arg1                     '|
              ror       sustain2, #4                       '| 
              or        sustain2, arg1                     '|
              ror       sustain2, #4                       '|  
'----------------------------------------------------------- 
              shr       selectedWaveform2, #4              '   Mask out waveform selection
              and       selectedWaveform2, #15 
'----------------------------------------------------------- 
              test      controlRegister2, #1            wc
              cmp       envelopeState2, #2              wz
 if_z_and_c   mov       envelopeState2, #0
 if_nz_and_nc mov       envelopeState2, #2           
 
'───────────────────────────────────────────────────────────
'                        Channel 3                          
'───────────────────────────────────────────────────────────
              add       tempValue, #4                      ' Read in first long ( 16bit frequency / 16bit pulse-width )
              rdlong    frequency3, tempValue              '
              mov       pulseWidth3, frequency3
              shl       pulseWidth3, #4                    ' Shift in "12 bit" pulse width value( make it 32 bits )
              andn      pulseWidth3, mask20bit   
              and       frequency3, mask16bit              ' Mask out 16 bit frequency value
              shl       frequency3, #13                      
'----------------------------------------------------------- 
              add       tempValue, #4                      ' Read in next long ( Control register / ADSR )
              rdlong    selectedWaveform3, tempValue
              mov       controlRegister3,  selectedWaveform3
'----------------------------------------------------------- 
              mov       arg1, selectedWaveform3            '|   
              shr       arg1, #8                           '|
              call      #getADSR                           '|
              mov       decay3, r1                         '|
              call      #getADSR                           '|
              mov       attack3, r1                        '|  Convert 4bit ADSR "presets" to their corresponding
              call      #getADSR                           '|  32bit values using attack/decay tables.    
              mov       release3, r1                       '|
              mov       sustain3, arg1                     '|
              ror       sustain3, #4                       '|
              or        sustain3, arg1                     '|     
              ror       sustain3, #4                       '|  
'----------------------------------------------------------- 
              shr       selectedWaveform3, #4              ' Mask out waveform selection
              and       selectedWaveform3, #15    
'----------------------------------------------------------- 
              test      controlRegister3, #1            wc
              cmp       envelopeState3, #2              wz
 if_z_and_c   mov       envelopeState3, #0
 if_nz_and_nc mov       envelopeState3, #2               
 
'───────────────────────────────────────────────────────────
'                      Filter / Volume  
'───────────────────────────────────────────────────────────
              add       tempValue, #4                      '|
              rdlong    filterControl, tempValue           '|
              mov       filterCutoff, filterControl        '|
'----------------------------------------------------------- 
              shr       filterControl, #16                 '|  Filter control
'-----------------------------------------------------------              
              shr       filterCutoff, #5                   '|
              andn      filterCutoff, #7                   '|
              mov       tempValue, filterControl           '|
              and       tempValue, #7                      '|  Filter cutoff frequency 
              or        filterCutoff, tempValue            '|
              and       filterCutoff, mask11bit            '|
              add       filterCutoff, filterOffset         '|
'----------------------------------------------------------- 
              mov       filterMode_Volume, filterControl   '|  Main volume and filter mode
              shr       filterMode_Volume, #8              '| 
'-----------------------------------------------------------
              mov       filterResonance,filterControl      '|
              and       filterResonance,#$F0               '|  Filter Resonance level 
              shr       filterResonance,#4                 '|

'
' Calculate sid samples channel 1-3 and store in out1-out3 
'
 
'───────────────────────────────────────────────────────────   
'    Increment phase accumulator 1-3 and handle syncing
'───────────────────────────────────────────────────────────  
SID           add      phaseAccumulator1, frequency1    wc ' Add frequency value to phase accumulator 1
  if_nc       andn     controlRegister2, #2
              test     controlRegister2, #10            wz ' Sync oscilator 2 to oscillator 1 if sync = on 
  if_nz       mov      phaseAccumulator2, #0               ' Or reset counter 2 when bit 4 of control register is 1
'-----------------------------------------------------------      
              add      phaseAccumulator2, frequency2    wc
  if_nc       andn     controlRegister3, #2
              test     controlRegister3, #10            wz ' Sync oscilator 3 to oscillator 2 if sync = on 
  if_nz       mov      phaseAccumulator3, #0               ' Or reset oscilator 3 when bit 4 of control register is 1
'-----------------------------------------------------------
              add      phaseAccumulator3, frequency3    wc
  if_nc       andn     controlRegister1, #2
              test     controlRegister1, #10            wz ' Sync oscilator 1 to oscillator 3 if sync = on 
  if_nz       mov      phaseAccumulator1, #0               ' Or reset oscilator 1 when bit 4 of control register is 1

'───────────────────────────────────────────────────────────  
'            Waveform shaping channel 1 -> arg1                           
'───────────────────────────────────────────────────────────
Saw1          cmp      selectedWaveform1, #2            wz
              mov      arg1, phaseAccumulator1
  if_z        jmp      #Envelope1   
'-----------------------------------------------------------  
Triangle1     cmp      selectedWaveform1, #1            wz, wc
  if_nz       jmp      #Square1
              shl      arg1, #1                         wc
  if_c        xor      arg1, mask32bit       
              test     controlRegister1, #4             wz '|
  if_nz       test     phaseAccumulator3, val31bit      wz '| These 3 lines handles ring modulation
  if_nz       xor      arg1, mask32bit                     '|
              jmp      #Envelope1   
'-----------------------------------------------------------  
Square1       cmp      selectedWaveform1, #4            wz
  if_z        sub      pulseWidth1, phaseAccumulator1   wc ' C holds the pulse width modulated square wave
  if_z        muxc     arg1, mask32bit
  if_z        jmp      #Envelope1  
'-----------------------------------------------------------  
Noise1        cmp      selectedWaveform1, #8            wz
  if_nz       jmp      #Combined1  
              and      arg1, mask28bit 
              sub      arg1, frequency1                 wc
              movi     arg1, noiseValue1
              add      arg1, noiseAddValue
  if_nc       jmp      #Envelope1 
              test     noiseValue1, noiseTap            wc 
              rcr      noiseValue1, #1  
              jmp      #Envelope1
'-----------------------------------------------------------                
Combined1     test     selectedWaveform1, #8            wz
              sub      selectedWaveform1, #4             
              mins     selectedWaveform1, #0             
              shl      selectedWaveform1, #8
              mov      tempValue, phaseAccumulator1
              shr      tempValue, #24
              add      selectedWaveform1, tempValue
              add      selectedWaveform1, combTableAddr
  if_nc_and_z rdbyte   arg1, selectedWaveform1
  if_nc_and_z shl      arg1, #24                         
  if_c_or_nz  mov      arg1, val31bit                
'───────────────────────────────────────────────────────────  
'            Envelope shaping channel 1 -> arg2           
'───────────────────────────────────────────────────────────    
Envelope1     mov      tempValue, decayDivideRef
              shr      tempValue, decayDivide1
              cmp      envelopeLevel1, tempValue        wc
              tjnz     envelopeState1, #Env_Dec1        nr
'----------------------------------------------------------- 
Env_At1 if_nc cmpsub   decayDivide1, #1                     
              add      envelopeLevel1, attack1          wc
  if_c        mov      envelopeLevel1, mask32bit         
  if_c        mov      envelopeState1, #1
              jmp      #Amplitude1
'----------------------------------------------------------- 
Env_Dec1 if_c add      decayDivide1, #1
              cmp      startLogLevel, envelopeLevel1    wc 
              cmp      envelopeState1, #1               wz
  if_nz       jmp      #Rel1
  if_nc       shr      decay1, decayDivide1  
              sub      envelopeLevel1, decay1
              min      envelopeLevel1, sustain1         wc
              jmp      #Amplitude1
'----------------------------------------------------------- 
Rel1 if_nc    shr      release1, decayDivide1  
              cmpsub   envelopeLevel1, release1
          
'───────────────────────────────────────────────────────────  
'Calculate sample out1 = arg1 * arg2 (waveform * amplitude)    
'───────────────────────────────────────────────────────────   
Amplitude1    shr      arg1, #14
              sub      arg1, val17bit             
              mov      arg2, envelopeLevel1     
              shr      arg2, #24
              call     #multiply
              mov      out1, r1
 
'─────────────────────────────────────────────────────────── 
'            Waveform shaping channel 2 -> arg1                           
'───────────────────────────────────────────────────────────
Saw2          cmp      selectedWaveform2, #2            wz
              mov      arg1, phaseAccumulator2
  if_z        jmp      #Envelope2   
'----------------------------------------------------------- 
Triangle2     cmp      selectedWaveform2, #1            wz, wc
  if_nz       jmp      #Square2
              shl      arg1, #1                         wc
  if_c        xor      arg1, mask32bit
              test     controlRegister2, #4             wz '|
  if_nz       test     phaseAccumulator1, val31bit      wz '| These 3 lines handles ring modulation
  if_nz       xor      arg1, mask32bit                     '|
              jmp      #Envelope2   
'-----------------------------------------------------------  
Square2       cmp      selectedWaveform2, #4            wz
  if_z        sub      pulseWidth2, phaseAccumulator2   wc ' C holds the pulse width modulated square wave  
  if_z        muxc     arg1, mask32bit              
  if_z        jmp      #Envelope2   
'----------------------------------------------------------- 
Noise2        cmp      selectedWaveform2, #8            wz 
  if_nz       jmp      #Combined2  
              and      arg1, mask28bit 
              sub      arg1, frequency2                 wc
              movi     arg1, noiseValue2
              add      arg1, noiseAddValue
  if_nc       jmp      #Envelope2 
              test     noiseValue2, noiseTap            wc 
              rcr      noiseValue2, #1 
              jmp      #Envelope2
'-----------------------------------------------------------                
Combined2     test     selectedWaveform2, #8            wz
              sub      selectedWaveform2, #4
              mins     selectedWaveform2, #0             
              shl      selectedWaveform2, #8
              mov      tempValue, phaseAccumulator2
              shr      tempValue, #24
              add      selectedWaveform2, tempValue
              add      selectedWaveform2, combTableAddr    
  if_nc_and_z rdbyte   arg1, selectedWaveform2
  if_nc_and_z shl      arg1, #24                         
  if_c_or_nz  mov      arg1, val31bit             
'───────────────────────────────────────────────────────────  
'            Envelope shaping channel 2 -> arg2           
'─────────────────────────────────────────────────────────── 
Envelope2     mov      tempValue, decayDivideRef
              shr      tempValue, decayDivide2
              cmp      envelopeLevel2, tempValue        wc
              tjnz     envelopeState2, #Env_Dec2        nr 
'----------------------------------------------------------- 
Env_At2 if_nc cmpsub   decayDivide2, #1                    
              add      envelopeLevel2, attack2          wc
  if_c        mov      envelopeLevel2, mask32bit         
  if_c        mov      envelopeState2, #1
              jmp      #Amplitude2
'----------------------------------------------------------- 
Env_Dec2 if_c add      decayDivide2, #1    
              cmp      startLogLevel,envelopeLevel2     wc   
              cmp      envelopeState2, #1               wz
  if_nz       jmp      #Rel2 
  if_nc       shr      decay2, decayDivide2  
              sub      envelopeLevel2, decay2
              min      envelopeLevel2, sustain2         wc
              jmp      #Amplitude2
'-----------------------------------------------------------   
Rel2 if_nc    shr      release2, decayDivide2  
              cmpsub   envelopeLevel2, release2
   
'───────────────────────────────────────────────────────────
'Calculate sample out2 = arg1 * arg2 (waveform * amplitude)     
'───────────────────────────────────────────────────────────
Amplitude2    shr      arg1, #14
              sub      arg1, val17bit  
              mov      arg2, envelopeLevel2
              shr      arg2, #24
              call     #multiply
              mov      out2, r1

'───────────────────────────────────────────────────────────              
'            Waveform shaping channel 3 -> arg1                           
'─────────────────────────────────────────────────────────── 
Saw3          cmp      selectedWaveform3, #2            wz
              mov      arg1, phaseAccumulator3
  if_z        jmp      #Envelope3   
'----------------------------------------------------------- 
Triangle3     cmp      selectedWaveform3, #1            wz, wc
  if_nz       jmp      #Square3
              shl      arg1, #1                         wc
  if_c        xor      arg1, mask32bit
              test     controlRegister3, #4             wz '|
  if_nz       test     phaseAccumulator2, val31bit      wz '| These 3 lines handles ring modulation 
  if_nz       xor      arg1, mask32bit                     '|
              jmp      #Envelope3   
'-----------------------------------------------------------  
Square3       cmp      selectedWaveform3, #4            wz
  if_z        sub      pulseWidth3, phaseAccumulator3   wc ' C holds the pulse width modulated square wave  
  if_z        muxc     arg1, mask32bit                   
  if_z        jmp      #Envelope3 
'----------------------------------------------------------- 
Noise3        cmp      selectedWaveform3, #8            wz 
  if_nz       jmp      #Combined3  
              and      arg1, mask28bit
              sub      arg1, frequency3                 wc
              movi     arg1, noiseValue3
              add      arg1, noiseAddValue
  if_nc       jmp      #Envelope3 
              test     noiseValue3, noiseTap            wc 
              rcr      noiseValue3, #1 
              jmp      #Envelope3
'-----------------------------------------------------------  
Combined3     test     selectedWaveform3, #8            wz
              sub      selectedWaveform3, #4             
              mins     selectedWaveform3, #0
              shl      selectedWaveform3, #8
              mov      tempValue, phaseAccumulator3
              shr      tempValue, #24
              add      selectedWaveform3, tempValue
              add      selectedWaveform3, combTableAddr    
  if_nc_and_z rdbyte   arg1, selectedWaveform3
  if_nc_and_z shl      arg1, #24                         
  if_c_or_nz  mov      arg1, val31bit
                
'───────────────────────────────────────────────────────────
'            Envelope shaping channel 3 -> arg2           
'───────────────────────────────────────────────────────────  
Envelope3     mov      tempValue, decayDivideRef           
              shr      tempValue, decayDivide3             
              cmp      envelopeLevel3, tempValue        wc 
              tjnz     envelopeState3, #Env_Dec3        nr  
'----------------------------------------------------------- 
Env_At3 if_nc cmpsub   decayDivide3, #1                    
              add      envelopeLevel3, attack3          wc 
  if_c        mov      envelopeLevel3, mask32bit           
  if_c        mov      envelopeState3, #1                  
              jmp      #Amplitude3                         
'----------------------------------------------------------- 
Env_Dec3 if_c add      decayDivide3, #1                    
              cmp      startLogLevel, envelopeLevel3    wc   
              cmp      envelopeState3, #1               wz 
  if_nz       jmp      #Rel3                       
  if_nc       shr      decay3, decayDivide3                
              sub      envelopeLevel3, decay3              
              min      envelopeLevel3, sustain3         wc 
              jmp      #Amplitude3                         
'-----------------------------------------------------------  
Rel3 if_nc    shr      release3, decayDivide3              
              cmpsub   envelopeLevel3, release3            
  
'───────────────────────────────────────────────────────────
'Calculate sample out3 = arg1 * arg2 (waveform * amplitude)     
'───────────────────────────────────────────────────────────
Amplitude3    shr      arg1, #14
              sub      arg1, val17bit            
              mov      arg2, envelopeLevel3
              shr      arg2, #24
              call     #multiply
              mov      out3, r1

' 
'              Handle multi-mode filtering 
'
filter        mov      ordinaryOutput, #0                  '|
              mov      highPassFilter, #0                  '|
              test     filterControl, #1                wc '|
  if_c        add      highPassFilter, out1                '|
  if_nc       add      ordinaryOutput, out1                '|
              test     filterControl, #2                wc '| Route channels trough the filter
  if_c        add      highPassFilter, out2                '| or bypass them
  if_nc       add      ordinaryOutput, out2                '|  
              test     filterControl, #4                wc '|
  if_c        add      highPassFilter, out3                '|
  if_nc       add      ordinaryOutput, out3                '|  
'-----------------------------------------------------------
              mov      arg2, filterResonance               '|
              add      arg2, #RESONANCE_OFFSET             '|
              mov      arg1, bandPassFilter                '|  
              sar      arg1, #RESONANCE_FACTOR             '|
              call     #multiply                           '| High pass filter
              sub      highPassFilter, bandPassFilter      '|
              add      highPassFilter, r1                  '| 
              sub      highPassFilter, lowPassFilter       '|
'----------------------------------------------------------- 
              mov      arg1, highPassFilter                '|
              sar      arg1, #BP_MAX_CUTOFF                '|
              mov      arg2, filterCutoff                  '| Band pass filter
              max      arg2, maxCutoff                     '|
              call     #multiply                           '|
              add      bandPassFilter, r1                  '|
'----------------------------------------------------------- 
              mov      arg1, bandPassFilter                '| 
              sar      arg1, #LP_MAX_CUTOFF                '| 
              mov      arg2, filterCutoff                  '| Low pass filter 
              call     #multiply                           '| 
              add      lowPassFilter, r1                   '| 
'-----------------------------------------------------------  
              mov      filterOutput, #0                    '|
              test     filterMode_Volume, #16           wc '|
  if_c        add      filterOutput, lowPassFilter         '|
              test     filterMode_Volume, #32           wc '| Enable/Disable
  if_c        add      filterOutput, bandPassFilter        '| Low/Band/High pass filtering
              test     filterMode_Volume, #64           wc '|
  if_c        add      filterOutput, highPassFilter        '|

' 
'      Mix channels and update FRQA/FRQB PWM-values
'
mixer         mov      arg1, filterOutput 
              add      arg1, ordinaryOutput 
'----------------------------------------------------------- 
              maxs     arg1, clipLevelHigh                 '|
              mins     arg1, clipLevelLow                  '|
              mov      arg2, filterMode_Volume             '| Main volume adjustment
              and      arg2, #15                           '|
              call     #multiply                           '|
'-----------------------------------------------------------             
              add      r1, val31bit                        '  DC offset
              waitcnt  waitCounter, sampleRate             '  Wait until the right time to update
              mov      FRQA, r1                            '| Update PWM values in FRQA/FRQB
              mov      FRQB, r1                            '|
              mov      tempValue, par
              add      tempValue, #28
              wrlong   r1, tempValue                       '| Write the sample to hub ram
              jmp      #getRegisters
               
' 
'   Get ADSR value    r1 = attackTable[arg1]
'
getADSR       movs      :indexed1, arg1
              andn      :indexed1, #$1F0
              add       :indexed1, #ADSRTable
              shr       arg1, #4                        
:indexed1     mov       r1, 0
getADSR_ret   ret

' 
'    Multiplication     r1(I32) = arg1(I32) * arg2(I32)
'
multiply      mov       r1,   #0            'Clear 32-bit product
:multiLoop    shr       arg2, #1   wc, wz   'Half multiplyer and get LSB of it
  if_c        add       r1,   arg1          'Add multiplicand to product on C
              shl       arg1, #1            'Double multiplicand    
  if_nz       jmp       #:multiLoop         'Check nonzero multiplier to continue multiplication
multiply_ret  ret

' 
'    Variables, tables, masks and reference values
'

ADSRTable           long trunc(ENV_CAL_FACTOR * (1.0 / 9.0    )) '2   ms   
                    long trunc(ENV_CAL_FACTOR * (1.0 / 32.0   )) '8   ms        
                    long trunc(ENV_CAL_FACTOR * (1.0 / 63.0   )) '16  ms     
                    long trunc(ENV_CAL_FACTOR * (1.0 / 95.0   )) '24  ms        
                    long trunc(ENV_CAL_FACTOR * (1.0 / 149.0  )) '38  ms       
                    long trunc(ENV_CAL_FACTOR * (1.0 / 220.0  )) '56  ms           
                    long trunc(ENV_CAL_FACTOR * (1.0 / 267.0  )) '68  ms         
                    long trunc(ENV_CAL_FACTOR * (1.0 / 313.0  )) '80  ms      
                    long trunc(ENV_CAL_FACTOR * (1.0 / 392.0  )) '100 ms            
                    long trunc(ENV_CAL_FACTOR * (1.0 / 977.0  )) '250 ms      
                    long trunc(ENV_CAL_FACTOR * (1.0 / 1954.0 )) '500 ms        
                    long trunc(ENV_CAL_FACTOR * (1.0 / 3126.0 )) '800 ms          
                    long trunc(ENV_CAL_FACTOR * (1.0 / 3907.0 )) '1   s       
                    long trunc(ENV_CAL_FACTOR * (1.0 / 11720.0)) '3   s         
                    long trunc(ENV_CAL_FACTOR * (1.0 / 19532.0)) '5   s          
                    long trunc(ENV_CAL_FACTOR * (1.0 / 31251.0)) '8   s              

'Masks and reference values
startLogLevel       long START_LOG_LEVEL 
sustainAdd          long $0f000000   
mask32bit           long $ffffffff
mask31bit           long $7fffffff 
mask28bit           long $fffffff 
mask24bit           long $ffffff
mask20bit           long $fffff
mask16bit           long $ffff
mask11bit           long $7ff
val31bit            long $80000000
val28bit            long $10000000
val27bit            long $8000000 
val17bit            long $20000
val16bit            long $10000
clipLevelHigh       long $8000000
clipLevelLow        long-$8000000
filterOffset        long FILTER_OFFSET
decayDivideRef      long DECAY_DIVIDE_REF
maxCutoff           long CUTOFF_LIMIT 
sampleRate          long 0                 'clocks between samples ( ~31.250 khz )
combTableAddr       long 0

'Setup and subroutine parameters  
arg1                long 1
arg2                long 1
r1                  long 1 

'Sid variables
noiseAddValue       long NOISE_ADD
noiseTap            long NOISE_TAP
noiseValue1         long $ffffff
noiseValue2         long $ffffff  
noiseValue3         long $ffffff
decayDivide1        long 0
decayDivide2        long 0
decayDivide3        long 0
envelopeLevel1      res  1 
envelopeLevel2      res  1 
envelopeLevel3      res  1 
controlRegister1    res  1 
controlRegister2    res  1
controlRegister3    res  1
frequency1          res  1
frequency2          res  1
frequency3          res  1 
phaseAccumulator1   res  1
phaseAccumulator2   res  1
phaseAccumulator3   res  1
pulseWidth1         res  1 
pulseWidth2         res  1
pulseWidth3         res  1
selectedWaveform1   res  1
selectedWaveform2   res  1
selectedWaveform3   res  1 
envelopeState1      res  1
envelopeState2      res  1
envelopeState3      res  1
attack1             res  1
attack2             res  1
attack3             res  1 
decay1              res  1
decay2              res  1
decay3              res  1 
sustain1            res  1
sustain2            res  1
sustain3            res  1 
release1            res  1
release2            res  1
release3            res  1
out1                res  1
out2                res  1
out3                res  1
filterResonance     res  1
filterCutoff        res  1
highPassFilter      res  1
bandPassFilter      res  1 
lowPassFilter       res  1
filterMode_Volume   res  1
filterControl       res  1
filterOutput        res  1
ordinaryOutput      res  1

'Working variables
waitCounter         res  1
tempValue           res  1
                    fit                          

DAT
  combinedWaveforms  file "adm-sid-combined-waveforms.bin"

VAR
  byte ch1_frequencyLo       
  byte ch1_frequencyHi     
  byte ch1_pulseWidthLo     
  byte ch1_pulseWidthHi    
  byte ch1_controlRegister 
  byte ch1_attackDecay     
  byte ch1_sustainRelease   
  byte ch1_dummy            
  byte ch2_frequencyLo     
  byte ch2_frequencyHi     
  byte ch2_pulseWidthLo     
  byte ch2_pulseWidthHi    
  byte ch2_controlRegister 
  byte ch2_attackDecay      
  byte ch2_sustainRelease   
  byte ch2_dummy            
  byte ch3_frequencyLo      
  byte ch3_frequencyHi    
  byte ch3_pulseWidthLo     
  byte ch3_pulseWidthHi    
  byte ch3_controlRegister  
  byte ch3_attackDecay      
  byte ch3_sustainRelease  
  byte ch3_dummy           
  byte Filter1              
  byte Filter2             
  byte Filter3             
  byte Volume
  byte oldVolume
  long SIDSample
  long cog
                                
