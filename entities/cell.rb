module Robosolver
  class Cell
    attr_reader :x, :y, :name
    attr_accessor :neighbors

    def initialize(name, x, y, board)
      @x = x
      @y = y
      @board = board
      @name = name
      @neighbors = []
    end

    def walkable_neighbours
      neighbors.map do |nx, ny|
        puts "searching board at #{nx}, #{ny}"
        @board.at(nx, ny)
      end.compact
    end
  end
end
