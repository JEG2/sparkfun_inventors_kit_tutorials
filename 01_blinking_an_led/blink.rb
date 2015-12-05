require "firmata"

board = Firmata::Board.new("/dev/cu.usbserial-DA01MF3D")
board.connect

board.digital_write(13, Firmata::Board::HIGH)

firmata_handler = trap(:INT) do
  board.reset
  firmata_handler.call
end

loop do
  sleep
end
