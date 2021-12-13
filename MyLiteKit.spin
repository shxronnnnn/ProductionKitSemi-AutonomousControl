{
  PROJECT: EE-10 ASSIGNMENT
  PLATFORM: PARALLEX PROJECT USB BOARD
  REVISION: 1.1
  AUTHOR: SHARON SIM
  DATE 15 NOV 2021
  LOG:
        DATE: DESCRIPTION
        15 NOV 21  Create Functions to detect obstacles
        20 NOV 21 Include Comm control
        29 NOV 21  Implemented comm control to move motors
}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

       'Creating a pause()
        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        _Ms_001 =_ConclkFreq / 1_000

        'Sensor Control
        tofSafeVal       = 150
        ultraSafeVal     = 200

        'Comm Control
        commStart        = $7A
        commForward      = $01
        commReverse      = $02
        commLeft         = $03
        commRight        = $04
        commStopAll      = $AA

        'Motor Control
        mainMotorForward = 0
        mainMotorReverse = 1
        mainMotorLeft    = 2
        mainMotorRight   = 3
        mainMotorStopAll = 4
        mainMotorSpeed   = 100

VAR
     long mainUltra1Val, mainUltra2Val, mainTof1Val, mainTof2Val
     long mainMotorControl, MotorSpeed
     long mainControlVal


OBJ
  Term            : "FullDuplexSerial.spin"
  Motor           : "MotorControl.spin"
  Sensor          : "SensorControl.spin"
  Comm            : "CommControl.spin"

PUB Main          'Core 0
  'Terminal Initialisation
  Term.Start(31, 30, 0, 115200) 'Turn on terminal
  Pause(500)

  'Initialise Controls
  Comm.Start(_Ms_001, @mainControlVal)
  Sensor.Start(_Ms_001, @mainTof1Val, @mainTof2Val, @mainUltra1Val, @mainUltra2Val)
  Motor.Start(_Ms_001, @mainMotorControl, @MotorSpeed)

{
    'Check for sensor values using SensorControl
    repeat
      Term.Str(String(13, "Ultrasonic Front Readings: "))
      Term.Dec(mainUltra1Val)
      Term.Str(String(13, "Ultrasonic Back Readings: "))
      Term.Dec(mainUltra2Val)
      Term.Str(String(13, "Tof Front Reading: "))
      Term.Dec(mainTof1Val)
      Term.Str(String(13, "Tof Back Reading: "))
      Term.Dec(mainTof2Val)
      Pause(100)
      Term.Tx(0)

}


'{
  'Semi Autonomous using SensorControl & MotorControl

    'Forward   'ultraSafeVal = 150;  tofSafeVal = 200
    repeat
      if (mainUltra1Val > ultraSafeVal or mainUltra1Val == 0) and (mainToF1Val < tofSafeVal)
        mainMotorControl := mainMotorForward     'Set motor direction to move forward
        MotorSpeed := 100
      else
        mainMotorControl := 4      'Set motor direction to move s

'}

{
  'Comm Control

  repeat
    'Term.Str(String(13, "Comm Control: "))
    'Term.Dec(mainControlVal)
    case mainControlVal
      1:                        'CommControl receives forward
        if (mainUltra1Val > ultraSafeVal or mainUltra1Val == 0) and (mainToF1Val < tofSafeVal)  'Check if sensor values are within safe range
          mainMotorControl := mainMotorForward        'assign direction to MotorControl
          MotorSpeed := mainMotorSpeed                'Assign speed to MotorControl
        else
          mainMotorControl := mainMotorStopAll

      2:                        'CommControl receives reverse
        if (mainUltra2Val > ultraSafeVal or mainUltra2Val == 0) and (mainToF2Val < tofSafeVal)  'Check if sensor values are within safe range
          mainMotorControl := mainMotorReverse        'assign direction to MotorControl
          MotorSpeed := mainMotorSpeed                'Assign speed to MotorControl
        else
          mainMotorControl := mainMotorStopAll

      3:                        'CommControl receives left
        mainMotorControl := mainMotorLeft             'assign direction to MotorControl
        MotorSpeed := mainMotorSpeed                  'Assign speed to MotorControl

      4:                        'CommControl receives right
        mainMotorControl := mainMotorRight            'assign direction to MotorControl
        MotorSpeed := mainMotorSpeed                  'Assign speed to MotorControl

      5:                        'CommControl receives stop
        mainMotorControl := mainMotorStopAll          'assign direction to MotorControl

}

PRI Pause(ms) | t
t:= cnt-1088                         'sync with system counter

repeat (ms#>0)                       'delay must be > 0
  waitcnt( t+=_MS_001)
return