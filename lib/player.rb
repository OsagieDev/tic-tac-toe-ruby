class Player
  attr_accessor :console

  def make_mark(board)
    index = @console.prompt_player_mark
    while not board.space_available?(index)
      index = @console.prompt_player_mark
    end
    board.make_mark(index,self)
  end
end
