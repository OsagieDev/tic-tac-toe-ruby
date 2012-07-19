require 'minimax'
require 'board'

describe Minimax do
  before :all do
    @solver = Minimax.new
  end
  
  before :each do
    @board = Board.new
    @min_player = mock("Player")
    @max_player = mock("Player")
    @solver.min_player = @min_player
    @solver.max_player = @max_player
  end

  it "scores high on winning mark" do
    @board.should_receive(:winning_solution?).with(@max_player)
      .and_return(true)
    @board.should_receive(:winning_solution?).with(@min_player)
      .and_return(false)
    @solver.score(@board,@max_player).should == 1
  end

  it "scores zero on non-winning mark" do
    set_no_winning_solution
    @board.stub!(:spaces_with_mark).and_return([])
    @solver.score(@board,@max_player).should == 0
  end

  it "scores low on opponent's winning mark" do
    @board.should_receive(:winning_solution?).with(@max_player)
      .and_return(false)
    @board.should_receive(:winning_solution?).with(@min_player)
      .and_return(true)
    @solver.score(@board,@min_player).should == -1
  end

  it "makes mark if no solution but spaces available" do
    set_no_winning_solution
    @board.stub!(:spaces_with_mark).and_return([1,2,3],[])
    @board.should_receive(:make_mark).any_number_of_times
    @solver.score(@board,@min_player)
  end

  it "calls 'score' recursively until no spaces available" do
    set_no_winning_solution
    @board.should_receive(:spaces_with_mark)
      .and_return([1,2],[2],[],[1],[])
    @solver.score(@board,@min_player)
  end

  it "calls 'score' recursively until a winning solution exists" do
    set_recursion_limit_before_solution(2)
    @board.stub!(:spaces_with_mark).and_return([1,2,3],[2,3],[3],[])
    @solver.score(@board,@min_player)
  end

  it "returns the score from lower recursion levels" do
    @board.stub!(:winning_solution?).with(@max_player)
      .and_return(false,false)
    @board.stub!(:winning_solution?).with(@min_player)
      .and_return(false,true)
    @board.stub!(:spaces_with_mark).and_return([1,2,3])
    @solver.score(@board,@min_player).should == -1
  end

  it "rotates players between levels of recursion" do
    set_recursion_limit_before_solution(3)
    player_order = []
    @board.stub!(:spaces_with_mark).and_return([1],[2],[3],[])
    @board.stub!(:make_mark) {|space,player|
      player_order << player if player != Mark::BLANK
    }
    @solver.score(@board,@min_player)
    player_order.should == [@max_player,@min_player,@max_player]
  end

  it "completes with board in original state" do
    original_spaces = @board.spaces_with_mark(Mark::BLANK)
    set_recursion_limit_before_solution(1)
    @solver.score(@board,@min_player)
    current_spaces = @board.spaces_with_mark(Mark::BLANK)
    current_spaces.should == original_spaces
  end

  it "tries all available spaces at each level of recursion" do
    space_order = []
    set_no_winning_solution
    @board.stub!(:spaces_with_mark).and_return([1,2,3],[],[],[])
    @board.stub!(:make_mark) {|space,player|
      space_order << space if player != Mark::BLANK
    }
    @solver.score(@board,@min_player)
    space_order.should == [1,2,3]
  end

  private
  def set_no_winning_solution
    @board.stub!(:winning_solution?).and_return(false)
  end

  def set_recursion_limit_before_solution(limit)
    @board.stub!(:winning_solution?)
      .and_return(*([false]*(limit*2+1) + [true]))
  end
end
