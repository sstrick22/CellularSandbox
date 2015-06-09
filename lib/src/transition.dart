part of life;

class Transition {
	Condition _condition;
	NextStateGenerator _next;

	Condition get condition => _condition;
	NextStateGenerator get next => _next;

	Transition(this._condition, this._next);

	bool operator ==(Object obj) => (obj is Transition) && (obj._condition.condition == _condition.condition) && (obj._next == _next);
  int get hashCode => hash2(_condition, _next);
}

abstract class NextStateGenerator {
	String state();
}

class ConstantNextStateGenerator implements NextStateGenerator {
	String _state;

	ConstantNextStateGenerator(this._state);

	String state() {
		return _state;
	}

	bool operator ==(Object obj) => (obj is ConstantNextStateGenerator) && (obj._state == _state);
  int get hashCode => _state.hashCode;
}

class RandomNextStateGenerator implements NextStateGenerator {
	static final Random indexGen = new Random();

	SplayTreeMap<String, int> _stateWeightMap;
	int _totalWeight;

	RandomNextStateGenerator(this._stateWeightMap, this._totalWeight);

	String state() {
		int index = indexGen.nextInt(_totalWeight);

		for (String state in _stateWeightMap.keys) {
			index -= _stateWeightMap[state];

			if (index < 0)
				return state;
		}

		// Should never get past the loop
		throw new Error();
	}

	bool operator ==(Object obj) {
		RandomNextStateGenerator other = obj as RandomNextStateGenerator;
		if (other == null)
			return false;

		if (other._totalWeight != _totalWeight)
			return false;

		if (other._stateWeightMap.length != _stateWeightMap.length)
			return false;

		for (String state in _stateWeightMap.keys) {
			if (other._stateWeightMap[state] != _stateWeightMap[state])
				return false;
		}

		return true;
	}

  int get hashCode => hash2(_stateWeightMap, _totalWeight);
}