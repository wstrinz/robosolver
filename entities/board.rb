module Robosolver
  class Board
    attr_reader :xmax, :ymax, :cells, :robits

    def initialize(xmax, ymax)
      @xmax = xmax
      @ymax = ymax
      @cells = []
      @robits = []
    end

    def create_blank_board
      (0...xmax).each do |cx|
        new_row = []
        (0...ymax).each do |cy|
          new_row << Cell.new(:"c#{cx}_#{cy}", cx, cy, self)
        end
        @cells << new_row
      end

      populate_blank_board_neighbors
    end

    def add_robit(robit)
      @robits << robit
    end

    def create_cells(cell_matrix)
      # take data structure representing cell props
      # populate @cells with cell instances
    end

    def at(x,y)
      cells.flatten.find{|c| c.x == x && c.y == y}
    end

    def at_robit(color)
      rob = robits.find{|r| r.color == color}
      if rob
        at(rob.x, rob.y)
      else
        raise "No robit for color #{color}"
      end
    end

    private

    def populate_blank_board_neighbors
      @cells.flatten.each do |cell|
        dirs = [[-1, 0], [0,-1], [1,0], [0,1]]
        coords = dirs.map{|dx, dy| [cell.x + dx, cell.y + dy]}
        coords.each do |x, y|
          if at(x,y)
            cell.neighbors << [x,y]
          end
        end
      end
    end
  end
end
