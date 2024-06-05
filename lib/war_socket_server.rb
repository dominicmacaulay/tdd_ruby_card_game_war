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

  def retrieve_players
    players_per_game.times.map do
      clients[pending_clients.shift]
    end
  end

  def run_game(game)
    ready_up(game)
  end

  def ready_up(game)
    # TODO: check if there is a way to shorten this
    pending_players = prompt_to_ready_and_store_players(game)
    until pending_players.empty?
      pending_players.each do |client|
        pending_players.remove(client) if confirm_ready(client)
      end
    end
  end

  def prompt_to_ready_and_store_players(game)
    pending_players = []
    game.players.each do |player|
      clients.key(player).puts("Are you ready to play? Enter 'ready' if so.")
      pending_players.push(clients.key(player))
    end
    pending_players
  end

  def confirm_ready(client)
    return false unless capture_output(client) == 'ready'

    client.puts('Waiting for other players to ready')
    true
  end

  def capture_output(client, delay = 0.1)
    sleep(delay)
    output = client.read_nonblock(1000).chomp.downcase # not gets which blocks
  rescue IO::WaitReadable
    output = ''
  end

  def stop
    @server&.close
  end
end
