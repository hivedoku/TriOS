{{******************************************************************************}
{ FileName............: Dcf77.spin                                             }
{ Project.............:                                                        }
{ Author(s)...........: MM                                                     }
{ Version.............: 1.00                                                   }
{------------------------------------------------------------------------------}
{  DCF77 (clock) control                                                       }
{                                                                              }
{  Copyright (C) 2006-2007  M.Majoor                                           }
{                                                                              }
{  This program is free software; you can redistribute it and/or               }
{  modify it under the terms of the GNU General Public License                 }
{  as published by the Free Software Foundation; either version 2              }
{  of the License, or (at your option) any later version.                      }
{                                                                              }
{  This program is distributed in the hope that it will be useful,             }
{  but WITHOUT ANY WARRANTY; without even the implied warranty of              }
{  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               }
{  GNU General Public License for more details.                                }
{                                                                              }
{  You should have received a copy of the GNU General Public License           }
{  along with this program; if not, write to the Free Software                 }
{  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA. }
{                                                                              }
{------------------------------------------------------------------------------}
{                                                                              }
{ Version   Date    Comment                                                    }
{  1.00   20070727  - Initial release                                          }
{******************************************************************************}

{------------------------------------------------------------------------------}
  DCF77 is a time signal being transmitted by 'radio'. The time signal being
  transmitted is based on an atomic clock.
  This code assumes we have a DCF77 receiver with a digital output. This output
  is connected to one of the available input pins.
  The output pin of the DCF77 receiver changes it output according to the
  received radio signal. This radio signal is an amplitude modulated signal.
  The amplitude level is converted into a digital signal by the DCF77 receiver.
  A typical output signal of a DCF77 receiver is:

    ┌──┐                 ┌──┐                   ┌─┐
    │  │                 │  │                   │ │
    │  │                 │  │                   │ │
    │  │                 │  │                   │ │
    ┘  └─────────────────┘  └───────────────────┘ └──────────────────

  The spacing of these pulses is 1 second. Every second the amplitude signal is
  being lowered for a small duration (0.1 s or 0.2 s). This lowered amplitude
  is being output as a pulse here.
  The duration of the pulse defines whether it represents a digital '0' or a
  digital '1'.
  These digital '0' and '1' together form a digital representation of the time.
  This digital stream of bits is being transmitted within one minute. The next
  minute a new digital stream starts.
  For synchronization purposes there will be no pulse when the 59's digital signal
  is being transmitted. This is used to indicate the start of the next digital
  stream (and the next minute).
  The pulse length is converted into a binary signal according to its length:
    0.1s  -->  '0'
    0.2s  -->  '1'

  The digital stream format is (with the first received bit at the right):

       5 555555555 44444 444 443333 3333332 22222222 211111 11111
  Sec  9 876543210 98765 432 109876 5432109 87654321 098765 432109876543210

       D P84218421 18421 421 218421 P218421 P4218421 SAZZAR
         30000     0         00     200     1000      2211



     R  = Call bit (irregularities in DCF77 control facilities)

     A1 = '1' Imminent change-over of time from CET <-> CEST
              Transmitted 1 hour prior to change (refelected in Z1/Z2)
     Z1 = Zone time bit 0       '10' = CET ;                             UTC + 1 hour
     Z2 = Zone time bit 1       '01' = CEST; DST ; dayligt saving time,  UTC + 2 hours
     A2 = '1' Imminent change-over of leap second
              Transmitted 1 hour prior to change (January 1/July 1)

     S  = Startbit coded time information (always '1')

     1  = Minute (BCD)
     2  = ,,
     4  = ,,
     8  = ,,
     10 = ,,
     20 = ,,
     40 = ,,
     P1 = Parity bit preceeding 7 bits (all bits including parity equals even number)

     1  = Hour (BDC)
     2  = ,,
     4  = ,,
     8  = ,,
     10 = ,,
     20 = ,,
     P2 = Parity bit preceeding 6 bits (all bits including parity equals even number)

     1  = Calendar day (BCD)
     2  = ,,
     4  = ,,
     8  = ,,
     10 = ,,
     20 = ,,

     1  = Day of the week (BCD)    1 = Monday
     2  = ,,
     4  = ,,

     1  = Month (BCD)
     2  = ,,
     4  = ,,
     8  = ,,
     10 = ,,

     1  = Year (BCD)
     2  = ,,
     4  = ,,
     8  = ,,
     10 = ,,
     20 = ,,
     40 = ,,
     80 = ,,

     P3 = Parity bit preceeding 22 bits (all bits including parity equals even number)

     D  = No pulse here except for leap second ('0' pulse) -> the next (leap) second
          then has no pulse.
          The pulse following the 'no pulse' indicates start of next minute/data stream.


  The DCF device is connected as follows:
                               3V3
                    ┌────────┐ 
           R        │  DCF   │ 10k
     3V3  ──┳──┳──┤        ├─┻── Input
              C   │ device │
         ┌────┻──┻──┤        │
                   └────────┘

            R = 1kΩ
            C = 1uF + 1nF

  The resistor here has one major purpose: filtering out any noise from the 3V3
  power supply, which is typically connected directly to the Propeller device.
  Since the DCF signal itself is a low frequency (77.5 kHz), it falls within
  the frequency range of the Propeller chip itself, which can lead to problems.
  Without this resistor the DCF device was unable to function properly. The
  resistor has very little impact on the voltage available to the DCF device.
  Because the DCF device draws very little current, the voltage drop over the
  resistor is very low (0.08V here).
{------------------------------------------------------------------------------}}


CON
  CDcfIn                 = 22                              ' Input  pin for DCF77                              _>Hive ADM-Port 1 ->Expansionsbus B17
  CDcfOut                = 24                              ' Output pin for DCF77 signal (debug/visualization) ->Hive-Administra-LED
  CDcfLevel              = 1                               ' Level for '1' signal
  CNoSync                = 0                               ' Not in sync (never sync data received)
  CInSync                = 1                               ' In sync     (no error since last sync)
  CInSyncWithError       = 2                               ' Not in sync (error since last sync), but time is up to date
  CCest                  = 1                               ' CEST timezone (daylight saving time)
  CCet                   = 2                               ' CET  timezone
  CAm                    = 0                               ' AM
  CPm                    = 1                               ' PM

VAR
  byte Cog                                                 ' Active cog
  long Stack[26]                                           ' Stack for cog
  byte Bits[8]                                             ' Current detection of pulses (bit access)
  long BitLevel                                            ' Current bit level  (NOT the signal level!)
  long BitError                                            ' Current bit status
  byte BitNumber                                           ' Current index of bit (== seconds)

  ' Time settings
  byte DataCount                                           ' Incremented when data below updated
  byte TimeIndex                                           ' Indicates the active index for the time settings
                                                           ' Typically the background writes in one of the registers
                                                           ' and if they all check out it makes them available by
                                                           ' changing the TimeIndex.
  byte InSync                                              ' Synchronization indication

  byte TimeZone[2]
  byte Seconds[2]
  byte Minutes[2]
  byte Hours[2]                                            ' 0..23 hour indication
  byte HoursAmPm[2]                                        ' 1..12 hour indication (used with AM/PM)
  byte AmPm[2]
  byte WeekDay[2]
  byte Day[2]
  byte Month[2]
  word Year[2]


{{------------------------------------------------------------------------------
  Params  : -
  Returns : <Result>  TRUE if cog available

  Descript: Start DCF acquisition
  Notes   :
 ------------------------------------------------------------------------------}}

PUB Start: Success
{
 DIRA[dcfstart]~~
 outa[dcfstart]:=1
 waitcnt((clkfreq * 2)+ cnt)
 outa[dcfstart]:=0
 }
 result := Cog := cognew(DcfReceive, @Stack)


{{------------------------------------------------------------------------------
  Params  : -
  Returns : -

  Descript: Stop cog and DCF acquisition
  Notes   :
 ------------------------------------------------------------------------------}}
PUB Stop
  if Cog == 0                                              ' Only if cog is active
    return
  cogstop(Cog)                                             ' Stop the cog


{{------------------------------------------------------------------------------
  Params  : -
  Returns : -

  Descript: Interfaces to variables
  Notes   :
 ------------------------------------------------------------------------------}}
PUB GetActiveSet: Value
  result := TimeIndex

PUB GetInSync: Value
  result := InSync

PUB GetTimeZone: Value
  result := TimeZone[TimeIndex]

PUB GetSeconds: Value
  result := Seconds[TimeIndex]

PUB GetMinutes: Value
  result := Minutes[TimeIndex]

PUB GetHours: Value
  result := Hours[TimeIndex]

PUB GetWeekDay: Value
  result := WeekDay[TimeIndex]

PUB GetDay: Value
  result := Day[TimeIndex]

PUB GetMonth: Value
  result := Month[TimeIndex]

PUB GetYear: Value
  result := Year[TimeIndex]

PUB GetBit(Index): Value
  result := Bits[Index]

PUB GetDataCount: Value
  result := DataCount

PUB GetBitNumber: Value
  result := BitNumber

PUB GetBitLevel: Value
  result := BitLevel

PUB GetBitError: Value
  result := BitError


{{------------------------------------------------------------------------------
  Params  : -
  Returns : -

  Descript: Handle DCF reception
  Notes   : At fixed intervals the DCF input is polled. Every second the
            data is checked and the data updated.
            This code does not compensate for a leap second. However, this
            is handled by a resynchronization.
            We use a state machine so we can divide everything up.
            Digital output:
                 On : In sync (no error)
               1 Hz : In sync with DCF77 signal (rising edge is start second)
               3 Hz : In sync with DCF77 signal (59th second)
                      Active in first 0.5 second
              10 Hz : Previous bit had error
                      Active in first 0.5 second
              20 Hz : Resyncing (waiting for pulse, max 1 s); followed by bit
                      error signal
                      This is the only variable in length (time) signal
              The last 100 ms of the 2nd 0.5 second contains a small 40 ms pulse
              when a binary '1' has been detected (for a '0' no pulse is generated)
            If no signal is being received then the following output is
            repeatedly generated:  20 Hz (1s), 10 Hz (0.5s), no signal (0.5s)
 ------------------------------------------------------------------------------}}
PUB DcfReceive | LLocalTime, LIntervalCounts, LState, LWaitInterval, LBitNumber, LBitError, LLevels, LBitLevel, LIndex, LAccu, LParity, LError, LNewData
  DIRA[CDcfIn]~
  DIRA[CDcfOut]~~
  DataCount       := 0
  LLocalTime      := 0
  InSync          := CNoSync
  LNewData        := FALSE
  LWaitInterval   := CNT                                   ' Get current system counter
  LState          := 99                                    ' Last state == initiates new state
  LIntervalCounts := (CLKFREQ / (1000 / 10)) #>381         ' Interval counts
  TimeIndex       := 0
  LIndex          := 1
  repeat

    ' The state machine consists of 100 equal steps
    ' Each of these steps have a time span of 10 ms, getting to a total
    ' of 1 second
    waitcnt(LWaitInterval += LIntervalCounts)              ' Wait for next interval

    ' We keep the local time running independent from the received DCF signal
    ' because that might need synchronization. Only when synchronization has taken place
    ' the local time is synchronized with the DCF. This only happens every minute, when
    ' the received data checks out correctly
    LLocalTime++
    case LLocalTime
      001: ' Update local time
           ' Note: the date is not adjusted
           if Seconds[TimeIndex] == 59
             Seconds[TimeIndex] := 0
             if Minutes[TimeIndex] == 59
               Minutes[TimeIndex] := 0
               if HoursAmPm[TimeIndex] == 12
                 HoursAmPm[TimeIndex] := 1
                 if AmPm[TimeIndex] == CAm
                   AmPm[TimeIndex] := CPm
                 else
                   AmPm[TimeIndex] := CAm
               else
                 HoursAmPm[TimeIndex]++
               if Hours[TimeIndex] == 23
                 Hours[TimeIndex] := 0
                 if WeekDay[TimeIndex] == 7
                   WeekDay[TimeIndex] := 1
                 else
                   WeekDay[TimeIndex]++
               else
                 Hours[TimeIndex]++
             else
               Minutes[TimeIndex]++
           else
             Seconds[TimeIndex]++
      100: LLocalTime := 0

    ' Handling the 0/1 detection
    ' We allow a 10% margin of error:
    '   0   .. 0.3s  0/1 signal detection
    '   0.3 .. 0.9s  signal must be 0
    '   0.9 .. 1  s  not checked
    '   1   .. 2  s  only when resync active
    LState++
    case LState
      01..30  : if INA[CDcfIn] == CDcfLevel
                  LLevels++                                ' We only need to check one level
      31..90  : if INA[CDcfIn] == CDcfLevel
                  LBitError := TRUE                        ' Any signal here is an error
      101..200: if INA[CDcfIn] == CDcfLevel
                  LState := 0                              ' Restart state machine

    ' We divide the second up into several parts, including handling data of the
    ' previous second.
    ' In the last state (100) data from the current second are copied to the data
    ' which is handled the next second
    case LState
      091: if (LLevels => 15)                              ' Decide if we detected a binary '0' or '1'
             LBitLevel := TRUE
             Bits[LBitNumber / 8] |=   (1 << (LBitNumber // 8))
           else
             LBitLevel := FALSE
             Bits[LBitNumber / 8] &=  !(1 << (LBitNumber // 8))
      092: ' Check for illogical data (this might also be the missing pulse occuring every minute)
           if LBitNumber <> 59
             LBitError := LBitError | (LLevels =< 5) | (LLevels => 25)
      093: ' We can check the received data immediately
           ' The background operates on the inactive settings
           if LBitLevel
             LParity++
           case LBitNumber
             0    : if LNewData                            ' If new data, switch over to new data set
                      Seconds[LIndex] := 0                 ' Synchronize seconds
                                                           ' Note: we can not synchronize in the
                                                           '       59th seconds because the 'local time'
                                                           '       state machine adjusts the minutes/hours
                                                           '       when the seconds reaches '60'
                      LLocalTime      := 0                 ' Synchronize the 'local time' state machine
                      if TimeIndex == 0                    ' Switch to different active set
                        TimeIndex := 1
                        LIndex    := 0
                      else
                        TimeIndex := 0
                        LIndex    := 1
                      InSync := CInSync
                      OUTA[CDcfOut]~~                      ' Output on
                    LNewData := FALSE
                    LError   := FALSE
             15                        : ' R  = Call bit (irregularities in DCF77 control facilities)
             16                        : ' A1 = '1' Imminent change-over of time from CET <-> CEST
                                         '      Transmitted 1 hour prior to change (refelected in Z1/Z2)
             19                        :                   ' A2 = '1' Imminent change-over of leap second
                                                           '      Transmitted 1 hour prior to change (January 1/July 1)
             20                        : if !LBitLevel     ' S  = Startbit coded time information (always '1')
                                           LError := TRUE
             17, 42, 45, 50            : if LBitLevel      ' Start new data
                                           LAccu   := 1
                                         else
                                           LAccu   := 0
             21, 29, 36                : if LBitLevel      ' Start new data and parity controlled data
                                           LAccu   := 1
                                           LParity := 1
                                         else
                                           LAccu   := 0
                                           LParity := 0
             18, 22, 30, 37, 43, 46, 51: if LBitLevel      ' 2
                                           LAccu += 2
                                         case LBitNumber
                                           18: TimeZone[LIndex] := LAccu
                                               if (LAccu == %00) or (LAccu == %11)
                                                 LError := TRUE
             23, 31, 38, 44, 47, 52    : if LBitLevel      ' 4
                                           LAccu += 4
                                         case LBitNumber
                                           44: WeekDay[LIndex] := LAccu
             24, 32, 39,     48, 53    : if LBitLevel      ' 8
                                           LAccu += 8
             25, 33, 40,     49, 54    : if LBitLevel      ' 10
                                           LAccu += 10
                                         case LBitNumber
                                           49: Month[LIndex] := LAccu
             26, 34, 41,         55    : if LBitLevel      ' 20
                                           LAccu += 20
                                         case LBitNumber
                                           34: Hours[LIndex] := LAccu
                                               if LAccu > 11         ' 1..12 Hour + AM/PM
                                                 AmPm[LIndex] := CPm
                                               else
                                                 AmPm[LIndex] := CAm
                                               if LAccu > 12
                                                 HoursAmPm[LIndex] := LAccu - 12
                                               else
                                                 if LAccu == 0
                                                   HoursAmPm[LIndex] := 12
                                                 else
                                                   HoursAmPm[LIndex] := LAccu
                                           41: Day[LIndex] := LAccu
             27,                 56    : if LBitLevel      ' 40
                                           LAccu += 40
                                         case LBitNumber
                                           27: Minutes[Lindex] := LAccu
             57                        : if LBitLevel      ' 80
                                           LAccu += 80
                                         Year[LIndex] := 2000 + LAccu
             28, 35, 58                : if (LParity & %1) <> 0
                                           LError := TRUE

             59                        : ' D  = No pulse here except for leap second ('0' pulse) -> the next (leap) second
                                         '      then has no pulse.
                                         '      The pulse following the 'no pulse' indicates start of next minute/data stream.
                                         if !LError
                                           LNewData := TRUE


      100: ' Copy current second data to data we will be handling the next second
           ' and (re)set data for next second
           if !LBitError                                   ' An error switches to the next state (resync)
             LState := 0                                   '   otherwise restart state machine
           BitLevel   := LBitLevel
           LBitLevel  := FALSE
           BitError   := LBitError
           LBitError  := FALSE
           BitNumber  := LBitNumber                        ' Last to change because foreground might check this one
                                                           ' to read others
           LLevels    := 0
           if BitError                                     ' A sync error resets the second counter
             LBitNumber := 0
             if InSync == CInSync
               InSync := CInSyncWithError                  ' 'Out of sync' if we were 'in sync'
           else
             LBitNumber++                                  ' Next second
             if LBitNumber == 60                           ' We could check for leap second here, but ...
               LBitNumber := 0
               DataCount++                                 ' Adjust data indicator for foreground
      201: LState := 0                                     ' Resync failed: restart state machine


    ' Output
    '  time   out  biterror  sec59  level         Note: 'biterror' and 'sec59' never active at same time
    '    1     1      1        1      1
    '   10            0
    '   17                     0
    '   20            1
    '   30            0
    '   34                     1
    '   40            1
    '   50     0      0        0      0
    '   75                     1
    '   91                            1
    '   95     0      0        0      0
    '  101     1      1        1      1
    '   ..     t      t        t      t
    '  195     0      0        0      0
    if InSync <> CInSync                                   ' Only control the output when not in sync
      case LState
        001               : OUTA[CDcfOut]~~                               ' Always on
        010, 020, 030, 040: if BitError                    ' 10 Hz signal (bit error)
                              !OUTA[CDcfOut]
        017, 034, 075     : if !BitError AND (LBitNumber == 59) ' 3 Hz signal (in sync and 59th second)
                              !OUTA[CDcfOut]
        091               : if LBitLevel                   ' Bit is '1'
                              !OUTA[CDcfOut]               ' Always off
        050, 095          : OUTA[CDcfOut]~
        101, 105, 110, 115, 120, 125, 130, 135, 140, 145, 150, 155, 160, 165, 170, 175, 180, 185, 190, 195: !OUTA[CDcfOut]
