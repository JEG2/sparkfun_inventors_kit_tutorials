require "firmata"

board = Firmata::Board.new("/dev/cu.usbserial-DA01MF3D")
board.connect

firmata_handler = trap(:INT) do
  board.reset
  firmata_handler.call
end

board.query_capabilities
board.read_and_process
board.query_analog_mapping
board.read_and_process

RED_PIN   = 9
GREEN_PIN = 10
BLUE_PIN  = 11
[RED_PIN, GREEN_PIN, BLUE_PIN].each do |pin|
  board.set_pin_mode(pin, Firmata::Board::OUTPUT)
end

{
  off:    {RED_PIN => false, GREEN_PIN => false, BLUE_PIN => false},
  red:    {RED_PIN => true,  GREEN_PIN => false, BLUE_PIN => false},
  green:  {RED_PIN => false, GREEN_PIN => true,  BLUE_PIN => false},
  blue:   {RED_PIN => false, GREEN_PIN => false, BLUE_PIN => true},
  yellow: {RED_PIN => true,  GREEN_PIN => true,  BLUE_PIN => false},
  cyan:   {RED_PIN => false, GREEN_PIN => true,  BLUE_PIN => true},
  purple: {RED_PIN => true,  GREEN_PIN => false, BLUE_PIN => true},
  white:  {RED_PIN => true,  GREEN_PIN => true,  BLUE_PIN => true}
}.each_value do |pins|
  pins.each do |pin, on|
    board.digital_write(pin, Firmata::Board.const_get(on ? :HIGH : :LOW))
  end

  sleep 1
end

[RED_PIN, GREEN_PIN, BLUE_PIN].each do |pin|
  board.set_pin_mode(pin, Firmata::Board::PWM)
end

768.times do |i|
  r, g, b = 0, 0, 0
  if i <= 255
    r = 255 - i
    g = i
  elsif i <= 511
    g = 255 - (i - 256)
    b = i - 256
  else # i >= 512
    r = i - 512
    b = 255 - (i - 512)
  end
  board.analog_write(RED_PIN, r)
  board.analog_write(GREEN_PIN, g)
  board.analog_write(BLUE_PIN, b)

  sleep 0.01
end

board.reset
