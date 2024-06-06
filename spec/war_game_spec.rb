# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/war_game'
require_relative '../lib/card_deck'

# test the WarGame method
RSpec.describe WarGame do # rubocop:disable Metrics/BlockLength
  describe '#initialize' do
    let(:game) { WarGame.new }
    it 'should create two players by default' do
      expect(game.players.length).to be 2
    end
    it 'should create a deck' do
      expect(game.deck).to respond_to :cards
    end
    it 'should create a nil winner variable' do
      expect(game.winner).to be nil
    end
  end

  describe '#start' do
    let(:game) { WarGame.new }
    it 'should call the shuffle method' do
      game = WarGame.new
      deck = game.deck
      expect(deck).to receive(:shuffle).with(no_args)
      game.start
    end
    it 'should deal until the master deck is empty' do
      game.start
      expect(game.deck.cards_left).to eql(0)
    end
    it 'should deal 26 cards to the players' do
      num_of_players = 2
      hand_length = (game.deck.cards_left / num_of_players)
      game.start
      expect(game.players.first.hand_length).to eql(hand_length)
      expect(game.players.last.hand_length).to eql(hand_length)
    end
  end

  describe '#play_round' do
    let(:game) { WarGame.new }
    it 'should add the cards to player 2' do
      card1 = create_card('K', 'S', game.players.first)
      card2 = create_card('A', 'H', game.players.last)
      result = game.play_round
      expect(game.players.first.hand).to be_empty
      expect(game.players.last.hand).to include(card1, card2)
      expect(result).to include('Player 2 took ', 'A of H', ', and ', 'K of S')
    end
    it 'should add the cards to player 1' do
      card1 = create_card('2', 'S', game.players.last)
      card2 = create_card('A', 'H', game.players.first)
      result = game.play_round
      expect(game.players.last.hand).to be_empty
      expect(game.players.first.hand).to include(card1, card2)
      expect(result).to include('Player 1 took', 'A of H', ', and ', '2 of S')
    end
    it 'should add cards to player 1 even after a tie' do
      cards = [create_card('A', 'S', game.players.last), create_card('A', 'H', game.players.first),
               create_card('2', 'S', game.players.last), create_card('A', 'D', game.players.first)]
      result = game.play_round
      expect(game.players.last.hand).to be_empty
      expect(game.players.first.hand).to include(*cards)
      expect(result).to include('Player 1 took ', 'A of H', ', ', 'A of S', ', ', 'A of D', ', and ', '2 of S')
    end
  end

  describe '#retrieve_cards' do
    let(:game) { WarGame.new }
    it 'should return an array of two cards from each players deck' do
      card1 = create_card('2', 'S', game.players.last)
      card2 = create_card('A', 'H', game.players.first)
      cards = game.retrieve_cards
      expect(cards).to include(card1, card2)
    end
    it 'should return an array of specifically the top card from each players deck' do
      cards = [create_card('A', 'S', game.players.last), create_card('A', 'H', game.players.first),
               create_card('2', 'S', game.players.last), create_card('A', 'D', game.players.first)]
      played_cards = game.retrieve_cards
      expect(played_cards).to include(cards[0], cards[1])
    end
  end

  describe '#get_match_winner' do
    before do
      @game = WarGame.new
      @card1 = PlayingCard.new('A', 'H', @game.players.first)
      @card2 = PlayingCard.new('2', 'S', @game.players.first)
      @pile = [@card1, @card2]
      @winner = @game.get_match_winner(@pile)
    end

    it 'evaluates the cards and returns the player who won' do
      expect(@winner).to eql(@game.players.first)
    end
    it 'adds the cards to the correct players hand' do
      expect(@game.players.first.hand).to include(@card1, @card2)
    end
  end

  describe '#game_feedback' do
    it 'should return a proper string' do
      game = WarGame.new
      card1 = PlayingCard.new('K', 'S', game.players.first)
      card2 = PlayingCard.new('A', 'H', game.players.first)
      pile = [card1, card2]
      expect(game.match_feedback(game.players.first, pile)).to eql('Player 1 took K of S, and A of H')
    end
  end

  describe '#check_for_game_winner' do
    let(:game) { WarGame.new }
    fit 'should make the winner player1 when player 1 wins' do
      card1 = PlayingCard.new('A', 'S', game.players.first)
      card2 = PlayingCard.new('A', 'H', game.players.first)
      game.players.first.add_cards([card1, card2])
      game.check_for_game_winner
      expect(game.winner).to eql(game.players.first)
    end
  end

  def create_card(rank, suit, player)
    card = PlayingCard.new(rank, suit, player)
    player.add_cards([card])
    card
  end
end
