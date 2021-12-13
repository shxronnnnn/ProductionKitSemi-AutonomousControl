{
  PROJECT: EE-7 ASSIGNMENT
  PLATFORM: PARALLEX PROJECT USB BOARD
  REVISION: 1.1
  AUTHOR: SHARON SIM
  DATE 13 NOV 2021
  LOG:
        DATE: DESCRIPTION
        15 NOV 21  Create Functions to detect obstacles
        20 NOV 21 Include Comm control
}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

       'Creating a pause()
        '_ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        '_Ms_001 =_ConclkFreq / 1_000

        commRxPin        = 20      'Din
        commTxPin        = 21      'DOut
        commBaud         = 9600

        commStart        = $7A
        commForward      = $01
        commReverse      = $02
        commLeft         = $03
        commRight        = $04
        commStopAll      = $AA

VAR
     long Cog, CogStack[64],_Ms_001


OBJ

  Comm           : "FullDuplexSerial.spin"

PUB Start(mainMsVal, mainControlAdd)

    _Ms_001 := mainMsVal
    StopCore
    Cog := cognew(CommCore(mainControlAdd),@CogStack)         'Start new core

PUB CommCore(mainControlAdd) | rxValue

  Comm.Start(commTxPin, commRxPin, 0, commBaud)
  Pause(3000)

  repeat
    rxValue := Comm.RxCheck      'Check if byte but not wait
    if (rxValue == commStart)
      repeat
        rxValue := Comm.RxCheck
        case rxValue
          commForward:
            long[mainControlAdd] := 1

          commReverse:
            long[mainControlAdd] := 2

          commLeft:
            long[mainControlAdd] := 3

          commRight:
            long[mainControlAdd] := 4

          commStopAll:
            long[mainControlAdd] := 5



PUB StopCore                  'Stop Cog

  IF Cog
    cogstop(Cog~)

PRI Pause(ms) | t
t:= cnt-1088                         'sync with system counter

repeat (ms#>0)                       'delay must be > 0
  waitcnt( t+=_MS_001)
return