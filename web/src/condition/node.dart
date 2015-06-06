part of life;

abstract class ConditionNode {
	int evaluate(Map<String, int> neighborStateDistribution);

	bool operator ==(Object obj);
}

class OperatorConditionNode implements ConditionNode {
	ConditionNode _lhs, _rhs;
	String _operator;

	OperatorConditionNode(this._lhs, this._operator, this._rhs);

	int evaluate(Map<String, int> neighborStateDistribution) {
		bool result;
		switch (_operator) {
			case '==':
				result = _lhs.evaluate(neighborStateDistribution) == _rhs.evaluate(neighborStateDistribution);
				break;
			case '!=':
				result = _lhs.evaluate(neighborStateDistribution) != _rhs.evaluate(neighborStateDistribution);
				break;
			case '<':
				result = _lhs.evaluate(neighborStateDistribution) < _rhs.evaluate(neighborStateDistribution);
				break;
			case '>':
				result = _lhs.evaluate(neighborStateDistribution) > _rhs.evaluate(neighborStateDistribution);
				break;
			case '<=':
				result = _lhs.evaluate(neighborStateDistribution) <= _rhs.evaluate(neighborStateDistribution);
				break;
			case '>=':
				result = _lhs.evaluate(neighborStateDistribution) >= _rhs.evaluate(neighborStateDistribution);
				break;
			case '&&':
				result = (_lhs.evaluate(neighborStateDistribution) != 0) && (_rhs.evaluate(neighborStateDistribution) != 0);
				break;
			case '||':
				result = (_lhs.evaluate(neighborStateDistribution) != 0) || (_rhs.evaluate(neighborStateDistribution) != 0);
				break;
			default:
				throw new Error();
		}
		return result ? 1 : 0;
	}

	bool operator ==(Object obj) => (obj is OperatorConditionNode) && (obj._operator == _operator) && (obj._lhs == _lhs) && (obj._rhs == _rhs);
}

class StateConditionNode implements ConditionNode {
	String _state;

	StateConditionNode(this._state);

	int evaluate(Map<String, int> neighborStateDistribution) {
		if (neighborStateDistribution.containsKey(_state))
			return neighborStateDistribution[_state];
		else
			return 0;
	}

	bool operator ==(Object obj) => (obj is StateConditionNode) && (obj._state == _state);
}

class NumberConditionNode implements ConditionNode {
	int _value;

	NumberConditionNode(String value) {
		_value = int.parse(value);
	}

	int evaluate(Map<String, int> neighborStateDistribution) {
		return _value;
	}

	bool operator ==(Object obj) => (obj is NumberConditionNode) && (obj._value == _value);
}
