require 'rspec'
require_relative '../player'

describe Player do
  before :each do
    @player = Player.new
  end

  describe "#new" do
    it "returns a Player object" do
      expect(@player.instance_of? Player).to eq true
    end
    it "creates a Player object with no name" do
      expect(@player.name).to eq ''
    end
    it "creates a Player object with score of 0" do
      expect(@player.score).to eq 0
    end
  end

  describe "#name_player" do
    it "changes player name" do
      Player.any_instance.stub(gets: 'This name') #Fake user input
      expect(@player.name_player("Player1")).to eq "This name"
    end
  end

  describe "#increase_points" do
    it "increases the player's points by 3" do
      initScore = @player.score
      @player.increase_points
      expect(@player.score - initScore).to eq 3
    end
  end

  describe "#decrease_points" do
    it "decreases the player's points by given value" do
      initScore = @player.score
      @player.decrease_points(4)
      expect((@player.score - initScore).abs).to eq 4.abs

      initScore = @player.score
      @player.decrease_points(2)
      expect((@player.score - initScore).abs).to eq 2
    end
  end

  it 'should be a Class' do
    expect(described_class.is_a? Class).to eq true
  end
end