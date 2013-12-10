{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                    AYcog - AY-3-891X / YM2149 emulator V0.22 (C) 2010-05 Johannes Ahlebrand                                  │
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
}}
CON

  PSG_FREQ    = 2_000_000.0  ' Clock frequency input to the chip   (Colour Genie EG2000 computer runs at 2.2Mhz)
 
 ' WARNING !!
 ' Don't alter the constants below unless you know what you are doing
 '-------------------------------------------------------------------
  SAMPLE_RATE = 125_000                  ' Sample rate of AYcog
  OSC_CORR    = trunc(1.05 * PSG_FREQ)   ' Calibrates the relative oscillator frequency
  NOISE_CORR  = OSC_CORR>>1              ' Calibrates the relative noise frequency
  ENV_CORR    = OSC_CORR>>6              ' Calibrates the relative envelope timing
'
' Reg bits function
' -----------------------------------
' 00  7..0 channel A fine tune
' 01  3..0 channel A coarse tune
' 02  7..0 channel B fine tune
' 03  3..0 channel B coarse tune
' 04  7..0 channel C fine tune
' 05  3..0 channel C coarse tune
' 06  4..0 noise period
' 07  7..0 enable register
' 08  4..0 channel A volume
' 09  4..0 channel B volume
' 10  4..0 channel C volume
' 11  7..0 envelope fine tune
' 12  7..0 envelope coarse tune
' 13  3..0 envelope shape
' 14  7..0 I/O port A value
' 15  7..0 I/O port B value

VAR
  long cog

PUB start(right,left,AYregisters)
  if (AYregisters & 1) <> 0     ' we need word aligned registers
    abort(-1)
  arg1 := $18000000 | left
  arg2 := $18000000 | right
  r1 := ((1<<right) | (1<<left))&!1
  sampleRate := clkfreq/SAMPLE_RATE
  cog := cognew(@AYEMU,AYregisters) + 1
  return cog

PUB stop
  if cog
    cogstop(cog~ -1)
 
dat org 0
'
'                Assembly AY emulator
'
AYEMU         mov      AY_Address, par                      ' Setup everyting
              mov      dira, r1
              mov      ctra, arg1
              mov      ctrb, arg2
              mov      waitCounter, cnt
              add      waitCounter, sampleRate
'----------------------------------------------------------- 
mainLoop      call     #getRegisters
              call     #AY                                  ' Main loop
              call     #mixer
              jmp      #mainLoop

'
' Read all AY registers from hub memory and convert
' them to more convenient representations.
'
getRegisters  mov       tempValue, AY_Address
              rdword    frequency1, tempValue               ' reg 0+1 Read in all 4
              shl       frequency1, #20                     ' frequency registers
              add       tempValue,  #2                      ' and make them "32 bits"
              rdword    frequency2, tempValue               ' reg 2+3
              shl       frequency2, #20
              add       tempValue,  #2
              rdword    frequency3, tempValue               ' reg 4+5
              shl       frequency3, #20
              add       tempValue,  #2
              rdbyte    noisePeriod, tempValue              ' reg 6
              and       noisePeriod, #$1f
              add       tempValue, #1
              rdbyte    enableRegister, tempValue           ' reg 7
              min       noisePeriod, #1
              add       tempValue, #1
              rdbyte    amplitude1, tempValue               ' reg 8
              and       amplitude1, #31
              add       tempValue, #1
              rdbyte    amplitude2, tempValue               ' reg 9
              and       amplitude2, #31
              add       tempValue, #1
              rdbyte    amplitude3, tempValue               ' reg 10
              and       amplitude3, #31
              add       tempValue, #1
              rdbyte    envelopePeriod, tempValue           ' reg 11
              add       tempValue, #1
              shl       noisePeriod, #20
              rdbyte    temp1, tempValue                    ' reg 12
              shl       temp1, #8
              or        envelopePeriod, temp1           wz
        if_z  mov       envelopePeriod, half_period         ' 0 == half the period of 1
        if_nz shl       envelopePeriod, #16
              add       tempValue, #1
              rdbyte    envelopeShape, tempValue            ' reg 13
              movd      oscValues, enableRegister
getRegisters_ret ret

'
' Calculate AY samples channel 1-3 and store in out1-out3
'
AY
'───────────────────────────────────────────────────────────
'───────────────────────────────────────────────────────────
'        Envelope shaping -> envelopeAmplitude
'───────────────────────────────────────────────────────────
Envelope      sub      envCounter, envSubValue           wc ' Handles envelope incrementing
  if_c        add      envCounter, envelopePeriod
  if_c        add      envelopeValue, envelopeInc
'───────────────────────────────────────────────────────────
              test     envelopeShape, #16                wz ' Handle envelope reset bit ( Extra bit added by Ahle2 )
  if_z        neg      envelopeValue, #0
  if_z        mov      envelopeInc, #1
  if_z        mov      envCounter, envelopePeriod
  if_z        or       envelopeShape, #16
  if_z        wrbyte   envelopeShape, tempValue             '<-IMPORTANT, sets bit 5 in hub ram
'───────────────────────────────────────────────────────────
              test     envelopeShape, #8                 wc ' Handle continue = 0
              test     envelopeShape, #4                 wz
 if_nc_and_z  mov      envelopeShape, #9
 if_nc_and_nz mov      envelopeShape, #15
'───────────────────────────────────────────────────────────
              test     envelopeShape, #2                 wz ' Sets the envelope hold level
              muxz     envHoldLevel, #15                    '
'───────────────────────────────────────────────────────────
              test     envelopeValue, #16                wz ' Check if > 15
              test     envelopeShape, #1                 wc ' Check hold bit
  if_nz_and_c mov      envelopeInc, #0                      ' Hold envelope
  if_nz_and_c mov      envelopeValue, envHoldLevel          '
'───────────────────────────────────────────────────────────
  if_nz       test     envelopeShape, #2                 wc ' Check and handle alternation
  if_nz_and_c neg      envelopeInc, envelopeInc
  if_nz_and_c add      envelopeValue, envelopeInc
'───────────────────────────────────────────────────────────
              mov      envelopeAmplitude, envelopeValue
              test     envelopeShape, #4                 wc ' Check and handle invertion (attack)
  if_nc       xor      envelopeAmplitude, #15               '(Move Value or ~Value to envelopeAmplitude)
 
'───────────────────────────────────────────────────────────
'     Waveform shaping noise -> bit 3 of oscValues
'───────────────────────────────────────────────────────────
Noise1        sub      phaseAccumulatorN, noiseSubValue  wc ' Noise generator
  if_c        add      phaseAccumulatorN, noisePeriod
  if_c        add      noiseValue, noiseAdd
  if_c        ror      noiseValue, #15                   wc
  if_c        xor      oscValues, #8  

'───────────────────────────────────────────────────────────
'            Waveform shaping channel 1 -> out1
'───────────────────────────────────────────────────────────
Env1          test     amplitude1, #16                   wz ' Selects envelope or fixed amplitude
  if_nz       mov      amplitude1, envelopeAmplitude        ' depending on bit 5 of amplitude register 1
              mov      arg1, amplitude1
              call     #getAmplitude
'───────────────────────────────────────────────────────────
Square1       cmp      frequency1, freqRef               wc     
  if_nc       sub      phaseAccumulator1, oscSubValue    wc ' Square wave generator
  if_c        add      phaseAccumulator1, frequency1        ' channel 1
  if_c        xor      oscValues, #1
'───────────────────────────────────────────────────────────
              test     oscValues, mask513                wz ' Handles mixing of channel 1
              negnz    out1, r1                             ' Tone on/off, Noice on/off     
              test     oscValues, mask4104               wz
  if_z        mov      out1, r1                             ' arg2 = (ToneOn | ToneDisable) & (NoiseOn | NoiseDisable)
 
'─────────────────────────────────────────────────────────── 
'            Waveform shaping channel 2 -> out2
'───────────────────────────────────────────────────────────
Env2          test     amplitude2, #16                   wz ' Selects envelope or fixed amplitude
  if_nz       mov      amplitude2, envelopeAmplitude        ' depending on bit 5 of amplitude register 2
              mov      arg1, amplitude2
              call     #getAmplitude
'───────────────────────────────────────────────────────────
Square2       cmp      frequency2, freqRef               wc        
  if_nc       sub      phaseAccumulator2, oscSubValue    wc ' Square wave generator
  if_c        add      phaseAccumulator2, frequency2        ' channel 2
  if_c        xor      oscValues, #2
'───────────────────────────────────────────────────────────
              test     oscValues, mask1026               wz ' Handles mixing of channel 2
              negz     out2, r1                             ' Tone on/off, Noice on/off     
              test     oscValues, mask8200               wz
  if_z        mov      out2, r1                             ' arg2 = (ToneOn | ToneDisable) & (NoiseOn | NoiseDisable)

'───────────────────────────────────────────────────────────              
'            Waveform shaping channel 3 -> out3
'───────────────────────────────────────────────────────────
Env3          test     amplitude3, #16                   wz ' Selects envelope or fixed amplitude
  if_nz       mov      amplitude3, envelopeAmplitude        ' depending on bit 5 of amplitude register 3
              mov      arg1, amplitude3
              call     #getAmplitude
'───────────────────────────────────────────────────────────
Square3       cmp      frequency3, freqRef               wc        
  if_nc       sub      phaseAccumulator3, oscSubValue    wc ' Square wave generator
  if_c        add      phaseAccumulator3, frequency3        ' channel 3
  if_c        xor      oscValues, #4
'───────────────────────────────────────────────────────────
              test     oscValues, mask2052               wz ' Handles mixing of channel 2
              negz     out3, r1                              ' Tone on/off, Noice on/off 
              test     oscValues, mask16392              wz
  if_z        mov      out3, r1                             ' arg2 = (ToneOn | ToneDisable) & (NoiseOn | NoiseDisable)
AY_ret        ret

' 
'      Mix channels and update FRQA/FRQB PWM-values
'
mixer         mov      r1, val31bit                        '  DC offset  
              add      r1, out1
              add      r1, out2
              add      r1, out3
              waitcnt  waitCounter, sampleRate             '  Wait until the right time to update
              mov      FRQA, r1                            '| Update PWM values in FRQA/FRQB
              mov      FRQB, r1                            '|
mixer_ret     ret

' 
'    Get amplitude table  r1 = amplitudTable[arg1] 
'
getAmplitude  and      arg1, #15
              add      arg1, #amplitudeTable               ' Lookup the amplitude according
              movs     :indexed1, arg1                     ' to the current state of the envelope
              nop
:indexed1     mov      r1, 0
getAmplitude_ret ret


' 
'    Variables, tables, masks and reference values
'
amplitudeTable      long 1634706    
                    long 2452059    
                    long 3678089   
                    long 5517133   
                    long 8275700    
                    long 12413550   
                    long 18620325   
                    long 27930488  
                    long 41895733  
                    long 62843600   
                    long 94265400  
                    long 141398100 
                    long 212097150 
                    long 318145725 
                    long 477218588 
                    long 715827882 
                                                                                                                                                                                                                                                                       
'Masks and reference values
mask513             long 513
mask1026            long 1026
mask2052            long 2052
mask4104            long 4104
mask8200            long 8200
mask16392           long 16392

mask32bit           long $ffffffff
mask16bit           long $ffff
half_period         long $00008000
val31bit            long $80000000
noiseAdd            long $88008800 'Value to add to the noise generator every noise update
sampleRate          long 0
freqRef             long 10<<20

'Setup and subroutine parameters  
arg1                long 0
arg2                long 0
r1                  long 0
AY_Address          long 0

'AY variables
envCounter          long 1
envSubValue         long ENV_CORR
oscSubValue         long OSC_CORR
noiseSubValue       long NOISE_CORR
envelopeValue       long 0
envelopeInc         long 1
envHoldLevel        res  1
oscValues           res  1
amplitude1          res  1
amplitude2          res  1
amplitude3          res  1
envelopeAmplitude   res  1
enableRegister      res  1
envelopeShape       res  1
frequency1          res  1
frequency2          res  1
frequency3          res  1
envelopePeriod      res  1
noisePeriod         res  1
phaseAccumulatorN   res  1
phaseAccumulator1   res  1
phaseAccumulator2   res  1
phaseAccumulator3   res  1
noiseValue          res  1
noiseOut            res  1
out1                res  1
out2                res  1
out3                res  1
waitCounter         res  1
tempValue           res  1
temp1               res  1
                    fit
