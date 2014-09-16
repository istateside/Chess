# encoding: utf-8

def vector_sum(vectors)
  result = [0,0]
  vectors.each do |vec|
    result[0] += vec[0]
    result[1] += vec[1]
  end
  result
end

class Piece
  # row, col
  DELTAS = { nw: [1, -1],  n: [1, 0],  ne: [1, 1],
                  w: [0, -1],               e: [0, 1],
                 sw: [-1, -1], s: [-1, 0], se: [-1, 1] }

  def initialize(pos, board, color)
    @pos = pos
    @board = board
    @color = color
  end

  def move_within_boundaries?(pos)
    row, col = pos
    row.between?(0..@board.height) && col.between?(0..@board.width)
  end

end

class SlidingPiece < Piece
  def moves
    moves = []
    move_dirs.each do |dir|
      current_pos = pos
      loop do
        next_move = vector_sum([current_pos, dir])
        break unless move_within_boundaries?(next_move)
        break if @board[next_move].color == self.color
        moves << next_move
        break unless @board[next_move].nil? #change .empty? to whatever call

        current_pos = next_move
      end
    end

    moves
  end
end

class SteppingPiece < Piece
  def moves
    moves = []
    move_dirs.each do |dir|
      next_move = vector_sum([pos, dir])
      next unless move_within_boundaries?(next_move)
      next if @board[next_move].color == self.color
      moves << next_move if @board[next_move].nil? #change empty
    end

    moves
  end
end

class Pawn < Piece
  def initialize(pos, board, color)
    super
    @moved = false
  end

  def move_dirs
    case @color
    when :w
      [DELTAS[:n], DELTAS[:ne], DELTAS[:nw]]
    when :b
      [DELTAS[:s], DELTAS[:se], DELTAS[:sw]]
    end
  end

  def moves
    moves = []
    dirs = move_dirs
    next_move = vector_sum([@pos, dirs.first])
    moves << next_move if @board[next_move].empty?
    moves << vector_sum([next_move, dirs.first]) unless @moved
    next_move = vector_sum([@pos, dirs[1]])
    unless @board[next_move].empty? || @board[next_move].color == self.color
      moves << next_move
    end
    next_move = vector_sum([@pos, dirs.last])
    unless @board[next_move].empty? || @board[next_move].color == self.color
      moves << next_move
    end

    moves.select { |move| move_within_boundaries?(move) }
  end

  def to_s
    @color == :b ? "\u{265f}" : "\u{2659}"
  end
end

class Bishop < SlidingPiece
  def move_dirs
    [DELTAS[:nw], DELTAS[:ne], DELTAS[:sw], DELTAS[:se]]
  end

  def to_s
    @color == :b ? "\u{265d}" : "\u{2657}"
  end
end

class Rook < SlidingPiece
  def move_dirs
    [DELTAS[:n], DELTAS[:e], DELTAS[:s], DELTAS[:w]]
  end

  def to_s
    @color == :b ? "\u{265c}" : "\u{2656}"
  end
end

class Queen < SlidingPiece
  def move_dirs
    DELTAS.values
  end

  def to_s
    @color == :b ? "\u{265b}" : "\u{2655}"
  end
end

class Knight < SteppingPiece
  def move_dirs
    [
      [DELTAS[:n]] * 3 + [DELTAS[:e]],
      [DELTAS[:n]] * 3 + [DELTAS[:w]],
      [DELTAS[:s]] * 3 + [DELTAS[:e]],
      [DELTAS[:s]] * 3 + [DELTAS[:w]],
      [DELTAS[:e]] * 3 + [DELTAS[:n]],
      [DELTAS[:w]] * 3 + [DELTAS[:n]],
      [DELTAS[:e]] * 3 + [DELTAS[:s]],
      [DELTAS[:w]] * 3 + [DELTAS[:s]],
    ].map { |vec| vector_sum(vec) }
  end

  def to_s
    @color == :b ? "\u{265e}" : "\u{2658}"
  end
end

class King < SteppingPiece
  def move_dirs
    DELTAS.values
  end

  def to_s
    @color == :b ? "\u{265a}" : "\u{2654}"
  end
end

class Board
  def initialize
    @board = Array.new(8) { Array.new(8) }
    place_pieces
  end

  def height
    @board.count
  end

  def width
    @board[0].count
  end

  def [](pos)
    row, col = pos
    @board[row][col]
  end

  def []=(pos, value)
    row, col = pos
    @board[row][col] = value
  end

  def place_pieces
    place_piece_row(0, :b)
    place_pawn_row(1, :b)
    place_pawn_row(6, :w)
    place_piece_row(7, :w)
  end

  def place_pawn_row(row, color)
    @board[row].each_with_index do |spot, i|
       @board[row][i] = Pawn.new([row, i], self, color)
     end
     nil
  end

  def place_piece_row(row, color)
    starting_row = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    @board[row].each_with_index do |spot, i|
      @board[row][i] = starting_row[i].new([row, i], @board, color)
    end
    nil
  end

  def display
    @board.each do |row|
      row.each do |piece|
        print piece.to_s
      end
      puts
    end

    nil
  end
end