# frozen_string_literal: true

require_relative '../lib/war_socket_server'
require_relative '../lib/war_game'
require_relative '../lib/war_socket_runner'

class MockWarSocketClient
  attr_reader :socket, :output

  def initialize(port)
    @socket = TCPSocket.new('localhost', port)
  end

  def provide_input(text)
    @socket.puts(text)
  end

  def capture_output(delay = 0.1)
    sleep(delay)
    @output = @socket.read_nonblock(1000).chomp # not gets which blocks
  rescue IO::WaitReadable
    @output = ''
  end

  def close
    @socket&.close
  end
end

describe WarSocketRunner do # rubocop:disable Metrics/BlockLength
  before(:each) do
    @clients = []
    @server = WarSocketServer.new
    @server.start
    sleep(0.1)
    @client1 = create_client('P 1')
    @client2 = create_client('P 2')
    game = @server.create_game_if_possible
    @runner = WarSocketRunner.new(game, @server.clients)
  end

  after(:each) do
    @server.stop
    @clients.each(&:close)
  end

  describe '#run_game' do
    it 'calls #ready_up' do
      expect(@runner).to receive(:ready_up)
      @runner.run_game
    end
  end

  describe '#ready_up' do
    it 'calls the confirm_ready method until all players say yes' do
      allow(@runner).to receive(:prompt_to_ready_and_store_players).and_return(@runner.clients.keys)
      allow(@runner).to receive(:confirm_ready).and_return(false, false, true, true)
      expect(@runner).to receive(:confirm_ready).at_least(@clients.length * 2).times
      @runner.ready_up
    end
  end

  describe '#prompt_to_ready_and_store_players' do
    it 'Ask each player if they are ready' do
      @runner.prompt_to_ready_and_store_players
      expect(@client1.capture_output.chomp).to eq("Are you ready to play? Enter 'ready' if so.")
      expect(@client2.capture_output.chomp).to eq("Are you ready to play? Enter 'ready' if so.")
    end
  end
  def create_client(name)
    client = MockWarSocketClient.new(@server.port_number)
    @clients.push(client)
    @server.accept_new_client(name)
    client
  end
end
