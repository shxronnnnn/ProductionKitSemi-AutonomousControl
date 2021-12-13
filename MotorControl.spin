{
  PROJECT: EE-5 ASSIGNMENT
  PLATFORM: PARALLEX PROJECT USB BOARD
  REVISION: 1.1
  AUTHOR: SHARON SIM
  DATE 26 OCT 2021
  LOG:
        DATE: DESCRIPTION
        4 NOV 2021 : DETERMINE THE FUNCTIONS REQUIRED
        6 NOV 2021 : DETERMINE THE ALGORITHM FOR FORWARD, REVERSE, LEFT & RIGHT MOVEMENT
        20 NOV 2021: ENCAPSULATE OBJ FILE
}

CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

       'Creating a pause()
        'ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        '_Ms_001 =_ConclkFreq / 1_000

      ' Declare Pins for motor
       motor1 = 10
       motor2 = 11
       motor3 = 12
       motor4 = 13

       'Values to stop motor
       motor1Zero = 1450
       motor2Zero = 1450
       motor3Zero = 1500
       motor4Zero = 1500

VAR

  long Cog, CoreStack[64],_Ms_001

OBJ

  Motors  : "Servo8Fast_vZ2.spin"          'File to run servo
  'Term: "FullDuplexSerial.spin"           'Terminal only needed to troubleshoot

PUB Start(mainMsVal,Control,mainSpeed)

      _Ms_001 := mainMsVal
      StopCore
      Cog := cognew(MotorCore(Control, mainSpeed),@CoreStack)       'Start a new cog

    'Go to various functions and run accordingly
{     Forward
      Right(0)           '0 is to tell the motor to turn right in the forward direction
      Left(0)            '0 is to tell the motor to turn left in the forward direction
      Reverse
      Left(1)            '1 is to tell the motor to turn left in the reverse direction
      Right(1)           '1 is to tell the motor to turn right in the reverse direction
      StopAllMotors
      StopCore
}
PUB MotorCore(Control,mainSpeed)

  'Initialisation
  Motors.Init
  Motors.AddSlowPin(motor1)
  Motors.AddSlowPin(motor2)
  Motors.AddSlowPin(motor3)
  Motors.AddSlowPin(motor4)
  Motors.Start

  'Direction Control
  repeat
    case long[Control]
      0:                                    'Forward
        Motors.Set(motor1,(motor1Zero + long[mainSpeed]))
        Motors.Set(motor2,(motor2Zero + long[mainSpeed]))
        Motors.Set(motor3,(motor3Zero + long[mainSpeed]))
        Motors.Set(motor4,(motor4Zero + long[mainSpeed]))

      1:                                    'Reverse
        Motors.Set(motor1,motor1Zero - long[mainSpeed])
        Motors.Set(motor2,motor2Zero - long[mainSpeed])
        Motors.Set(motor3,motor3Zero - long[mainSpeed])
        Motors.Set(motor4,motor4Zero - long[mainSpeed])

      2:                                    'Forward Left / Reverse Right
        Motors.Set(motor1,motor1Zero + long[mainSpeed])
        Motors.Set(motor2,motor2Zero - long[mainSpeed])
        Motors.Set(motor3,motor3Zero + long[mainSpeed])
        Motors.Set(motor4,motor4Zero - long[mainSpeed])

      3:                                    'Forward Right /Reverse Left
        Motors.Set(motor1,motor1Zero - long[mainSpeed])
        Motors.Set(motor2,motor2Zero + long[mainSpeed])
        Motors.Set(motor3,motor3Zero - long[mainSpeed])
        Motors.Set(motor4,motor4Zero + long[mainSpeed])

      4:                                    'Stop All Motors
        Motors.Set(motor1,motor1Zero)
        Motors.Set(motor2,motor2Zero)
        Motors.Set(motor3,motor3Zero)
        Motors.Set(motor4,motor4Zero)


PUB StopCore                  'Stop Cog

  IF Cog
    cogstop(Cog~)

PRI Pause(ms) | t
t:= cnt-1088

repeat (ms#>0)
  waitcnt( t+=_MS_001)
return