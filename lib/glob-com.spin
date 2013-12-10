{{
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐               
│ Communications Engine                                                                                                       │
│                                                                                                                             │
│ Author: Kwabena W. Agyeman                                                                                                  │                              
│ Updated: 8/4/2009                                                                                                           │
│ Designed For: P8X32A                                                                                                        │
│                                                                                                                             │
│ Copyright (c) 2009 Kwabena W. Agyeman                                                                                       │              
│ See end of file for terms of use.                                                                                           │               
│                                                                                                                             │
│ Driver Info:                                                                                                                │
│                                                                                                                             │
│ The COMEngine runs a COM driver in the next free cog on the propeller chip when called.                                     │
│                                                                                                                             │ 
│ The driver, is only guaranteed and tested to work at an 80Mhz system clock or higher. The driver is designed for the P8X32A │
│ so port B will not be operational.                                                                                          │
│                                                                                                                             │
│ Nyamekye,                                                                                                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘ 
}}

CON    
                  ''   
  RX_Pin     = 31 '' ── RX Line - This line is driven by the interface chip.
                  ''  
  TX_Pin     = 30 '' ── TX Line - This line is driven by the propeller chip.

  Stop_Bits  = 1

CON

  ' For use with "receiveCharacter", "receiveCheck", "transmitCharacter", "transmitCharacters" 

  #0, Null

  #1, Start_Of_Heading, Start_Of_Text, End_Of_Text, End_Of_Transmission

  #5, Enquiry, Acknowledge

  #7, Bell, Backspace, Horizontal_Tab, Line_Feed, Vertical_Tab, Form_Feed, Carriage_Return

  #14, Shift_Out, Shift_In, Data_Link_Escape

  #17, Device_Control_1, Device_Control_2, Device_Control_3, Device_Control_4

  #21, Negative_Aknowledge, Synchronous_Idle, End_Of_Transmission_Block, Cancel, End_Of_Medium, Substitute, Escapse

  #28, File_Seperaor, Group_Seperator, Record_Seperator, Unit_Seperator
  
  #127, Delete

  #17, XON, #19, XOFF    

VAR

  long baudRate

  byte inputHead 
  byte inputTail

  byte outputHead
  byte outputTail

  byte inputBuffer[256]
  byte outputBuffer[256]

PUB generateEvenParity(character) '' 8 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Generates an even parity for a character and returns that character with the new parity attached.                        │
'' │                                                                                                                          │
'' │ Character - A character.                                                                                                 │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return (character ^ evenOrOdd(character))

PUB generateOddParity(character) '' 8 Stack Longs 

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Generates an odd parity for a character and returns that character with the new parity attached.                         │
'' │                                                                                                                          │
'' │ Character - A character.                                                                                                 │ 
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return (character ^ evenOrOdd(character) ^ $80) 

PUB generateMarkParity(character) '' 4 Stack Longs 

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Generates an mark parity for a character and returns that character with the new parity attached.                        │ 
'' │                                                                                                                          │
'' │ Character - A character.                                                                                                 │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘ 

  return (character | $80)

PUB generateSpaceParity(character) '' 4 Stack Longs 

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Generates an space parity for a character and returns that character with the new parity attached.                       │                                                                                     │
'' │                                                                                                                          │
'' │ Character - A character.                                                                                                 │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return (character & $7F)

PUB checkEvenParity(character) '' 8 Stack Longs  

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns true if the parity is correct and false if it is not.                                                            │
'' │                                                                                                                          │                                                                                                                      
'' │ Character - A character with an even parity.                                                                             │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return (not(evenOrOdd(character)))

PUB checkOddParity(character) '' 8 Stack Longs 

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns true if the parity is correct and false if it is not.                                                            │
'' │                                                                                                                          │                                                                                                                    
'' │ Character - A character with an odd parity.                                                                              │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  result or= evenOrOdd(character)

PUB checkMarkParity(character) '' 4 Stack Longs  

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns true if the parity is correct and false if it is not.                                                            │
'' │                                                                                                                          │                                                                                                                    
'' │ Character - A character with an mark parity.                                                                             │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  result or= (character & $80)
  
PUB checkSpaceParity(character) '' 4 Stack Longs  

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns true if the parity is correct and false if it is not.                                                            │
'' │                                                                                                                          │                                                                                                                     
'' │ Character - A character with an space parity.                                                                            │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return (not(character & $80))

PUB receiveCharacter '' 6 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns the next character in the receiver buffer.                                                                       │
'' │                                                                                                                          │
'' │ Waits until there is a character to return if the receiver buffer is empty.                                              │                             
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  repeat until(receiveNumber)
  
  return inputBuffer[inputTail++]

PUB receiveNumber '' 3 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns the number of characters in the receiver buffer.                                                                 │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return ((inputHead - inputTail) & $FF)

PUB receiveCheck(character) '' 7 Stack Longs 

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Compares the last character in the receiver buffer with the specified character for equality.                            │
'' │                                                                                                                          │
'' │ Returns true if they are equal and false otherwise.                                                                      │ 
'' │                                                                                                                          │ 
'' │ Character - The character to compare the last received character with for equality.                                      │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return (receiveNumber and (inputBuffer[(inputHead - 1) & $FF] == character))
  
PUB receiveFull '' 6 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns true if the receiver buffer is full and false if it is not.                                                      │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return (receiveNumber == 255)

PUB receiveFlush '' 3 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Empties the receiver buffer.                                                                                             │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  inputTail := inputHead

PUB transmitCharacter(character) '' 4 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Transmits a character at the speed of the currently specified baud rate.                                                 │ 
'' │                                                                                                                          │ 
'' │ Character - A character to transmit.                                                                                     │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  repeat until(outputTail <> ((outputHead + 1) & $FF))
  
  outputBuffer[outputHead++] := character

PUB transmitCharacters(characters) '' 8 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Transmits a string characters at the speed of the currently specified baud rate.                                         │
'' │                                                                                                                          │ 
'' │ Characters - A pointer to the string of characters to transmit.                                                          │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  repeat strsize(characters)
  
    transmitCharacter(byte[characters++])

PUB changeBaudRate(newBaudRate) '' 4 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Changes the current baud rate.                                                                                           │
'' │                                                                                                                          │ 
'' │ NewBaudRate - The new baud rate to transmit and receive at. Between 1 BPS and 250000 BPS.                                │ 
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  repeat while(outputHead <> outputTail)

  if(baudRate)
  
    waitcnt((baudRate * constant((((Stop_Bits <# 32) #> 1) + 8) * 4)) + cnt)
  
  baudRate := ((clkfreq / ((newBaudRate <# 250000) #> 1)) >> 2)
                                                                      
PUB COMEngine(newBaudRate) '' 8 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Initializes the COM driver to run on a new cog.                                                                          │
'' │                                                                                                                          │
'' │ Returns the new cog's ID on sucess or -1 on failure.                                                                     │
'' │                                                                                                                          │ 
'' │ NewBaudRate - The new baud rate to transmit and receive at. Between 1 BPS and 250000 BPS.                                │ 
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  inputHeadAddress := @inputHead
  inputTailAddress := @inputTail

  outputHeadAddress := @outputHead
  outputTailAddress := @outputTail

  inputBufferAddress  := @inputBuffer
  outputBufferAddress := @outputBuffer

  changeBaudRate(newBaudRate)
  
  return cognew(@initialization, @baudRate)

PRI evenOrOdd(character) ' 4 Stack Longs
   
  repeat 8
  
    result += (character & 1)
    character >>= 1
    
  return ((result & 1) << 7)

DAT

' ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
'                       COM Driver
' ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

                        org
                        
' //////////////////////Initialization///////////////////////////////////////////////////////////////////////////////////////// 

initialization          mov     transmitterPC,      #transmitter                    ' Setup transmitter.
                        movi    ctra,               #%0_00100_000                   '
                        movs    ctra,               #((TX_Pin <# 31) #> 0)          '
                        neg     phsa,               #1                              '
                        mov     dira,               TXPin                           '

                        rdlong  counter,            par                             ' Setup synchronization.
                        add     counter,            cnt                             '

' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Receiver
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
receiver                rdlong  quarterRate,        par                             ' Get new settings.
                        add     counter,            quarterRate                     '
                        
                        waitcnt counter,            quarterRate                     ' Wait for transmitter.
                        jmpret  receiverPC,         transmitterPC                   '

                        waitcnt counter,            quarterRate                     ' Wait for start bit.
                        test    RXPin,              ina wz                          '

if_nz                   waitcnt counter,            quarterRate                     ' Wait for start bit.                                       
if_nz                   test    RXPin,              ina wc                          '                                                                                               

if_nz_and_c             jmp     #receiver                                           ' Repeat.

' //////////////////////Receiver Setup/////////////////////////////////////////////////////////////////////////////////////////

                        mov     receiverCounter,    #9                              ' Setup loop to receive the packet. 

' //////////////////////Receive Packet/////////////////////////////////////////////////////////////////////////////////////////

receive                 waitcnt counter,            quarterRate                     ' Input bits.
                        test    RXPin,              ina wc                          '  
                        rcl     receiverBuffer,     #1                              '

if_z                    add     counter,            quarterRate                     ' Wait for transmitter.
                        waitcnt counter,            quarterRate                     '
                        jmpret  receiverPC,         transmitterPC                   '
if_nz                   add     counter,            quarterRate                     '                                                
                        waitcnt counter,            quarterRate                     '                                                
                                                                                                             
                        djnz    receiverCounter,    #receive                        ' Ready next bit.                       

                        rev     receiverBuffer,     #24                             ' Reverse backwards bits.

' //////////////////////Update Packet//////////////////////////////////////////////////////////////////////////////////////////
   
                        rdbyte  receiverTail,       inputTailAddress                ' Check if the buffer is full.   
                        mov     buffer,             receiverHead                    ' 
                        sub     buffer,             receiverTail                    ' 
                        and     buffer,             #$FF                            ' 
                        cmp     buffer,             #255 wc                         '

' //////////////////////Set Packet/////////////////////////////////////////////////////////////////////////////////////////////

if_z                    add     counter,            quarterRate                     ' Set packet and synchronize.
if_c                    mov     buffer,             inputBufferAddress              ' 
if_c                    add     buffer,             receiverHead                    '
if_c                    wrbyte  receiverBuffer,     buffer                          '
                                                                                   
if_c                    add     receiverHead,       #1                              ' Update receiver head pointer.
if_c                    and     receiverHead,       #$FF                            '                                                                  
if_c                    wrbyte  receiverHead,       inputHeadAddress                '

' //////////////////////Repeat/////////////////////////////////////////////////////////////////////////////////////////////////
 
                        jmp     #receiver                                           ' Repeat              
                        
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
'                       Transmitter
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

transmitter             jmpret  transmitterPC,      receiverPC                      ' Run some code.

loop                    rdbyte  buffer,             outputHeadAddress               ' Check if the buffer is empty.
                        sub     buffer,             transmitterTail                 ' 
                        tjz     buffer,             #transmitter                    '
 
' //////////////////////Get Packet/////////////////////////////////////////////////////////////////////////////////////////////

                        mov     transmitterBuffer,  outputBufferAddress             ' Get packet and output start bit.   
                        add     transmitterBuffer,  transmitterTail                 '
                        jmpret  transmitterPC,      receiverPC                      '
                        rdbyte  phsa,               transmitterBuffer               '
                        
                        add     transmitterTail,    #1                              ' Update transmitter tail pointer.
                        and     transmitterTail,    #$FF                            ' 
                        wrbyte  transmitterTail,    outputTailAddress               '

' //////////////////////Transmitter Setup///////////////////////////////////////////////////////////////////////////////////////

                        mov     transmitterCounter, #(((Stop_Bits <# 32) #> 1) + 8) ' Setup loop to transmit the packet.
                        
' //////////////////////Transmit Packet////////////////////////////////////////////////////////////////////////////////////////
                                                                                     
transmit                or      phsa,               #$100                           ' Output bits.
                        jmpret  transmitterPC,      receiverPC                      '
                        ror     phsa,               #1                              '
                                                                                     
                        djnz    transmitterCounter, #transmit                       ' Ready next bit.                                      

' //////////////////////Repeat/////////////////////////////////////////////////////////////////////////////////////////////////
                                                                             
                        jmp     #loop                                               ' Repeat.      
                                                           
' ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
'                       Data
' /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                        

receiverHead            long    0
transmitterTail         long    0

' //////////////////////Pin Masks//////////////////////////////////////////////////////////////////////////////////////////////

RXPin                   long    (|<((RX_Pin <# 31) #> 0))                           ' Receiving pin mask.
TXPin                   long    (|<((TX_Pin <# 31) #> 0))                           ' Transmitting pin mask.

' //////////////////////Addresses//////////////////////////////////////////////////////////////////////////////////////////////

inputHeadAddress        long    0                                   
inputTailAddress        long    0                                    
                                                                        
outputHeadAddress       long    0                                   
outputTailAddress       long    0

inputBufferAddress      long    0                                    
outputBufferAddress     long    0                                   

' //////////////////////Run Time Variables/////////////////////////////////////////////////////////////////////////////////////

buffer                  res     1
counter                 res     1

halfRate                res     1
quarterRate             res     1

' //////////////////////Receiver Variables/////////////////////////////////////////////////////////////////////////////////////

receiverBuffer          res     1
receiverCounter         res     1

receiverTail            res     1

receiverPC              res     1 

' //////////////////////Transmitter Variables//////////////////////////////////////////////////////////////////////////////////

transmitterBuffer       res     1
transmitterCounter      res     1

transmitterHead         res     1    

transmitterPC           res     1

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