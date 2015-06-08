part of life;

class Cell {
  String state;
  int age;

  Cell(this.state) {
    age = 0;
  }
}

class Grid {
	int _rows, _cols, _generation;
	String _defaultState;
	List<List<Cell>> _cells;
	List<List<Cell>> _nextCellBuffer;

	int get rows => _rows;
	int get cols => _cols;
  int get generation => _generation;

	Grid(this._rows, this._cols, this._defaultState) {
    _generation = 0;
		_cells = new List<List<Cell>>.generate(_rows, (int) => new List<Cell>.generate(_cols, (int) => new Cell(_defaultState)));
		_nextCellBuffer = new List<List<Cell>>.generate(_rows, (int) => new List<Cell>.generate(_cols, (int) => new Cell(_defaultState)));
	}

	String getState(int row, int col) {
		if (row < 0 || row >= _rows || col < 0 || col >= _cols)
			return _defaultState;

		return _cells[row][col].state;
	}

	void setState(int row, int col, String state) {
		if (row < 0 || row >= _rows || col < 0 || col >= _cols)
			throw new Error();

		_cells[row][col].state = state;
	}

	void advance(Map<String, List<Transition>> stateTransitionMap) {
		// Determine the next states
		Map<String, int> neighborStateDistribution = new Map<String, int>();
		for (int row = 0; row < _rows; row++) {
			for (int col = 0; col < _cols; col++) {
        // Check if age should be reset. This cell's state could have
        // been adjusted between generation advances.
        if (_nextCellBuffer[row][col].state != _cells[row][col].state)
          _cells[row][col].age = 0;

        // Set the next state to the current state.  This will matter if
        // no transitions are taken.
				_nextCellBuffer[row][col].state = _cells[row][col].state;

        List<Transition> transitions = stateTransitionMap[_cells[row][col]];
				if (transitions.isNotEmpty) {
					// Determine neighbor state distribution
					neighborStateDistribution.clear();
					for (int nRow = row - 1; nRow <= row + 1; nRow++) {
						for (int nCol = col - 1; nCol <= col + 1; nCol++) {
							if (nRow == row && nCol == col)
								continue;

							String nState = getState(nRow, nCol);
							if (neighborStateDistribution.containsKey(nState))
								neighborStateDistribution[nState]++;
							else
								neighborStateDistribution[nState] = 1;
						}
					}

					// Determine which transition to take, if any.
					for (Transition transition in transitions) {
						if (transition.condition.evaluate(neighborStateDistribution, _cells[row][col].age, _generation)) {
							_nextCellBuffer[row][col].state = transition.next.state();
							break;
						}
					}
				}

        // Check if the age advanced during generation advance
        if (_nextCellBuffer[row][col].state == _cells[row][col].state)
          _nextCellBuffer[row][col].age = _cells[row][col].age + 1;
        else
          _nextCellBuffer[row][col].age = 0;
			}
		}

		// Advance the states
		List<List<Cell>> oldCells = _cells;
		_cells = _nextCellBuffer;
		_nextCellBuffer = oldCells;

    // Advance the generation
    _generation++;
	}

	void clear() {
		for (List<Cell> list in _cells) {
      for (Cell cell in list) {
        cell.state = _defaultState;
        cell.age = 0;
      }
    }
    _generation = 0;
	}
}