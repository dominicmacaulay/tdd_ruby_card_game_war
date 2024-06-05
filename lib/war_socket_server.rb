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
      players = get_players
      games.push(WarGame.new(*players))
      return games[-1]
    end
    pending_clients.each { |client| client.puts("Waiting for other player(s) to join") }
  end

  def get_players
    players =[]
    until players.length == players_per_game
      players.push(clients[pending_clients.shift])
    end
    players
  end

  def run_game(game)
    ready_up(game)
  end

  def ready_up(game)
    game.players.each do |player| 
      clients.key(player).puts("Are you ready to play? Enter 'ready' if so.") 
      capture_output(clients.key(player))
    end
  end

  def capture_output(client, delay=0.1)
    sleep(delay)
    output = client.read_nonblock(1000) # not gets which blocks
  rescue IO::WaitReadable
    output = ""
  end

  def stop
    @server.close if @server
  end
end