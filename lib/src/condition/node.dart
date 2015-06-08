part of life;

abstract class ConditionNode {
	int evaluate(ConditionContext context);

	bool operator ==(Object obj);
}

class OperatorConditionNode implements ConditionNode {
	ConditionNode _lhs, _rhs;
	String _operator;

	OperatorConditionNode(this._lhs, this._operator, this._rhs);

	int evaluate(ConditionContext context) {
		bool result;
		switch (_operator) {
			case '==':
				result = _lhs.evaluate(context) == _rhs.evaluate(context);
				break;
			case '!=':
				result = _lhs.evaluate(context) != _rhs.evaluate(context);
				break;
			case '<':
				result = _lhs.evaluate(context) < _rhs.evaluate(context);
				break;
			case '>':
				result = _lhs.evaluate(context) > _rhs.evaluate(context);
				break;
			case '<=':
				result = _lhs.evaluate(context) <= _rhs.evaluate(context);
				break;
			case '>=':
				result = _lhs.evaluate(context) >= _rhs.evaluate(context);
				break;
			case '&&':
				result = (_lhs.evaluate(context) != 0) && (_rhs.evaluate(context) != 0);
				break;
			case '||':
				result = (_lhs.evaluate(context) != 0) || (_rhs.evaluate(context) != 0);
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

	int evaluate(ConditionContext context) {
		if (context.neighborStateDistribution.containsKey(_state))
			return context.neighborStateDistribution[_state];
		else
			return 0;
	}

	bool operator ==(Object obj) => (obj is StateConditionNode) && (obj._state == _state);
}

class AgeConditionNode implements ConditionNode {
  int evaluate(ConditionContext context) {
    return context.age;
  }

  bool operator ==(Object obj) => (obj is AgeConditionNode);
}

class GenerationConditionNode implements ConditionNode {
  int evaluate(ConditionContext context) {
    return context.generation;
  }

  bool operator ==(Object obj) => (obj is GenerationConditionNode);
}

class NumberConditionNode implements ConditionNode {
	int _value;

	NumberConditionNode(String value) {
		_value = int.parse(value);
	}

	int evaluate(ConditionContext context) {
		return _value;
	}

	bool operator ==(Object obj) => (obj is NumberConditionNode) && (obj._value == _value);
}
