class CommandLineConsole
  attr_reader :characters
  attr_accessor :in, :out

  def initialize
    @characters = Hash.new
    @characters[Mark::BLANK] = "_"
    @in = $stdin
    @out = $stdout
  end

  def set_players(players)
    @players = players.clone
    @characters[players.first] = "O"
    @characters[players.last] = "X"
  end

  def display_board(board)
    print_board = convert_board_to_ascii(board)
    print_available = available_spaces_to_ascii(board)
    output = (0...board.size).collect {|index| "%10s%10s" % [print_board[index],print_available[index]]}
    @out.puts("",*output)
  end

  def prompt_player_mark
    @out.print("\n","Please choose the number of the space where you'd like to make your mark: ")
    @in.gets.chomp.to_i - 1
  end

  def prompt_opponent_type(opponents)
    value = 0
    while value < 1 or value > opponents.length
      @out.print("\n","Choose your opponent #{players_as_options(opponents)} : ")
      value = @in.gets.chomp.to_i
    end
    opponents[value - 1]
  end

  def alert_space_unavailable(index)
    @out.puts("","The space you've selected is unavailable")
  end

  def display_game_results(board)
    output = convert_board_to_ascii(board).collect {|row| "%10s" % row}
    message = board.winning_solution?(*@players) ?
      "Player #{board.winning_solution?(@players.first) ? 1 : 2} is the winner!" :
      "The game has ended with a draw!"
    @out.puts("",*output,"",message)
  end

  def convert_board_to_ascii(board)
    board.spaces.each_slice(board.size).collect {|row| row.collect {
      |mark| @characters[mark]}.join("|")}
  end

  def available_spaces_to_ascii(board)
    board.spaces.collect.with_index {|space, index| space == Mark::BLANK ? index + 1 : " "}
      .each_slice(board.size).to_a.collect {|row| row.join(" ")}
  end

  def players_as_options(players)
    "[%s]" % players.collect.with_index {|player,index|
      "%d: %s" % [index+1, player]}.join(", ")
  end
end
