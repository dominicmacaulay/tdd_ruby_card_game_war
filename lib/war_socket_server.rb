require 'socket'
require_relative 'war_player'
require_relative 'war_game'

class WarSocketServer
    attr_accessor :games, :pending_clients, :clients
    attr_reader :players_per_game
  def initialize(players_per_game = 2)
    @players_per_game = players_per_game
    @games = []
    @pending_clients = []
    @clients = {}
  end

  def port_number
    3336
  end

  def start
    @server = TCPServer.new(port_number)
  end

  def accept_new_client(player_name = "Random Player")
    client = @server.accept_nonblock
    self.pending_clients.push(client)
    self.clients[client] = Player.new(player_name)
  rescue IO::WaitReadable, Errno::EINTR
    puts "No client to accept"
  end

  def create_game_if_possible
    if self.pending_clients.length >= players_per_game
      games.push(WarGame.new(*get_players))
      return games[-1]
    end
    pending_clients.each { |client| client.puts("Waiting for other player(s) to join") }
  end

  def get_players
    x = 0
    players =[]
    until x == players_per_game
      players.push(clients[pending_clients.shift])
      x += 1
    end
  end

  def run_game(game)
  end

  def stop
    @server.close if @server
  end
end