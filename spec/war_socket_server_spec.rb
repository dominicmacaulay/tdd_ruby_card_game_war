require 'socket'
require_relative '../lib/war_socket_server'
require_relative '../lib/war_game'

class MockWarSocketClient
  attr_reader :socket
  attr_reader :output

  def initialize(port)
    @socket = TCPSocket.new('localhost', port)
  end

  def provide_input(text)
    @socket.puts(text)
  end

  def capture_output(delay=0.1)
    sleep(delay)
    @output = @socket.read_nonblock(1000) # not gets which blocks
  rescue IO::WaitReadable
    @output = ""
  end

  def close
    @socket.close if @socket
  end
end

describe WarSocketServer do
  before(:each) do
    @clients = []
    @server = WarSocketServer.new
    @server.start
    sleep(0.1)
  end

  after(:each) do
    @server.stop
    @clients.each do |client|
      client.close
    end
  end

  it "is not listening on a port before it is started"  do
    @server.stop
    expect {MockWarSocketClient.new(@server.port_number)}.to raise_error(Errno::ECONNREFUSED)
  end

  describe "#accept_new_client" do
    it "accepts new clients into the pending and full client lists" do
      client1 = MockWarSocketClient.new(@server.port_number)
      @clients.push(client1)
      @server.accept_new_client("Player 1")
      client2 = MockWarSocketClient.new(@server.port_number)
      @clients.push(client2)
      @server.accept_new_client("Player 2")
      expect(@server.pending_clients.length).to be @clients.length
      expect(@server.clients.length).to be @clients.length
    end
  end

  describe "#create_game_if_possible" do
    it "starts a game only if there are enough players" do
      client1 = MockWarSocketClient.new(@server.port_number)
      @clients.push(client1)
      @server.accept_new_client("Player 1")
      @server.create_game_if_possible
      expect(@server.games.count).to be 0
      client2 = MockWarSocketClient.new(@server.port_number)
      @clients.push(client2)
      @server.accept_new_client("Player 2")
      @server.create_game_if_possible
      expect(@server.games.count).to be 1
    end
    
    it "returns a WarGame object if there are enough players" do
      MockWarSocketClient.new(@server.port_number)
      @server.accept_new_client("Player 1")
      MockWarSocketClient.new(@server.port_number)
      @server.accept_new_client("Player 2")
      game = @server.create_game_if_possible
      expect(game).to be_a(WarGame)

    end

    it "sends the client a pending message when there are not enough players yet" do
      client1 = MockWarSocketClient.new(@server.port_number)
      @clients.push(client1)
      @server.accept_new_client("Player 1")
      @server.create_game_if_possible
      expect(client1.capture_output.chomp).to eq("Waiting for other player(s) to join")
    end
  end

  describe "#run_game" do
    it "calls #ask_ready" do
      MockWarSocketClient.new(@server.port_number)
      @server.accept_new_client("Player 1")
      MockWarSocketClient.new(@server.port_number)
      @server.accept_new_client("Player 2")
      game = @server.create_game_if_possible
      expect(@server).to receive(:ask_ready)
      @server.run_game(game)
    end
  end

  describe "#ask_ready" do
    it "sends the client a pending message when the other player(s) haven't agreed to play a round" do
      client1 = MockWarSocketClient.new(@server.port_number)
      @server.accept_new_client("Player 1")
      client2 = MockWarSocketClient.new(@server.port_number)
      @server.accept_new_client("Player 2")
      game = @server.create_game_if_possible
      @server.run_game(game)
      expect(client1.capture_output.chomp).to eq("Are you ready to begin?")
      expect(client2.capture_output.chomp).to eq("Are you ready to begin?")
    end
  end
  # Add more tests to make sure the game is being played
  # For example:
  #   make sure the mock client gets appropriate output
  #   make sure the next round isn't played until both clients say they are ready to play
  #   ...
end