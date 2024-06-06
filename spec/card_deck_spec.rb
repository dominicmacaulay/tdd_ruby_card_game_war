# frozen_string_literal: true

require 'spec_helper'
require_relative '../lib/card_deck'
require_relative '../lib/playing_card'

# tests the CardDeck class
RSpec.describe CardDeck do # rubocop:disable Metrics/BlockLength
  it 'Should have 52 cards when created' do
    deck = CardDeck.new
    expect(deck.cards_left).to eq 52
  end

  describe '#deal' do
    it 'should return a card and decrease the deck' do
      deck = CardDeck.new
      card1 = deck.deal
      expect(card1).to respond_to :rank
      expect(deck.cards_left).to eq 51
    end

    it 'should deal unique cards' do
      deck = CardDeck.new
      card1 = deck.deal
      card2 = deck.deal
      expect(card1).not_to eq(card2)
    end

    it 'should deal the top card' do
      deck = CardDeck.new
      top_card = deck.cards[0]
      card1 = deck.deal
      expect(top_card).to eql(card1)
      top_card = deck.cards[0]
      card2 = deck.deal
      expect(top_card).to eql(card2)
    end
  end

  describe '#shuffle' do
    it 'should shuffle the deck' do
      deck1 = CardDeck.new([1, 2, 3])
      deck2 = CardDeck.new([1, 2, 3])
      deck1.shuffle(Random.new(1000))
      expect(deck1.cards).not_to eql(deck2.cards)
    end
  end

  describe '#no_cards?' do
    it 'returns false if there are still cards' do
      deck = CardDeck.new
      expect(deck.no_cards?).to be false
    end
    it 'returns true if there are no cards left' do
      deck = CardDeck.new([1])
      deck.deal
      expect(deck.no_cards?).to be true
    end
  end

  describe '#get_index' do
    it 'returns the index number of an Ace in the rank array' do
      deck = CardDeck.new
      rank = 'A'
      expect(deck.get_index(rank)).to eql(12)
    end
    it 'returns the index number of an 10 in the rank array' do
      deck = CardDeck.new
      rank = '10'
      expect(deck.get_index(rank)).to eql(8)
    end
  end

  describe '#tie?' do
    let(:deck) { CardDeck.new }
    it 'returns true when both cards are the same rank' do
      card1 = PlayingCard.new('A', 'H')
      card2 = PlayingCard.new('A', 'S')
      expect(deck.tie?([card1, card2])).to be true
    end
    it 'returns false when the cards are not the same rank' do
      card1 = PlayingCard.new('K', 'H')
      card2 = PlayingCard.new('A', 'H')
      expect(deck.tie?([card1, card2])).to be false
    end
  end

  describe '#winning_card' do
    let(:deck) { CardDeck.new }
    it 'returns the card with the highest value' do
      card1 = PlayingCard.new('A', 'H')
      card2 = PlayingCard.new('4', 'H')
      expect(deck.winning_card([card1, card2])).to eql(card1)
    end
  end
end
