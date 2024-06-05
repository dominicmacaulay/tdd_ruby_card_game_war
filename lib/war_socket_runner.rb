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
    run_game(game)
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
    self.game.players.each do |player|
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
