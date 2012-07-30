require 'command_line_console'
require 'command_line_prompter'
require 'command_line_renderer'

describe "CommandLineConsole" do
  before :all do
    @input = StringIO.new('', 'r+')
    @output = StringIO.new('', 'w')
    @prompter = CommandLinePrompter.new
    @prompter.set_input_output(@input, @output)
    @renderer = CommandLineRenderer.new
    @renderer.set_output(@output)
    @players = [:player1, :player2]
  end

  before :each do
    @console = CommandLineConsole.new(@prompter, @renderer)
    @console.set_players(@players)
    @console.out = @output
  end

  it "assigns ASCII characters to players and marks in 'Game'" do
    @console.characters[:player1].should == 'O'
    @console.characters[:player2].should == 'X'
    @console.characters[Board::BLANK].should == '_'
  end

  it "receives command-line input when prompted" do
    @input.reopen('2', 'r+')
    @console.prompt_player_mark.should eql 1
  end

  it "prompts the user to play again" do
    @output.should_receive(:print).exactly(3).times
    @input.should_receive(:gets).and_return('a', '1', 'y')
    @console.prompt_play_again.should == true
  end

  it "prompts the user to choose a mark" do
    @output.should_receive(:print).exactly(3).times
    @input.should_receive(:gets).and_return('a', 'x', 'X')
    @console.prompt_mark_symbol.should == 'X'
  end

  context "when prompting the user to specify an opponent" do
    before :each do
      @opponent_options = [:human,:computer]
    end

    it "accepts an input within a valid range" do
      @input.reopen('1', 'r')
      @console.prompt_opponent_type(@opponent_options).should == :human
    end

    it "continues prompting until receiving a valid input" do
      @output.should_receive(:print).exactly(3).times
      @input.should_receive(:gets).and_return('0', '3', '1')
      @console.prompt_opponent_type(@opponent_options).should == :human
    end
  end

  it "assigns 'X' and 'O' to player and opponent" do
    given_hash = {:player1 => nil, :player2 => nil}
    target_hash = {:player1 => 'X', :player2 => 'O'}
    @input.stub!(:gets).and_return('X')
    @console.prompt_for_marks(given_hash).should == target_hash
  end
end
