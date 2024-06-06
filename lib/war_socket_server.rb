# frozen_string_literal: true

require 'socket'
require_relative 'war_player'
require_relative 'war_game'

# runs interactions between the clients and the server
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

  def accept_new_client(player_name = 'Random Player')
    client = @server.accept_nonblock
    pending_clients.push(client)
    clients[client] = Player.new(player_name)
  rescue IO::WaitReadable, Errno::EINTR
    puts 'No client to accept'
  end

  def create_game_if_possible
    if pending_clients.length >= players_per_game
      players = retrieve_players
      games.push(WarGame.new(*players))
      return games.last
    end
    pending_clients.each { |client| client.puts('Waiting for other player(s) to join') }
  end

  def run_game(game)
    create_runner(game).start
  end

  def create_runner(game)
    clients = game.players.map { |player| clients.key(player) }
    WarSocketRunner.new(game, clients)
  end

  def retrieve_players
    players_per_game.times.map do
      clients[pending_clients.shift]
    end
  end

  def provide_input(client, message)
    client.puts(message)
  end

  def capture_output(client, delay = 0.1)
    sleep(delay)
    client.read_nonblock(1000).chomp.downcase # not gets which blocks
  rescue IO::WaitReadable
    ''
  end

  def stop
    @server&.close
  end
end
