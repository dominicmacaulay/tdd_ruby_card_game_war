# frozen_string_literal: true

require_relative 'war_socket_server'
require_relative 'war_game'

# runs the game on a server
class WarSocketRunner
  attr_reader :game, :clients, :server
  attr_accessor :are_players_prompted, :pending_players

  def initialize(game, clients)
    @game = game
    @clients = clients
    @are_players_prompted = false
    @pending_players = store_pending_players
  end

  def start
    run_game
  end

  def run_game
    until game.winner
      prompt_players if are_players_prompted == false
      run_round_if_possible
    end
    send_feedback("Winner is #{game.winner.name}")
  end

  def run_round_if_possible
    return unless ready_up

    match_result = game.play_round
    send_feedback(match_result)
    self.are_players_prompted = false
    self.pending_players = store_pending_players
  end

  def send_feedback(message)
    clients.each { |client| send_message_to_client(client.first, message) }
  end

  def ready_up
    pending_players.each do |client|
      pending_players.delete(client) if confirm_ready(client)
    end
    pending_players.empty?
  end

  def store_pending_players
    players = []
    game.players.each do |player|
      players.push(clients.key(player))
    end
    players
  end

  def prompt_players
    game.players.each do |player|
      send_message_to_client(clients.key(player), "Are you ready to play? Enter 'ready' if so.")
    end
    self.are_players_prompted = true
  end

  def confirm_ready(client)
    return false unless retreive_message_from_player(client) == 'ready'

    send_message_to_client(client, 'Waiting for other players to ready')
    true
  end

  def send_message_to_client(client, text)
    client.puts(text)
  end

  def retreive_message_from_player(client, delay = 0.1)
    sleep(delay)
    client.read_nonblock(1000).chomp.downcase # not gets which blocks
  rescue IO::WaitReadable
    ''
  end
end
