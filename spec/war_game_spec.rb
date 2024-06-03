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
            game.player1.add_cards(card1)
            game.player2.add_cards(card2)
            game.play_round
            expect(game.player1.hand).to be_empty
            expect(game.player2.hand).to include(card1, card2)
        end
        it 'should add the cards to player 1' do
            card1 = PlayingCard.new("2", "S")
            card2 = PlayingCard.new("A", "H")
            game.player1.add_cards(card2)
            game.player2.add_cards(card1)
            game.play_round
            expect(game.player2.hand).to be_empty
            expect(game.player1.hand).to include(card1, card2)
        end
    end
end
