module Robosolver
  module Solvers
    class BFS
      include Base

      def solve
        bfs(start, target).flatten.map(&:name)
      end

      private

      def bfs(start, target, searched = [])
        searched << [start.x, start.y]
        (start.neighbors - searched).each do |x,y|
          n = board.at(x,y)
          if n.x == target.x && n.y == target.y
            return n
          else
            searched << [x,y]
            result = bfs(n, target, searched)
            if result
              return [n, result]
            end

            return nil
          end
        end
      end
    end
  end
end
