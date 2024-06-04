require 'socket'

class WarSocketServer
  def initialize
  end

  def port_number
    3336
  end

  def games
    []
  end

  def start
    @server = TCPServer.new(port_number)
  end

  def accept_new_client(player_name = "Random Player")
    client = @server.accept_nonblock
    # associate player and client
  rescue IO::WaitReadable, Errno::EINTR
    puts "No client to accept"
  end

  def create_game_if_possible
  end

  def stop
    @server.close if @server
  end
end