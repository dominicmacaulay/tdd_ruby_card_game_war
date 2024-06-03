require_relative '../lib/war_player'

describe 'WarPlayer' do
    it 'should create a passed in name' do
        player = Player.new("Player 1")
        expect(player.name).to eql("Player 1")
    end
    it 'should create an empty hand array' do
        player = Player.new("Player 1")
        expect(player.hand).to eql([])
    end
    describe "#hand_length" do
        it 'should return the amount of cards present' do
            player = Player.new("Player 1")
            expect(player.hand_length).to eql player.hand.count
        end
    end
    describe "#add_cards" do
        it 'adds a card to the hand' do
            player = Player.new('x')
            player.add_cards(1)
            expect(player.hand.include?(1)).to be true
        end
        it 'adds multiple cards to the hand' do
            player = Player.new('x')
            player.add_cards([1,2,3])
            expect(player.hand.include?(1)).to be true
            expect(player.hand.include?(2)).to be true
            expect(player.hand.include?(3)).to be true
        end
    end

    describe "#remove_top_card" do
        it 'removes and returns the top card from the hand' do
            player = Player.new('x', [1])
            expect(player.remove_top_card).to eql(1)
            expect(player.hand.include?(1)).to be false
        end
    end
end
