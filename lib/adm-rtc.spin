{{
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐               
│ Real Time Clock Engine                                                                                                      │
│                                                                                                                             │
│ Author: Kwabena W. Agyeman                                                                                                  │                              
│ Updated: 11/22/2009                                                                                                         │
│ Designed For: P8X32A                                                                                                        │
│                                                                                                                             │
│ Copyright (c) 2009 Kwabena W. Agyeman                                                                                       │              
│ See end of file for terms of use.                                                                                           │
│                                                                                                                             │
│ Driver Info:                                                                                                                │
│                                                                                                                             │
│ The RTCEngine interfaces with the DS1307RTC.                                                                                │
│                                                                                                                             │ 
│ The driver is only guaranteed and tested to work at an 80Mhz system clock or higher. The driver is designed for the P8X32A  │
│ so port B will not be operational.                                                                                          │
│                                                                                                                             │
│ Nyamekye,                                                                                                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘ 
}}

CON
                         ''
                         ''   3.3V
                         ''   
                         ''   │
                         ''    10KΩ
                         ''   │
  Data_Pin          = 29 '' ─┻─ SDA
                         ''
                         ''   3.3V
                         ''   
                         ''   │
                         ''    10KΩ
                         ''   │
  Clock_Pin         = 28 '' ─┻─ SCL

  RTC_Address       = %1101000

CON

  ' For use with "getDay" and "setDay". 
                         
  #1, Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday

  ' For use with "getMonth" and "setMonth".
          
  #1, January, February, March, April, May, June, July, August, September, October, November, December

PUB getSeconds '' 11 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns the current second (0 - 59) from the real time clock.                                                            │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
   
  return BCDToNumber(getRAM(0))    

PUB getMinutes '' 11 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns the current minute (0 - 59) from the real time clock.                                                            │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return BCDToNumber(getRAM(1)) 

PUB getHours '' 11 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns the current hour (0 - 23) from the real time clock.                                                              │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return BCDToNumber(getRAM(2)) 

PUB getDay '' 11 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns the current day (1 - 7) from the real time clock.                                                                │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return BCDToNumber(getRAM(3)) 

PUB getDate '' 11 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns the current date (1 - 31) from the real time clock.                                                              │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return BCDToNumber(getRAM(4)) 

PUB getMonth '' 11 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns the current month (1 - 12) from the real time clock.                                                             │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return BCDToNumber(getRAM(5)) 

PUB getYear '' 11 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Returns the current year (2000 - 2099) from the real time clock.                                                         │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return (BCDToNumber(getRAM(6)) + 2000)

PUB setSeconds(seconds) '' 13 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Sets the current real time clock seconds.                                                                                │
'' │                                                                                                                          │
'' │ Seconds - Number to set the seconds to between 0 - 59.                                                                   │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  setRAM(0, numberToBCD(((seconds <# 59) #> 0)))   

PUB setMinutes(minutes) '' 13 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Sets the current real time clock minutes.                                                                                │
'' │                                                                                                                          │
'' │ Minutes - Number to set the minutes to between 0 - 59.                                                                   │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  setRAM(1, numberToBCD(((minutes <# 59) #> 0)))

PUB setHours(hours) '' 13 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Sets the current real time clock hours.                                                                                  │
'' │                                                                                                                          │
'' │ Hours - Number to set the hours to between 0 - 23.                                                                       │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  setRAM(2, numberToBCD(((hours <# 23) #> 0)))  

PUB setDay(day) '' 13 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Sets the current real time clock day.                                                                                    │
'' │                                                                                                                          │
'' │ Day - Number to set the day to between 1 - 7.                                                                            │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  setRAM(3, numberToBCD(((day <# 7) #> 1)))  

PUB setDate(date) '' 13 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Sets the current real time clock date.                                                                                   │
'' │                                                                                                                          │
'' │ Date - Number to set the date to between 1 - 31.                                                                         │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  setRAM(4, numberToBCD(((date <# 31) #> 1)))  
  
PUB setMonth(month) '' 13 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Sets the current real time clock month.                                                                                  │
'' │                                                                                                                          │
'' │ Month - Number to set the month to between 1 - 12.                                                                       │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  setRAM(5, numberToBCD(((month <# 12) #> 1)))  

PUB setYear(year) '' 13 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Sets the current real time clock year.                                                                                   │
'' │                                                                                                                          │
'' │ Year - Number to set the year to between 2000 - 2099.                                                                    │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  setRAM(6, numberToBCD((((year - 2000) <# 99) #> 0)))

PUB setSQWOUTFrequency(frequency) '' 13 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Turns the square wave on.                                                                                                │
'' │                                                                                                                          │
'' │ Frequency - Selects the frequency of the square wave pin. (0 - 1HZ), (1 - 4.096KHZ), (2 - 8.192KHZ), (3 - 32.768KHZ).    │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  setRAM(7, ($10 | ((frequency <# 3) #> 0)))
  
PUB setSQWOUTState(state) '' 13 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Turns the square wave off.                                                                                               │
'' │                                                                                                                          │
'' │ State - Selects the state of the square wave pin.                                                                        │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  setRAM(7, ((not(not(state))) & $80))

PUB setNVSRAM(index, value) '' 14 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Sets the NVSRAM to the selected value (0 - 255) at the index (0 - 55).                                                   │
'' │                                                                                                                          │
'' │ Index - The location in NVRAM to set (0 - 55).                                                                           │
'' │ Value - The value (0 - 255) to change the location to.                                                                   │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  setRam((((index <# 55) #> 0) + 8), value)

PUB getNVSRAM(index) '' 12 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Gets the selected NVSRAM value at the index (0 - 55).                                                                    │  
'' │                                                                                                                          │
'' │ Returns the selected location's value (0 - 255).                                                                         │                                     
'' │                                                                                                                          │
'' │ Index - The location in NVRAM to get (0 - 55).                                                                           │ 
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  return getRam(((index <# 55) #> 0) + 8)

PUB pauseForSeconds(number) '' 4 Stack Longs

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Pauses execution for a number of seconds.                                                                                │
'' │                                                                                                                          │
'' │ Returns a puesdo random value derived from the current clock frequency and the time when called.                         │
'' │                                                                                                                          │
'' │ Number - Number of seconds to pause for between 0 and 2,147,483,647.                                                     │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  result := cnt 

  repeat (number #> 0)
    result += clkfreq
    waitcnt(result)   

PUB pauseForMilliseconds(number) '' 4 Stack Longs  

'' ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
'' │ Pauses execution for a number of milliseconds.                                                                           │
'' │                                                                                                                          │
'' │ Returns a puesdo random value derived from the current clock frequency and the time when called.                         │
'' │                                                                                                                          │
'' │ Number - Number of milliseconds to pause for between 0 and 2,147,483,647.                                                │
'' └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

  result := cnt
  
  repeat (number #> 0)
    result += (clkfreq / 1000)
    waitcnt(result)      

PRI BCDToNumber(BCD) ' 4 Stack Longs

  return (((BCD >> 4) * 10) + (BCD & $F))

PRI numberToBCD(number) ' 4 Stack Longs 

  return (((number / 10) << 4) + (number // 10))
                                         
PRI setRAM(index, value) ' 9 Stack Longs

  startDataTransfer
  transmitPacket(constant(RTC_Address << 1))
  transmitPacket(index)                 
  transmitPacket(value)
  stopDataTransfer

PRI getRAM(index) ' 8 Stack Longs 

  startDataTransfer
  transmitPacket(constant(RTC_Address << 1))
  transmitPacket(index)
  stopDataTransfer

  ' Repeated Start
  
  startDataTransfer
  transmitPacket(constant((RTC_Address << 1) | 1))
  result := receivePacket(false)
  stopDataTransfer

PRI transmitPacket(value) ' 4 Stack Longs

  value := ((!value) >< 8)

  repeat 8
  
    dira[constant(((Data_Pin <# 31) #> 0))] := value
     
    dira[constant(((Clock_Pin <# 31) #> 0))] := false
    
    dira[constant(((Clock_Pin <# 31) #> 0))] := true
    
    value >>= 1
         
  dira[constant(((Data_Pin <# 31) #> 0))] := false

  dira[constant(((Clock_Pin <# 31) #> 0))] := false
  dira[constant(((Clock_Pin <# 31) #> 0))] := true 

  dira[constant(((Data_Pin <# 31) #> 0))] := true    

PRI receivePacket(aknowledge) ' 4 Stack Longs

  dira[constant(((Data_Pin <# 31) #> 0))] := false

  repeat 8
  
    result <<= 1
    
    dira[constant(((Clock_Pin <# 31) #> 0))] := false
       
    result |= ina[constant(((Data_Pin <# 31) #> 0))]
    
    dira[constant(((Clock_Pin <# 31) #> 0))] := true
   
  dira[constant(((Data_Pin <# 31) #> 0))] := aknowledge
   
  dira[constant(((Clock_Pin <# 31) #> 0))] := false
  dira[constant(((Clock_Pin <# 31) #> 0))] := true 

  dira[constant(((Data_Pin <# 31) #> 0))] := true       

PRI startDataTransfer ' 3 Stack Longs 

  dira[constant(((Data_Pin <# 31) #> 0))] := true
  dira[constant(((Clock_Pin <# 31) #> 0))] := true     

PRI stopDataTransfer ' 3 Stack Longs 

  dira[constant(((Clock_Pin <# 31) #> 0))] := false 
  dira[constant(((Data_Pin <# 31) #> 0))] := false
   
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