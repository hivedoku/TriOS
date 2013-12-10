{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                           SIDcog - SID/MOS8580 emulator V0.80 (C) 2010-02 Johannes Ahlebrand                                 │                                                            
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
{

11-07-2010-dr235  - änderung in setWaveform

}


CON
  PAL           = 985248.0
  NTSC          = 1022727.0
  MAXF          = 1031000.0
  TRIANGLE      = 16
  SAW           = 32
  SQUARE        = 64
  NOISE         = 128

  C64_CLOCK_FREQ   = PAL
  '                            ___
  CUTOFF_LIMIT     = 1300'        │
  LP_MAX_CUTOFF    = 10'          │
  BP_MAX_CUTOFF    = 11'          │ Don't alter these unless you know what you are doing. ;)   
  FILTER_OFFSET    = 27'          │   
  DECAY_DIVIDE_REF = $6C6C6C6C'   │
  NOISE_ADD        = $979D21B5'   │
  NOISE_ROTATE     = 28'       ___│     

PUB start(right,left)
  arg1 := $18000000 | left
  arg2 := $18000000 | right
  r1 := ((1<<right) | (1<<left))&!1
  sampleRate := clkfreq/trunc(C64_CLOCK_FREQ/32.0) 
  combTableAddr := @combinedWaveforms 
  cog  := cognew(@SIDEMU, @ch1_frequencyLo) + 1
  return @ch1_frequencyLo

PUB stop
  if cog
    cogstop(cog~ -1)

PUB setRegister(reg,val) 
  byte[@ch1_frequencyLo+(reg+(reg/7))] := val
   
PUB updateRegisters(source)
  bytemove(@ch1_frequencyLo   , source   , 7) 
  bytemove(@ch1_frequencyLo+8 , source+7 , 7)
  bytemove(@ch1_frequencyLo+16, source+14, 7)
  bytemove(@ch1_frequencyLo+24, source+21, 4)

PUB getSample
  return long[@SIDSample]

PUB setVolume(value)
  byte[@Volume] := (byte[@Volume]&$F0) | (value&$0F)  

PUB play(channel, freq, waveform, attack, decay, sustain, release) | offs
  offs := channel<<3
  word[@ch1_frequencyLo+offs] := freq   
  byte[@ch1_attackDecay+offs] := (decay&$F) | ((attack&$F)<<4)
  byte[@ch1_sustainRelease+offs] := (release&$F) | ((sustain&$F)<<4) 
  byte[@ch1_controlRegister+offs] := (byte[@ch1_controlRegister+offs]&$0F) | waveform | 1

PUB noteOn(channel, freq) | offs
  offs := channel<<3
  byte[@ch1_controlRegister+offs] := (byte[@ch1_controlRegister+offs]&$FE) | 1 
  word[@ch1_frequencyLo+offs] := freq
  
PUB noteOff(channel)
  byte[@ch1_controlRegister+(channel<<3)] &= $FE

PUB setFreq(channel,freq)
  word[@ch1_frequencyLo+(channel<<3)] := freq

PUB setWaveform(channel,waveform) | offs  
  offs := channel<<3
  byte[@ch1_controlRegister+offs] := (byte[@ch1_controlRegister+offs]&$0F) | waveform
'  byte[@ch1_controlRegister+offs] := (byte[@ch1_controlRegister+offs]&$0F) | (1<<(4+(waveform&3)))

PUB setPWM(channel, value)
  word[@ch1_pulseWidthLo+(channel<<3)] := value 

PUB setADSR(channel, attack, decay, sustain, release ) | offs
  offs := channel<<3
  byte[@ch1_attackDecay+offs]    := (decay&$F)   | ((attack&$F)<<4)
  byte[@ch1_sustainRelease+offs] := (release&$F) | ((sustain&$F)<<4) 

PUB setResonance(val)
  byte[@Filter3] := (byte[@Filter3]&$0F) | (val<<4)
  
PUB setCutoff(freq)
  byte[@Filter1] := freq&$07
  byte[@Filter2] := (freq&$07F8)>>3

PUB setFilterMask(ch1,ch2,ch3)
  byte[@Filter3] := (byte[@Filter3]&$F0) | (ch1&1) | (ch2&2) | (ch3&4)

PUB setFilterType(lp,bp,hp)
  byte[@volume] := (byte[@volume]&$0F) | (lp&16) | (bp&32) | (hp&64) 

PUB enableRingmod(ch1,ch2,ch3)
  byte[@ch1_controlRegister] := (byte[@ch1_controlRegister]&$FB) | (ch1&4)
  byte[@ch2_controlRegister] := (byte[@ch2_controlRegister]&$FB) | (ch2&4)
  byte[@ch3_controlRegister] := (byte[@ch3_controlRegister]&$FB) | (ch3&4)

PUB enableSynchronization(ch1,ch2,ch3)
  byte[@ch1_controlRegister] := (byte[@ch1_controlRegister]&$FD) | (ch1&2)
  byte[@ch2_controlRegister] := (byte[@ch2_controlRegister]&$FD) | (ch2&2)
  byte[@ch3_controlRegister] := (byte[@ch3_controlRegister]&$FD) | (ch3&2)
    
dat org 0
'
'                Assembly SID emulator                      
'
SIDEMU        mov      dira, r1                     
              mov      ctra, arg1                          
              mov      ctrb, arg2
              mov      waitCounter, cnt                    
              add      waitCounter, sampleRate
'----------------------------------------------------------- 
mainLoop      call     #getRegisters
              call     #SID
              call     #filter
              call     #mixer
              jmp      #mainLoop
'-----------------------------------------------------------              
 
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
              call      #getDecay                          '|
              mov       decay1, r1                         '|
              shr       arg1, #4                           '|
              call      #getAttack                         '|
              mov       attack1, r1                        '|  Convert 4bit ADSR "presets" to their corresponding  
              shr       arg1, #4                           '|  32bit values using attack/decay tables.
              call      #getDecay                          '|
              mov       release1, r1                       '|
              mov       sustain1, selectedWaveform1        '|
              shl       sustain1, #8                       '|
              andn      sustain1, mask28bit                '| 
'----------------------------------------------------------- 
              shr       selectedWaveform1, #4              ' Mask out waveform selection
              and       selectedWaveform1, #15  wz, wc    
'----------------------------------------------------------- 
              test      controlRegister1, #1        wc
              cmp       envelopeState1, #2          wz
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
              call      #getDecay                          '|
              mov       decay2, r1                         '|
              shr       arg1, #4                           '|
              call      #getAttack                         '|
              mov       attack2, r1                        '|  Convert 4bit ADSR "presets" to their corresponding
              shr       arg1, #4                           '|  32bit values using attack/decay tables.
              call      #getDecay                          '|
              mov       release2, r1                       '|
              mov       sustain2, selectedWaveform2        '|
              shl       sustain2, #8                       '|
              andn      sustain2, mask28bit                '|   
'----------------------------------------------------------- 
              shr       selectedWaveform2, #4              ' Mask out waveform selection
              and       selectedWaveform2, #15  wz, wc    
'----------------------------------------------------------- 
              test      controlRegister2, #1        wc
              cmp       envelopeState2, #2          wz
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
              call      #getDecay                          '|
              mov       decay3, r1                         '|
              shr       arg1, #4                           '|
              call      #getAttack                         '|
              mov       attack3, r1                        '|  Convert 4bit ADSR "presets" to their corresponding
              shr       arg1, #4                           '|  32bit values using attack/decay tables.
              call      #getDecay                          '|
              mov       release3, r1                       '|
              mov       sustain3, selectedWaveform3        '|
              shl       sustain3, #8                       '|
              andn      sustain3, mask28bit                '|   
'----------------------------------------------------------- 
              shr       selectedWaveform3, #4              ' Mask out waveform selection
              and       selectedWaveform3, #15  wz, wc    
'----------------------------------------------------------- 
              test      controlRegister3, #1        wc
              cmp       envelopeState3, #2          wz
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
              and       filterResonance,#$F0               '|
              shr       filterResonance,#5                 '|
              add       filterResonance,#resTable          '|  Filter Resonance level (Ariba)
              movs      rdRes,filterResonance              '|
              nop                                          '|
rdRes         mov       filterResonance,0-0                '|

getRegisters_ret ret 

'
' Calculate sid samples channel 1-3 and store in out1-out3 
'
 
'───────────────────────────────────────────────────────────   
'    Increment phase accumulator 1-3 and handle syncing
'───────────────────────────────────────────────────────────  
SID           add      phaseAccumulator1, frequency1    wc ' Add frequency value to phase accumulator 1
  if_nc       andn     controlRegister2, #2
              test     controlRegister2, #10            wz ' Sync oscilator 2 to oscilator 1 if sync = on 
  if_nz       mov      phaseAccumulator2, #0               ' Or reset counter 2 when bit 4 of control register is 1
'-----------------------------------------------------------      
              add      phaseAccumulator2, frequency2    wc
  if_nc       andn     controlRegister3, #2
              test     controlRegister3, #10            wz ' Sync oscilator 3 to oscilator 2 if sync = on 
  if_nz       mov      phaseAccumulator3, #0               ' Or reset oscilator 3 when bit 4 of control register is 1
'-----------------------------------------------------------
              add      phaseAccumulator3, frequency3    wc
  if_nc       andn     controlRegister1, #2
              test     controlRegister1, #10            wz ' Sync oscilator 1 to oscilator 3 if sync = on 
  if_nz       mov      phaseAccumulator1, #0               ' Or reset oscilator 1 when bit 4 of control register is 1

'───────────────────────────────────────────────────────────  
'            Waveform shaping channel 1 -> arg1                           
'───────────────────────────────────────────────────────────
Triangle1     tjz      selectedWaveform1, #Triangle2   
              cmp      selectedWaveform1, #1            wz
  if_nz       jmp      #Saw1
              abs      arg1, phaseAccumulator1
              max      arg1, mask31bit          
              test     controlRegister1, #4             wc '|
  if_c        test     phaseAccumulator3, val31bit      wc '| These 3 lines handles ring modulation
  if_c        xor      arg1, mask32bit                     '|
              shl      arg1, #1
              jmp      #Env_Attack1   
'-----------------------------------------------------------  
Saw1          cmp      selectedWaveform1, #2            wz
  if_z        mov      arg1, phaseAccumulator1
  if_z        jmp      #Env_Attack1   
'-----------------------------------------------------------  
Square1       cmp      selectedWaveform1, #4            wz
  if_z        sub      pulseWidth1, phaseAccumulator1   wc ' C holds the pulse width modulated square wave
  if_z        muxc     arg1, mask32bit
  if_z        jmp      #Env_Attack1  
'-----------------------------------------------------------  
Noise1        cmp      selectedWaveform1, #8            wz
  if_nz       jmp      #Combined1
              mov      tempValue, phaseAccumulator1
              and      tempValue, mask28bit
              sub      tempValue, frequency1            wc
  if_z_and_c  ror      noiseValue1, NOISE_ROTATE
  if_z_and_c  add      noiseValue1, noiseAdd
  if_z        mov      arg1, noiseValue1
              jmp      #Env_Attack1
'-----------------------------------------------------------                
Combined1     sub      selectedWaveform1, #4
              mins     selectedWaveform1, #0
              shl      selectedWaveform1, #8
              mov      tempValue, phaseAccumulator1
              shr      tempValue, #24
              add      selectedWaveform1, tempValue
              add      selectedWaveform1, combTableAddr
              rdbyte   arg1, selectedWaveform1
              shl      arg1, #24 
              
'───────────────────────────────────────────────────────────  
'            Envelope shaping channel 1 -> arg2           
'───────────────────────────────────────────────────────────    
Env_Attack1   cmp      envelopeState1, #0               wz
  if_nz       jmp      #InitDecay1
              add      envelopeLevel1, attack1          wc
  if_c        mov      envelopeLevel1, mask32bit         
  if_c        mov      envelopeState1, #1
              mov      decayDivide1, #0                
              jmp      #Amplitude1
'----------------------------------------------------------- 
InitDecay1    mov      tempValue, decayDivideRef
              shr      tempValue, decayDivide1
              cmp      envelopeLevel1, tempValue        wc
  if_c        add      decayDivide1, #1
'----------------------------------------------------------- 
Env_Decay1    cmp      envelopeState1, #1               wz
  if_nz       jmp      #Env_Release1
              shr      decay1, decayDivide1  
              sub      envelopeLevel1, decay1
              min      envelopeLevel1, sustain1         wc
              jmp      #Amplitude1
'----------------------------------------------------------- 
Env_Release1  cmp      envelopeState1, #2               wz
  if_nz       jmp      #Amplitude1
              shr      release1, decayDivide1  
              cmpsub   envelopeLevel1, release1
          
'───────────────────────────────────────────────────────────  
'Calculate sample out1 = arg1 * arg2 (waveform * amplitude)    
'───────────────────────────────────────────────────────────   
Amplitude1    shr      arg1, #16
              sub      arg1, val15bit             
              mov      arg2, envelopeLevel1     
              shr      arg2, #22
              call     #multiply
              mov      out1, r1
 
'─────────────────────────────────────────────────────────── 
'            Waveform shaping channel 2 -> arg1                           
'───────────────────────────────────────────────────────────
Triangle2     tjz      selectedWaveform2, #Triangle3 
              cmp      selectedWaveform2, #1            wz
  if_nz       jmp      #Saw2
              abs      arg1, phaseAccumulator2              
              max      arg1, mask31bit    
              test     controlRegister2, #4             wc '|
  if_c        test     phaseAccumulator1, val31bit      wc '| These 3 lines handles ring modulation
  if_c        xor      arg1, mask32bit                     '|
              shl      arg1, #1
              jmp      #Env_Attack2   
'-----------------------------------------------------------  
Saw2          cmp      selectedWaveform2, #2            wz
  if_z        mov      arg1, phaseAccumulator2
  if_z        jmp      #Env_Attack2   
'----------------------------------------------------------- 
Square2       cmp      selectedWaveform2, #4            wz
  if_z        sub      pulseWidth2, phaseAccumulator2   wc ' C holds the pulse width modulated square wave  
  if_z        muxc     arg1, mask32bit              
  if_z        jmp      #Env_Attack2   
'----------------------------------------------------------- 
Noise2        cmp      selectedWaveform2, #8            wz
  if_nz       jmp      #Combined2  
              mov      tempValue, phaseAccumulator2
              and      tempValue, mask28bit
              sub      tempValue, frequency2            wc
  if_z_and_c  ror      noiseValue2, NOISE_ROTATE
  if_z_and_c  add      noiseValue2, noiseAdd
  if_z        mov      arg1,  noiseValue2
              jmp      #Env_Attack2
'-----------------------------------------------------------                
Combined2     sub      selectedWaveform2, #4
              mins     selectedWaveform2, #0
              shl      selectedWaveform2, #8
              mov      tempValue, phaseAccumulator2
              shr      tempValue, #24
              add      selectedWaveform2, tempValue
              add      selectedWaveform2, combTableAddr    
              rdbyte   arg1, selectedWaveform2
              shl      arg1, #24 
  
'───────────────────────────────────────────────────────────  
'            Envelope shaping channel 2 -> arg2           
'─────────────────────────────────────────────────────────── 
Env_Attack2   cmp      envelopeState2, #0               wz
  if_nz       jmp      #InitDecay2
              add      envelopeLevel2, attack2          wc
  if_c        mov      envelopeLevel2, mask32bit         
  if_c        mov      envelopeState2, #1
              mov      decayDivide2, #0                 
              jmp      #Amplitude2
'----------------------------------------------------------- 
InitDecay2    mov      tempValue, decayDivideRef
              shr      tempValue, decayDivide2
              cmp      envelopeLevel2, tempValue        wc 
  if_c        add      decayDivide2, #1
'----------------------------------------------------------- 
Env_Decay2    cmp      envelopeState2, #1               wz
  if_nz       jmp      #Env_Release2 
              shr      decay2, decayDivide2  
              sub      envelopeLevel2, decay2
              min      envelopeLevel2, sustain2         wc
              jmp      #Amplitude2
'-----------------------------------------------------------   
Env_Release2  cmp      envelopeState2, #2               wz
  if_nz       jmp      #Amplitude2  
              shr      release2, decayDivide2  
              cmpsub   envelopeLevel2, release2
   
'───────────────────────────────────────────────────────────
'Calculate sample out2 = arg1 * arg2 (waveform * amplitude)     
'───────────────────────────────────────────────────────────
Amplitude2    shr      arg1, #16
              sub      arg1, val15bit  
              mov      arg2, envelopeLevel2
              shr      arg2, #22
              call     #multiply
              mov      out2, r1

'───────────────────────────────────────────────────────────              
'            Waveform shaping channel 3 -> arg1                           
'─────────────────────────────────────────────────────────── 
Triangle3     tjz      selectedWaveform3, #SID_ret  
              cmp      selectedWaveform3, #1            wz
  if_nz       jmp      #Saw3
              abs      arg1, phaseAccumulator3              
              max      arg1, mask31bit    
              test     controlRegister3, #4             wc '|
  if_c        test     phaseAccumulator2, val31bit      wc '| These 3 lines handles ring modulation 
  if_c        xor      arg1, mask32bit                     '|
              shl      arg1, #1
              jmp      #Env_Attack3   
'-----------------------------------------------------------  
Saw3          cmp      selectedWaveform3, #2            wz
  if_z        mov      arg1, phaseAccumulator3
  if_z        jmp      #Env_Attack3   
'----------------------------------------------------------- 
Square3       cmp      selectedWaveform3, #4            wz
  if_z        sub      pulseWidth3, phaseAccumulator3   wc ' C holds the pulse width modulated square wave  
  if_z        muxc     arg1, mask32bit                   
  if_z        jmp      #Env_Attack3 
'----------------------------------------------------------- 
Noise3        cmp      selectedWaveform3, #8            wz
  if_nz       jmp      #Combined3
              mov      tempValue, phaseAccumulator3
              and      tempValue, mask28bit
              sub      tempValue, frequency3            wc
  if_z_and_c  ror      noiseValue3, NOISE_ROTATE
  if_z_and_c  add      noiseValue3, noiseAdd
  if_z        mov      arg1, noiseValue3
              jmp      #Env_Attack3
'-----------------------------------------------------------  
Combined3     sub      selectedWaveform3, #4
              mins     selectedWaveform3, #0
              shl      selectedWaveform3, #8
              mov      tempValue, phaseAccumulator3
              shr      tempValue, #24
              add      selectedWaveform3, tempValue
              add      selectedWaveform3, combTableAddr    
              rdbyte   arg1, selectedWaveform3
              shl      arg1, #24 
  
'───────────────────────────────────────────────────────────
'            Envelope shaping channel 3 -> arg2           
'───────────────────────────────────────────────────────────  
Env_Attack3   cmp      envelopeState3, #0               wz
  if_nz       jmp      #InitDecay3
              add      envelopeLevel3, attack3          wc
  if_c        mov      envelopeLevel3, mask32bit         
  if_c        mov      envelopeState3, #1
              mov      decayDivide3, #0  
              jmp      #Amplitude3
'----------------------------------------------------------- 
InitDecay3    mov      tempValue, decayDivideRef
              shr      tempValue, decayDivide3
              cmp      envelopeLevel3, tempValue        wc 
  if_c        add      decayDivide3, #1
'----------------------------------------------------------- 
Env_Decay3    cmp      envelopeState3, #1               wz
  if_nz       jmp      #Env_Release3 
              shr      decay3, decayDivide3  
              sub      envelopeLevel3, decay3
              min      envelopeLevel3, sustain3         wc
              jmp      #Amplitude3
'-----------------------------------------------------------  
Env_Release3  cmp      envelopeState3, #2               wz
  if_nz       jmp      #Amplitude3   
              shr      release3, decayDivide3   
              cmpsub   envelopeLevel3, release3
  
'───────────────────────────────────────────────────────────
'Calculate sample out3 = arg1 * arg2 (waveform * amplitude)     
'───────────────────────────────────────────────────────────
Amplitude3    shr      arg1, #16
              sub      arg1, val15bit            
              mov      arg2, envelopeLevel3
              shr      arg2, #22                       
              call     #multiply
              mov      out3, r1
SID_ret       ret

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
              mov      tempValue, bandPassFilter           '|
              sar      tempValue, filterResonance          '| High pass filter 
              sub      highPassFilter, tempValue           '|
              sub      highPassFilter, lowPassFilter       '|
'----------------------------------------------------------- 
              mov      arg1, highPassFilter                '|
              sar      arg1, #BP_MAX_CUTOFF                '|
              mov      arg2, filterCutoff                  '| Band pass filter
                                                max arg2, maxCutoff  
              call     #multiplyNS                         '|
              add      bandPassFilter, r1                  '|
'----------------------------------------------------------- 
              mov      arg1, bandPassFilter                '| 
              sar      arg1, #LP_MAX_CUTOFF                '| 
              mov      arg2, filterCutoff                  '| Low pass filter 
              call     #multiplyNS                         '| 
              add      lowPassFilter, r1                   '| 
'-----------------------------------------------------------  
              mov      filterOutput, #0                    '|
              test     filterMode_Volume, #16           wc '|
  if_c        add      filterOutput, lowPassFilter         '|
              test     filterMode_Volume, #32           wc '| Enable/Disable
  if_c        add      filterOutput, bandPassFilter        '| Low/Band/High pass filtering
              test     filterMode_Volume, #64           wc '|
  if_c        add      filterOutput, highPassFilter        '|
filter_ret    ret

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
              call     #multiplyNS                         '|
'-----------------------------------------------------------             
              add      r1, val31bit                        '  DC offset
              waitcnt  waitCounter, sampleRate             '  Wait until the right time to update
              mov      FRQA, r1                            '| Update PWM values in FRQA/FRQB
              mov      FRQB, r1                            '|
              mov      tempValue, par
              add      tempValue, #28
              wrlong   r1, tempValue                       '| Write the sample to hub ram
mixer_ret     ret

' 
'   Get attack value    r1 = attackTable[arg1]  
'
getAttack     mov       arg2, arg1
              and       arg1, #15              
              add       arg1, #ADSRTable
              movs      :indexed1, arg1
              mov       arg1, arg2
:indexed1     mov       r1, 0
getAttack_ret ret

' 
'   Get decay value     r1 = decayTable[arg1] 
'
getDecay      mov       arg2, arg1
              and       arg1, #15              
              add       arg1, #ADSRTable 
              movs      :indexed2, arg1
              mov       arg1, arg2
:indexed2     mov       r1, 0
getDecay_ret  ret

' 
'    Multiplication     r1(I32) = arg1(I32) * arg2(I32)
'
multiply      cmp       arg1, arg2 wc       'If arg1 is less than arg2 C is set
  if_c        xor       arg1, arg2          'Swap arguments
  if_c        xor       arg2, arg1
  if_c        xor       arg1, arg2
multiplyNS    mov       r1,   #0            'Clear 32-bit product
:multiLoop    shr       arg2, #1   wc, wz   'Half multiplyer and get LSB of it
  if_c        add       r1,   arg1          'Add multiplicand to product on C
              shl       arg1, #1            'Double multiplicand    
  if_nz       jmp       #:multiLoop         'Check nonzero multiplier to continue multiplication
multiplyNS_ret      
multiply_ret  ret

' 
'    Variables, tables, masks and reference values
'

ADSRTable           long 68719476  '2   ms
                    long 17179870  '8   ms
                    long 8589934   '16  ms
                    long 5726622   '24  ms
                    long 3616814   '38  ms
                    long 2454268   '56  ms
                    long 2021160   '68  ms
                    long 1717986   '80  ms
                    long 1374390   '100 ms
                    long 549754    '250 ms
                    long 274876    '500 ms
                    long 171798    '800 ms
                    long 137438    '1   s
                    long 45812     '3   s
                    long 27486     '5   s
                    long 17180     '8   s
 
resTable            long  0,1,1,1,1,1,2,2       '(Ariba) 
 
'Masks and reference values    
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
val16bit            long $10000
val15bit            long $8000             
clipLevelHigh       long $8000000
clipLevelLow        long-$8000000
noiseAdd            long NOISE_ADD         'Value to add to the noise generator every noise update
filterOffset        long FILTER_OFFSET
decayDivideRef      long DECAY_DIVIDE_REF
maxCutoff           long CUTOFF_LIMIT 
sampleRate          long 0   'clocks between samples ( ~31.250 khz )
combTableAddr       long 0

'Setup and subroutine parameters  
arg1                long 1
arg2                long 1
r1                  long 1 
 
'Sid variables 
envelopeLevel1      long 1
envelopeLevel2      long 1
envelopeLevel3      long 1
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
noiseValue1         res  1
noiseValue2         res  1  
noiseValue3         res  1  
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
decayDivide1        res  1
decayDivide2        res  1
decayDivide3        res  1 
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

dat
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
  long SIDSample
  byte cog
                                
