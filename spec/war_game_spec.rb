require_relative '../lib/war_game'
require_relative '../lib/card_deck'

describe 'WarGame' do
    describe "#initialize" do
        let(:game) { WarGame.new }
        it 'should create two players' do 
            expect(game.player1).to respond_to :name
            expect(game.player2).to respond_to :name
        end
        it 'should create a deck' do
            expect(game.deck).to respond_to :cards
        end
        it 'should create a nil winner variable' do
            expect(game.winner).to be nil
        end
    end

    describe "#start" do
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
            expect(game.player1.hand_length).to eql(hand_length)
            expect(game.player2.hand_length).to eql(hand_length)
        end
    end

    describe "#play_round" do
        let(:game) { WarGame.new }
        it 'should add the cards to player 2' do
            card1 = PlayingCard.new("K", "S")
            card2 = PlayingCard.new("A", "H")
            game.player1.add_cards([card1])
            game.player2.add_cards([card2])
            result = game.play_round
            expect(game.player1.hand).to be_empty
            expect(game.player2.hand).to include(card1, card2)
            expect(result).to include("Player 2 took ","A of H",", and ","K of S")
        end
        it 'should add the cards to player 1' do
            card1 = PlayingCard.new("2", "S")
            card2 = PlayingCard.new("A", "H")
            game.player1.add_cards([card2])
            game.player2.add_cards([card1])
            result = game.play_round
            expect(game.player2.hand).to be_empty
            expect(game.player1.hand).to include(card1, card2)
            expect(result).to include("Player 1 took","A of H",", and ","2 of S")
        end
        it 'should add cards to player 1 even after a tie' do
            card1 = PlayingCard.new("A", "S")
            card2 = PlayingCard.new("A", "H")
            card3 = PlayingCard.new("2", "S")
            card4 = PlayingCard.new("A", "D")
            game.player1.add_cards([card2])
            game.player1.add_cards([card4])
            game.player2.add_cards([card1])
            game.player2.add_cards([card3])
            result = game.play_round
            expect(game.player2.hand).to be_empty
            expect(game.player1.hand).to include(card1, card2, card3, card4)
            expect(result).to include("Player 1 took ","A of H",", ","A of S",", ","A of D",", and ","2 of S")
        end
    end

    describe "#retrieve_cards" do
    let(:game) { WarGame.new }
        it 'should return an array of two cards from each players deck' do
            card1 = PlayingCard.new("2", "S")
            card2 = PlayingCard.new("A", "H")
            game.player1.add_cards([card2])
            game.player2.add_cards([card1])
            cards = game.retrieve_cards
            expect(cards).to include(card1, card2)
        end
        it 'should return an array of specifically the top card from each players deck' do
            card1 = PlayingCard.new("2", "S")
            card2 = PlayingCard.new("A", "H")
            card1 = PlayingCard.new("4", "S")
            card2 = PlayingCard.new("7", "H")
            game.player1.add_cards([card2])
            game.player2.add_cards([card1])
            cards = game.retrieve_cards
            expect(cards).to include(card1, card2)
        end
    end

    describe "#get_match_winner" do
        let(:game) { WarGame.new }
        it 'evaluates the cards and returns the player who won' do
            card1 = PlayingCard.new("A", "H")
            card2 = PlayingCard.new("2", "S")
            pile = [card1, card2]
            winner = game.get_match_winner(pile)
            expect(winner).to eql(game.player1)
        end
        it 'adds the cards to the correct players hand' do
            card1 = PlayingCard.new("A", "H")
            card2 = PlayingCard.new("2", "S")
            pile = [card1, card2]
            game.get_match_winner(pile)
            expect(game.player1.hand).to include(card1, card2)
        end
    end

    describe "#game_feedback" do
        it 'should return a proper string' do
            game = WarGame.new
            card1 = PlayingCard.new("K", "S")
            card2 = PlayingCard.new("A", "H")
            pile = [card1,card2]
            expect(game.match_feedback(game.player1, pile)).to eql("Player 1 took K of S, and A of H")
        end
    end

    describe "#check_for_game_winner" do
        let(:game) { WarGame.new }
        it 'should make the winner player1 when player 1 wins' do
            card1 = PlayingCard.new("A", "S")
            card2 = PlayingCard.new("A", "H")
            game.player1.add_cards([card1,card2])
            game.check_for_game_winner
            expect(game.winner).to eql(game.player1)
        end
    end
end
