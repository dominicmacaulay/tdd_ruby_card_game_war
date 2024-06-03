require_relative 'playing_card'
class CardDeck
  attr_accessor :cards

  RANKS = %w( 2 3 4 5 6 7 8 9 10 J Q K A )
  SUITS = %w( S C H D)

  def initialize(cards = make_deck)
    @cards = cards
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

  def shuffle
    cards.shuffle!
  end

  def no_cards?
    cards_left == 0
  end

  def get_index(rank)
    RANKS.index(rank)
  end

  def tie?(card1, card2)
    card1.rank == card2.rank
  end

  def player1_wins?(card1, card2)
    get_index(card1.rank) > get_index(card2.rank)
  end
end
