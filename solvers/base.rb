module Robosolver
  module Solvers
    module Base
      attr_reader :board, :start, :target

      def initialize(board = nil)
        @board = board
      end

      def find_path(startx, starty, targetx, targety)
        @start = board.at(startx, starty)
        @target = board.at(targetx, targety)
        solve
      end

      def solve
        raise <<-ERROR
        #{self.class} must implement a 'solve' method

        It can access the 'start', 'target', and 'board' attrs
        ERROR
      end
    end
  end
end
