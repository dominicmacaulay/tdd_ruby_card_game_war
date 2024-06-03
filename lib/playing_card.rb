class PlayingCard
    attr_reader :rank, :suit
    def initialize(rank, suit)
        @rank = rank
        @suit = suit
    end

    def ==(other_card)
        other_card.rank == @rank && other_card.suit == @suit
    end
end 
