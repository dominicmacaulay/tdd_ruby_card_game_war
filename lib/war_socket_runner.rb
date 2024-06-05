# frozen_string_literal: true

require_relative 'war_socket_server'
require_relative 'war_game'

# runs the game on a server
class WarSocketRunner
  attr_reader :game, :clients, :server

  def initialize(game, clients, server)
    @game = game
    @clients = clients
    @server = server
  end

  def start
    run_game
  end

  def run_game
    until game.winner
      ready_up
      match_result = game.play_round
      send_feedback(match_result)
    end
    send_feedback("Winner is #{game.winner.name}")
  end

  def send_feedback(message)
    clients.each { |client| server.provide_input(client.first, message) }
  end

  def ready_up
    # TODO: check if there is a way to shorten this
    pending_players = prompt_to_ready_and_store_players
    until pending_players.empty?
      pending_players.each do |client|
        pending_players.delete(client) if confirm_ready(client)
      end
    end
  end

  def prompt_to_ready_and_store_players
    pending_players = []
    game.players.each do |player|
      server.provide_input(clients.key(player), "Are you ready to play? Enter 'ready' if so.")
      pending_players.push(clients.key(player))
    end
    pending_players
  end

  def confirm_ready(client)
    return false unless server.capture_output(client) == 'ready'

    server.provide_input(client, 'Waiting for other players to ready')
    true
  end
end
