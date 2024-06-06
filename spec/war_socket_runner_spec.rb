# frozen_string_literal: true

require 'spec_helper'
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

RSpec.describe WarSocketRunner do # rubocop:disable Metrics/BlockLength
  before(:each) do
    @clients = []
    @server = WarSocketServer.new
    @server.start
    sleep(0.1)
    @client1 = create_client('P 1')
    @client2 = create_client('P 2')
    @game = @server.create_game_if_possible
    @runner = @server.create_runner(@game)
  end

  after(:each) do
    @server.stop
    @clients.each(&:close)
  end

  describe '#run_round_if_possible' do # rubocop:disable Metrics/BlockLength
    before do
      @game.start
    end
    it 'puts appropriate prompt messages for each player' do
      @runner.run_round_if_possible
      expect(@client1.capture_output).to match 'Enter'
      expect(@client2.capture_output).to match 'Enter'
    end
    it 'puts prompt only if the players have not yet been prompted' do
      @runner.are_players_prompted = true
      @runner.run_round_if_possible
      expect(@client1.capture_output).not_to match 'Enter'
      expect(@client2.capture_output).not_to match 'Enter'
    end
    it 'puts appropriate waiting message for each player' do
      @client1.provide_input('ready')
      @client2.provide_input('ready')
      @runner.run_round_if_possible
      expect(@client1.capture_output).to match 'Waiting'
      expect(@client2.capture_output).to match 'Waiting'
    end
    it 'puts match results' do
      @client1.provide_input('ready')
      @client2.provide_input('ready')
      @runner.run_round_if_possible
      expect(@client1.capture_output).to match 'took'
      expect(@client2.capture_output).to match 'took'
    end
    it 'changes variables back to their original states' do
      @client1.provide_input('ready')
      @client2.provide_input('ready')
      @runner.run_round_if_possible
      expect(@runner.are_players_prompted).to be false
      expect(@runner.pending_players).to eq(@runner.clients)
    end
  end
  def create_client(name)
    client = MockWarSocketClient.new(@server.port_number)
    @clients.push(client)
    @server.accept_new_client(name)
    client
  end
end
