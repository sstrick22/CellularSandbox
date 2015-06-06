part of life;

class Grid {
	int _rows, _cols;
	String _defaultState;
	List<List<String>> _states;
	List<List<String>> _nextStateBuffer;

	int get rows => _rows;
	int get cols => _cols;

	Grid(this._rows, this._cols, this._defaultState) {
		_states = new List<List<String>>.generate(_rows, (int) => new List<String>.filled(_cols, _defaultState));
		_nextStateBuffer = new List<List<String>>.generate(_rows, (int) => new List<String>.filled(_cols, _defaultState));
	}

	bool hasChanged(int row, int col) {
		if (row < 0 || row >= _rows || col < 0 || col >= _cols)
			return false;

		return _states[row][col] != _nextStateBuffer[row][col];
	}

	String getState(int row, int col) {
		if (row < 0 || row >= _rows || col < 0 || col >= _cols)
			return _defaultState;

		return _states[row][col];
	}

	void setState(int row, int col, String state) {
		if (row < 0 || row >= _rows || col < 0 || col >= _cols)
			throw new Error();

		_states[row][col] = state;
	}

	void advance(Map<String, List<Transition>> stateTransitionMap) {
		// Determine the next states
		Map<String, int> neighborStateDistribution = new Map<String, int>();
		for (int row = 0; row < _rows; row++) {
			for (int col = 0; col < _cols; col++) {
				List<Transition> transitions = stateTransitionMap[_states[row][col]];
				_nextStateBuffer[row][col] = _states[row][col];

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

					// Determine next state
					for (Transition transition in transitions) {
						if (transition.condition.evaluate(neighborStateDistribution)) {
							_nextStateBuffer[row][col] = transition.next.state();
							break;
						}
					}
				}
			}
		}

		// Advance the states
		List<List<String>> oldStates = _states;
		_states = _nextStateBuffer;
		_nextStateBuffer = oldStates;
	}

	void clear() {
		_states.forEach((List<String> list) => list.fillRange(0, list.length, _defaultState));
	}

	Set<String> getInvalidStates(Set<String> validStates) {
		Set<String> invalidStates = new Set<String>();
		for (int row = 0; row < _rows; row++) {
			for (int col = 0; col < _cols; col++) {
				if (!validStates.contains(_states[row][col]))
					invalidStates.add(_states[row][col]);

				if (!validStates.contains(_nextStateBuffer[row][col]))
					invalidStates.add(_nextStateBuffer[row][col]);
			}
		}
		return invalidStates;
	}

	void replaceStates(Map<String,String> stateMap) {
		for (int row = 0; row < _rows; row++) {
			for (int col = 0; col < _cols; col++) {
				if (stateMap.containsKey(_states[row][col]))
					_states[row][col] = stateMap[_states[row][col]];

				if (stateMap.containsKey(_nextStateBuffer[row][col]))
					_nextStateBuffer[row][col] = stateMap[_nextStateBuffer[row][col]];
			}
		}
	}
}