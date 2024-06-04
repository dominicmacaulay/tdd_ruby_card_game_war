# lib/war_socket_server_runner.rb

require 'war_socket_server'

server = WarSocketServer.new
server.start
while true do
  server.accept_client
  game = server.create_game_if_possible
  if game
    server.run_game(game)
  end
rescue
  server.stop
end