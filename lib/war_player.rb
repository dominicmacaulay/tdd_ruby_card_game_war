 
class Player
    attr_reader :name
    attr_accessor :hand, :client
    def initialize(name, hand = [], client = nil)
        @name = name
        @hand = hand
        @client = client
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