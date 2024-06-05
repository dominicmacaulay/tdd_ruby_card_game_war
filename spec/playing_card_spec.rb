# frozen_string_literal: true

require_relative '../lib/playing_card'

# test the playing card class
describe PlayingCard do
  it 'should have a rank and suite' do
    card = PlayingCard.new(2, 'H')
    expect(card).to respond_to :rank
    expect(card).to respond_to :suit
  end
  describe '#==' do
    it 'should return true only if rank and suit are equal' do
      card1 = PlayingCard.new(2, 'S')
      card2 = PlayingCard.new(2, 'S')
      card3 = PlayingCard.new(3, 'S')
      card4 = PlayingCard.new(2, 'H')
      expect(card1).to eq card2
      expect(card1).not_to eq card3
      expect(card1).not_to eq card4
    end
  end
end
