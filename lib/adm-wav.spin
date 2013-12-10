{{
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐               
│ Digital To Analog Converter Engine                                                                                          │
│                                                                                                                             │
│ Author: Kwabena W. Agyeman                                                                                                  │                              
│ Updated: 1/11/2010                                                                                                          │
│ Designed For: P8X32A                                                                                                        │
│                                                                                                                             │
│ Copyright (c) 2010 Kwabena W. Agyeman                                                                                       │              
│ See end of file for terms of use.                                                                                           │               
│                                                                                                                             │
│ Driver Info:                                                                                                                │
│                                                                                                                             │
│ The DACEngine runs a stereo digital to analog converter driver in the next free cog on the propeller chip when called.      │
│                                                                                                                             │
│ The driver, is only guaranteed and tested to work at an 80Mhz system clock or higher. The driver is designed for the P8X32A │
│ so port B will not be operational.                                                                                          │
│                                                                                                                             │
│ Nyamekye,                                                                                                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}

CON
                     ''
                     ''   100Ω   1µF
  DAC_Left_Pin  = 08 '' ───┳─── Left Out
                     ''       │
                     ''      10nF
                     ''       │
                     ''       
                     ''
                     ''   100Ω   1µF
  DAC_Right_Pin = 09 '' ───┳─── Right Out
                     ''       │
                     ''      10nF
                     ''       │
                     ''       
                              
VAR

  word dataBlock[512]

  word callerPointer
  word callePointer

  byte stopedOrStarted
  byte signedOrUnsigned
  byte bitsPerSample
  byte numberOfChannels

  word leftVolume
  word rightVolume  
  
  long sampleRate

PUB getDataBlockAddress

  return @dataBlock
  
PUB startPlayer '' 3 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Starts/Unpauses the stereo DAC player. The player will begin at whatever point it stopped at before.                     │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
 
  stopedOrStarted := true

PUB stopPlayer '' 3 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Stops/pauses the stereo DAC. The player will remember whatever point it stopped at.                                      │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  stopedOrStarted := false

PUB transferData '' 3 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Helps reliably transfers data to the stero DAC to play. Throttles data transfer speed to that of data play speed.        │
'' │                                                                                                                          │
'' │ Returns address of next data buffer to transfer data to. Does not return until data buffer is ready for transfer.        │
'' │                                                                                                                          │
'' │ At 8 bits per sample using 1 channel each data buffer is composed of 512 bytes with 512 samples per transfer.            │
'' │                                                                                                                          │
'' │ At 8 bits per sample using 2 channels each data buffer is composed of 512 bytes with 256 samples per transfer.           │
'' │                                                                                                                          │
'' │ At 16 bits per sample using 1 channel each data buffer is composed of 256 words with 256 samples per transfer.           │
'' │                                                                                                                          │
'' │ At 16 bits per sample using 2 channels each data buffer is composed of 256 words with 128 samples per transfer.          │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                 
  repeat while(callerPointer == callePointer)
  result := @dataBlock[256 & callerPointer]
  not callerPointer    

PUB clearData '' 3 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Clears all data in all player data buffers.                                                                              │
'' │                                                                                                                          │
'' │ Helps prevent old data from being played when changing to a new data transfer source.                                    │                                                                
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  bytefill(@dataBlock, ((not(signedOrUnsigned)) & $80), 1024)
  
PUB changeLeftChannelVolume(newVolume) '' 4 Stack Longs 

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Changes the volume of the left channel. (0 to 100)                                                                       │
'' │                                                                                                                          │
'' │ NewVolume - New volume to output samples at. Samples are scaled by this value. Zero mutes the channel.                   │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
                                                    
  leftVolume := (((newVolume <# 100) #> 0) * constant(65536 / 100))

PUB changeRightChannelVolume(newVolume) '' 4 Stack Longs 

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Changes the volume of the right channel. (0 to 100)                                                                      │
'' │                                                                                                                          │
'' │ NewVolume - New volume to output samples at. Samples are scaled by this value. Zero mutes the channel.                   │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  rightVolume := (((newVolume <# 100) #> 0) * constant(65536 / 100))

PUB changeSampleSign(signed) '' 4 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Changes whether samples are signed or not.                                                                               │
'' │                                                                                                                          │
'' │ Signed - True to make all samples be interpreted as signed. False to make all samples be interpreted as unsigned.        │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  signedOrUnsigned := signed
  
PUB changeBitsPerSample(newWidth) '' 4 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Changes the bits per sample, 8 bits or 16 bits.                                                                          │
'' │                                                                                                                          │
'' │ NewWidth - New bits per sample to output samples at. Samples are sized by this value. (8 or 16)                          │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  bitsPerSample := (newWidth == 16)

PUB changeNumberOfChannels(newNumber) '' 4 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Changes the number of channels, 1 channel or 2 channels.                                                                 │
'' │                                                                                                                          │
'' │ When set to 1 channel mode the driver will output samples to both channels at once.                                      │
'' │                                                                                                                          │
'' │ When set to 2 channel mode the driver will output samples to both channels at simultaneously.                            │
'' │                                                                                                                          │
'' │ NewNumber - New number of channels to output samples at. Samples are grouped by this value. (1 or 2)                     │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  numberOfChannels := (newNumber == 2)

PUB changeSampleRate(newRate) '' 4 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Changes the sample rate. The stereo DAC supportes samples rates from 1HZ to 88.2KHZ.                                     │
'' │                                                                                                                          │
'' │ NewRate - New sample rate to out samples at. Samples are outputted at the frequency specified by this value.             │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  sampleRate := (clkfreq / ((newRate <# 88200) #> 1))

PUB DACEngine(newRate) '' 4 Stack longs 

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Initializes the stereo digital to analog converter driver to run on a new cog.                                           │
'' │                                                                                                                          │
'' │ Default mode is 8 bits per sample with unsigned samples, 1 channel with muted volume, and playing stopped.               │
'' │                                                                                                                          │
'' │ Returns the new cog's ID on sucess or -1 on failure.                                                                     │
'' │                                                                                                                          │
'' │ NewRate - New sample rate to out samples at. Samples are outputted at the frequency specified by this value.             │ 
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  changeSampleRate(newRate)

  dataBlockAddress := @dataBlock

  callePointerAddress := @callePointer
  
  stopedOrStartedAddress := @stopedOrStarted
  unsignedOrSignedAddress := @signedOrUnsigned
  bitsPerSampleAddress := @bitsPerSample
  numberOfChannelsAddress := @NumberOfChannels

  leftVolumeAddress := @leftVolume
  rightVolumeAddress := @rightVolume

  return cognew(@initialization, @sampleRate)

DAT

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
'                       Stereo Digital To Analog Converter Driver
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  

                        org

' //////////////////////Initialization/////////////////////////////////////////////////////////////////////////////////////////

initialization          mov     ctra,            #((DAC_Left_Pin <# 31) #> 0)  ' Setup counter I/O pins.
                        mov     ctrb,            #((DAC_Right_Pin <# 31) #> 0) '
                        
                        movi    ctra,            #%0_00110_000                 ' Setup counter modes to duty cycle mode.
                        movi    ctrb,            #%0_00110_000                 '
                         
                        mov     dira,            outputMask                    ' Setup I/O pin directions.
                                                                                
                        mov     playerPointer,   dataBlockAddress              ' Setup data block pointer.

                        rdlong  timeCounter,     par                           ' Setup timing.  
                        add     timeCounter,     cnt                           '    

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
'                       Player
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

outerLoop               rdbyte  buffer,          numberOfChannelsAddress wz    ' Setup player mode.
                        muxz    playerMode,      #$1                           '
                        rdbyte  buffer,          bitsPerSampleAddress wz       '
                        muxz    playerMode,      #$2                           '

                        test    playerMode,      #$1 wc                        ' Setup counter.
                        mov     counter,         #128                          '
if_c_or_z               add     counter,         #128                          '
if_c_and_z              add     counter,         #256                          '

' //////////////////////Inner Loop/////////////////////////////////////////////////////////////////////////////////////////////                               

innerLoop               rdlong  buffer,          par                           ' Wait until next sample output period.
                        waitcnt timeCounter,     buffer                        '

                        rdbyte  buffer,          stopedOrStartedAddress        ' If stopped loop continously.
                        tjz     buffer,          #innerLoop                    '
                                                                                 
                        movs    multiplicand,    #leftVolumeAddress            ' Get and output value. 
                        call    #decode                                        ' 
                        mov     frqa,            sampleBuffer                  '

                        test    playerMode,      #1 wc                         ' Check number of channels.
if_c                    mov     frqb,            frqa                          '
if_c                    jmp     #nextLoop                                      '

                        movs    multiplicand,    #rightVolumeAddress           ' Get and output value.
                        call    #decode                                        ' 
                        mov     frqb,            sampleBuffer                  '

nextLoop                djnz    counter,         #innerLoop                    ' Loop.

' //////////////////////Outer Loop/////////////////////////////////////////////////////////////////////////////////////////////

                        rdword  buffer,          callePointerAddress wz        ' Switch data block pointer.
if_z                    neg     buffer,          #1                            '
if_nz                   mov     buffer,          #0                            '
                        wrword  buffer,          callePointerAddress           '

if_nz                   mov     playerPointer,   dataBlockAddress              ' Setup data block pointer.

                        jmp     #outerLoop                                     ' Loop.

' ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
'                       Decode Value
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

decode                  test    playerMode,      #$2 wc                        ' Read data depending on size.
if_c                    rdbyte  multiplyBuffer,  playerPointer                 '
if_c                    add     playerPointer,   #1                            '
if_nc                   rdword  multiplyBuffer,  playerPointer                 '
if_nc                   add     playerPointer,   #2                            '    

                        rdbyte  buffer,          unsignedOrSignedAddress wz    ' Modify data depending on sign and size.   
if_z_and_c              sub     multiplyBuffer,  #$80                          '
if_c                    shl     multiplyBuffer,  #24                           '
if_c                    sar     multiplyBuffer,  #16                           '                  
if_z_and_nc             sub     multiplyBuffer,  wordAdjust                    '
if_nc                   shl     multiplyBuffer,  #16                           '
if_nc                   sar     multiplyBuffer,  #16                           '

multiplicand            rdword  multiplyCounter, 0                             ' Setup inputs. 
                        mov     sampleBuffer,    #0                            '
                        
                        abs     multiplyBuffer,  multiplyBuffer wc             ' Backup sign.
                        rcr     sampleBuffer,    #1 wz, nr                     '

multiplyLoop            shr     multiplyCounter, #1 wc                         ' Preform multiplication.
if_c                    add     sampleBuffer,    multiplyBuffer                '
                        shl     multiplyBuffer,  #1 wc                         '
                        tjnz    multiplyCounter, #multiplyLoop                 '

                        negnz   sampleBuffer,    sampleBuffer                  ' Restore sign.   

                        add     sampleBuffer,    longAdjust                    ' Center output value.
                        
decode_ret              ret                                                    ' Return.

' ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
'                       Data
' ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

wordAdjust              long    $8000                                          ' Edits word signed value.
longAdjust              long    $80000000                                      ' Edits long unsigend value.

' //////////////////////Pin Masks//////////////////////////////////////////////////////////////////////////////////////////////

outputMask              long    ((|<((DAC_Left_Pin <# 31) #> 0)) | (|<((DAC_Right_Pin <# 31) #> 0))) ' DAC Outputs.             

' //////////////////////Addresses//////////////////////////////////////////////////////////////////////////////////////////////

dataBlockAddress        long    0

callePointerAddress     long    0

stopedOrStartedAddress  long    0
unsignedOrSignedAddress long    0          
bitsPerSampleAddress    long    0
numberOfChannelsAddress long    0

leftVolumeAddress       long    0
rightVolumeAddress      long    0
                     
' //////////////////////Run Time Variables/////////////////////////////////////////////////////////////////////////////////////

buffer                  res     1
counter                 res     1

playerPointer           res     1
playerMode              res     1

sampleBuffer            res     1
timeCounter             res     1

multiplyBuffer          res     1
multiplyCounter         res     1

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

                        fit     496
 
{{

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                 │                                                            
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation   │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,   │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the        │
│Software is furnished to do so, subject to the following conditions:                                                         │         
│                                                                                                                             │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the         │
│Software.                                                                                                                    │
│                                                                                                                             │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE         │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR        │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,  │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                        │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}                        