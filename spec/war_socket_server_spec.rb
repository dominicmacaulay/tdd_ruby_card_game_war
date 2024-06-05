require 'socket'
require_relative '../lib/war_socket_server'
require_relative '../lib/war_game'

class MockWarSocketClient
  attr_reader :socket, :output

  def initialize(port)
    @socket = TCPSocket.new('localhost', port)
  end

  def provide_input(text)
    @socket.puts(text)
  end

  def capture_output(delay=0.1)
    sleep(delay)
    @output = @socket.read_nonblock(1000).chomp # not gets which blocks
  rescue IO::WaitReadable
    @output = ""
  end

  def close
    @socket&.close
  end
end

describe WarSocketServer do # rubocop:disable Metrics/BlockLength
  before(:each) do
    @clients = []
    @server = WarSocketServer.new
    @server.start
    sleep(0.1)
  end

  after(:each) do
    @server.stop
    @clients.each(&:close)
  end

  it 'is not listening on a port before it is started' do
    @server.stop
    expect { MockWarSocketClient.new(@server.port_number) }.to raise_error(Errno::ECONNREFUSED)
  end

  describe '#accept_new_client' do
    it 'accepts new clients into the pending and full client lists' do
      create_client('Player 1')
      create_client('Player 2')
      expect(@server.pending_clients.length).to be @clients.length
      expect(@server.clients.length).to be @clients.length
    end
  end

  describe '#create_game_if_possible' do
    it 'starts a game only if there are enough players' do
      create_client('Player 1')
      @server.create_game_if_possible
      expect(@server.games.count).to be 0
      create_client('Player 2')
      @server.create_game_if_possible
      expect(@server.games.count).to be 1
    end

    it 'returns a WarGame object if there are enough players' do
      MockWarSocketClient.new(@server.port_number)
      @server.accept_new_client('Player 1')
      MockWarSocketClient.new(@server.port_number)
      @server.accept_new_client('Player 2')
      game = @server.create_game_if_possible
      expect(game).to respond_to(:start)
    end

    it 'sends the client a pending message when there are not enough players yet' do
      client1 = create_client('Player 1')
      @server.create_game_if_possible
      expect(client1.capture_output.chomp).to eq('Waiting for other player(s) to join')
    end
  end

  describe '#capture_output' do
    it "receives the downcased client's input" do
      client1 = create_client('P 1')
      client1.provide_input('Hello')
      expect(@server.capture_output(@server.pending_clients.first)).to eq('hello')
      client1.provide_input('reaDy')
      expect(@server.capture_output(@server.pending_clients.first)).to eq('ready')
    end
  end
  # Add more tests to make sure the game is being played
  # For example:
  #   make sure the mock client gets appropriate output
  #   make sure the next round isn't played until both clients say they are ready to play
  #   ...

  def create_client(name)
    client = MockWarSocketClient.new(@server.port_number)
    @clients.push(client)
    @server.accept_new_client(name)
    client
  end
end
