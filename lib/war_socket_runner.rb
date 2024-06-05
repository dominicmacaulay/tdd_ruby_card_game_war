# frozen_string_literal: true

require_relative 'war_socket_server'
require_relative 'war_game'

# runs the game on a server
class WarSocketRunner
  attr_reader :game, :clients

  def initialize(game, clients)
    @game = game
    @clients = clients
  end

  def start
    run_game
  end

  def run_game
    ready_up
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
end
