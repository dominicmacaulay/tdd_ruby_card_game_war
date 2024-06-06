# frozen_string_literal: true

require_relative 'playing_card'

# This is the deck class
class CardDeck
  attr_accessor :cards

  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A].freeze
  SUITS = %w[S C H D].freeze

  def initialize(cards = make_deck)
    @cards = cards == 'test' ? make_test_deck : cards
  end

  def make_test_deck
    cards = []
    until x > 8
      cards.push(PlayingCard.new((x + 1).to_s, 'H'))
      cards.push(PlayingCard.new((x + 1).to_s, 'S'))
      x += 1
    end
    cards
  end

  def make_deck
    SUITS.flat_map do |suit|
      RANKS.map do |rank|
        PlayingCard.new(rank, suit)
      end
    end
  end

  def cards_left
    cards.count
  end

  def deal
    cards.shift
  end

  def shuffle(seed = Random.new)
    cards.shuffle!(random: seed)
  end

  def no_cards?
    cards_left.zero?
  end

  def get_index(rank)
    RANKS.index(rank)
  end

  def tie?(cards)
    cards.each do |card|
      cards.each do |other_card|
        return true if other_card.rank == card.rank && other_card != card
      end
    end
    false
  end

  def winning_card(cards)
    highest_card = nil
    cards.each do |card|
      highest_card = card if highest_card.nil? || get_index(card.rank) > get_index(highest_card&.rank)
    end
    highest_card
  end
end
