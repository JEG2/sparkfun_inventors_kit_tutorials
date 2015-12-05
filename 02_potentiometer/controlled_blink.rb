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

potentiometer = board.pins[14]
board.set_pin_mode(14, Firmata::Board::ANALOG)

sleep_length = 0

potentiometer_monitor = Thread.new do
  loop do
    board.read_and_process
    sleep_length = potentiometer.value / 1_000.0
    sleep 0.25
  end
end

led_changer = Thread.new do
  loop do
    board.digital_write(13, Firmata::Board::HIGH)
    sleep sleep_length
    board.digital_write(13, Firmata::Board::LOW)
    sleep sleep_length
  end
end

[potentiometer_monitor, led_changer].each(&:join)
