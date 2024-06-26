# frozen_string_literal: true

# Generic player object
class Player
  attr_reader :name
  attr_accessor :hand, :client

  def initialize(name, hand = [])
    @name = name
    @hand = hand
  end

  def hand_length
    hand.count
  end

  def add_cards(cards)
    cards.shuffle!
    hand.push(*cards)
  end

  def remove_top_card
    hand.shift
  end
end
