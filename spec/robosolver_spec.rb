require_relative 'spec_helper'

describe Robosolver do
  let(:boardx) { 5 }
  let(:boardy) { 5 }
  let(:board) { Board.new(boardx, boardy) }
  let(:robit) { Robit.new(1, 1, :red, board) }
  before do
    board.add_robit(robit)
  end

  describe Board do

    context "properties" do
      it { expect(board.xmax).to eq boardx }
      it { expect(board.ymax).to eq boardy }
      it { expect(board.cells).to eq [] }
    end

    context "setup" do
      describe "#create_blank_board" do
        it do
          board.create_blank_board
          expect(board.cells.length).to eq boardx
          expect(board.cells.map(&:length)).to all(eq(boardy))
        end
      end
    end
  end

  describe Cell do
    let(:cell) { Cell.new(:c1_2, 1,2,board) }

    context "properties" do
      it { expect(cell.x).to eq 1 }
      it { expect(cell.y).to eq 2 }
      it { expect(cell.neighbors).to eq [] }
    end
  end

  describe Robit do
    let(:robit) { Robit.new(0, 1, :blue, board) }

    context "properties" do
      it { expect(robit.x).to eq 0 }
      it { expect(robit.y).to eq 1 }
      it { expect(robit.color).to eq :blue }
    end
  end

  describe Solvers do
    let(:targetx) { 3 }
    let(:targety) { 4 }
    let(:robit_color) { :red }

    before do
      board.create_blank_board
    end

    describe Solvers::AStar do
      let(:solver) { Solvers::AStar.new(board) }

      it "solves the board" do
        skip "is broken"
        solution = solver.solve_board(targetx, targety, robit_color)
        expect(solution).not_to be_nil
      end
    end

    describe Solvers::BFS do
      let(:solver) { Solvers::BFS.new(board) }
      let(:dumb_bfs_solution) { [ [0, 1], [0, 0], [1, 0], [2, 0], [3, 0],
                                  [4, 0], [4, 1], [3, 1], [2, 1], [2, 2],
                                  [1, 2], [0, 2], [0, 3], [1, 3], [2, 3],
                                  [3, 3], [3, 2], [4, 2], [4, 3], [4, 4],
                                  [3, 4] ] }

      it "solves the board" do
        solution = solver.find_path(robit.x, robit.y, targetx, targety)
        expect(solution).to eq(dumb_bfs_solution.map{|x,y| board.at(x,y).name})
      end
    end

    describe Solvers::Djikstra do
      let(:solver) { Solvers::Djikstra.new(board) }
      let(:djikstra_solution) { [:c1_1, :c1_2, :c1_3, :c1_4, :c2_4, :c3_4] }

      it "solves the board" do
        solution = solver.find_path(robit.x, robit.y, targetx, targety)
        expect(solution).to eq(djikstra_solution)
      end
    end

  end
end
