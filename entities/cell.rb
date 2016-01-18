module Robosolver
  class Cell
    include Entity
    WALL_OFFSETS = {
      left: [-1, 0],
      right: [1, 0],
      top: [0, 1],
      bottom: [0, -1],
    }

    attr_reader :walls
    attr_accessor :neighbors

    def initialize(name, x, y, board)
      @x = x
      @y = y
      @board = board
      @name = name
      @neighbors = []
      @walls = Set.new
    end

    def add_wall(dir)
      @walls = walls.add dir
    end

    def remove_wall(dir)
      @walls = walls.delete dir
    end

    def walkable_neighbours
      neighbors.map do |nx, ny|
        puts "searching board at #{nx}, #{ny}"
        @board.at(nx, ny)
      end.compact
    end
  end
end
