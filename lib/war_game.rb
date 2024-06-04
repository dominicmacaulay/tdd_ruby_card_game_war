require_relative 'war_player'
require_relative 'card_deck'
class WarGame
    attr_reader :player1, :player2, :deck, :deck_length
    attr_accessor :winner
    def initialize(player1 = Player.new("Player 1"), player2 = Player.new("Player 2"))
        @player1 = player1
        @player2 = player2
        @deck = CardDeck.new
        @deck_length = deck.cards_left
        @winner = nil
    end

    def start
        deck.shuffle
        until deck.no_cards?
            player1.add_cards([deck.deal])
            player2.add_cards([deck.deal])
        end
    end

    def play_round(pile = [])
        pile.push(*retrieve_cards)
        if deck.tie?(pile[-2],pile[-1])
            return play_round(pile) 
        end
        match_winner = get_match_winner(pile)
        match_feedback(match_winner, pile)
    end

    def get_match_winner(pile)
        deck.player1_wins?(pile[-2],pile[-1]) ? match_winner = player1 : match_winner = player2
        match_winner.add_cards(pile)
        check_for_winner(match_winner)
        match_winner
    end

    def retrieve_cards
        card1 = player1.remove_top_card
        card2 = player2.remove_top_card
        [card1,card2]
    end

    def match_feedback(player, cards)
        message = "#{player.name} took "
        cards.each do |card|
            message.concat("and ") if card == cards.last
            message.concat("#{card.rank} of #{card.suit}")
            message.concat(", ") if card != cards.last
        end
        return message
    end

    def check_for_winner(match_winner, deck_length = self.deck_length)
        if match_winner.hand_length == deck_length
            self.winner = match_winner
        end
    end
end