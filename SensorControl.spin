 {
  PROJECT: EE-7 ASSIGNMENT
  PLATFORM: PARALLEX PROJECT USB BOARD
  REVISION: 1.1
  AUTHOR: SHARON SIM
  DATE 13 NOV 2021
  LOG:
        DATE: DESCRIPTION
        13 NOV 21 : Create Functions to read sensors
        20 NOV 21 : ENCAPSULATE OBJ FILE
}

CON

        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

       'Creating a pause()
        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        _Ms_001 =_ConclkFreq / 1_000

      ' Declare Pins for sensors
        ultra1SCL = 6
        ultra1SDA = 7
        ultra2SCL = 8
        ultra2SDA = 9

        ToF1SCL    = 0
        ToF1SDA    = 1
        ToF1RST    = 14
        ToF2SCL    = 2
        ToF2SDA    = 3
        ToF2RST    = 15
        ToFAdd     = $29

VAR
     long Cog, CogStack[64]

OBJ
  'Term            : "FullDuplexSerial.spin"
  Ultra           : "EE-7_Ultra_v2.spin"
  ToF[2]          : "EE-7_ToF.spin"

PUB Start(mainMSVal, mainTof1Add, mainTof2Add, mainUltra1Add, mainUltra2Add)

  StopCore     'Stop previous running core
  Cog := cognew(SensorCore(mainTof1Add, mainTof2Add, mainUltra1Add, mainUltra2Add), @CogStack)  'Start new cog

PUB SensorCore(mainTof1Add, mainTof2Add, mainUltra1Add, mainUltra2Add)

  'Terminal Initialisation
  'Term.Start(31, 30, 0, 115200) 'Turn on terminal
  'Pause(500)

  'Ultrasonic Initialisation
  Ultra.Init(ultra1SCL, ultra1SDA, 0)
  Ultra.Init(ultra2SCL, ultra2SDA, 1)

  'Time of Flight Initialisation
  ToF[0].Init(ToF1SCL, ToF1SDA, ToF1RST)
  ToF[0].ChipReset(1)
  ToF[1].Init(ToF2SCL, ToF2SDA, ToF2RST)
  ToF[1].ChipReset(1)
  Pause(1000)
  ToF[0].FreshReset(ToFAdd)
  ToF[1].FreshReset(ToFAdd)
  ToF[0].MandatoryLoad(ToFAdd)
  ToF[1].MandatoryLoad(ToFAdd)
  ToF[0].RecommendedLoad(ToFAdd)
  ToF[1].RecommendedLoad(ToFAdd)
  ToF[0].FreshReset(ToFAdd)
  ToF[1].FreshReset(ToFAdd)

  'Read Sensor values
  repeat
    long[mainUltra1Add] := Ultra.readSensor(0) 'cast operator is required because we are putting values into an address with a long data type
    long[mainUltra2Add] := Ultra.readSensor(1) 'without the cast operator, we are changing the address
    long[mainTof1Add] := ToF[0].GetSingleRange(ToFAdd)
    long[mainTof2Add] := ToF[1].GetSingleRange(ToFAdd)
    Pause(50)

PUB StopCore                  'Stop Cog

  IF Cog

    cogstop(Cog~)

PRI Pause(ms) | t
t:= cnt-1088                         'sync with system counter

repeat (ms#>0)                       'delay must be > 0
  waitcnt( t+= _Ms_001)
return