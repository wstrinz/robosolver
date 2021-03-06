module Robosolver
  class Robit
    include Entity

    attr_reader :color

    def initialize(x, y, color, board)
      @x = x
      @y = y
      @color = color
      @board = board
    end

    def find_path(solver_class, targetx, targety)
      solver_class.new(board).find_path(x, y, targetx, targety)
    end
  end
end
