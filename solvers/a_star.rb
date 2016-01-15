require 'astar'

module Robosolver
  module Solvers
    class AStar
      include Base

      def solve(targetx, targety, robit_color)
        # ::Astar::FindPath.from(board.at_robit(robit_color)).to(board.at(targetx, targety))
      end
    end
  end
end
