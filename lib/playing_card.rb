# frozen_string_literal: true

# playing card object
class PlayingCard
  attr_reader :rank, :suit
  attr_accessor :player

  def initialize(rank, suit, player = nil)
    @rank = rank
    @suit = suit
    @player = player
  end

  def change_player(player)
    self.player = player
  end

  def ==(other)
    other.rank == rank && other.suit == suit
  end
end
