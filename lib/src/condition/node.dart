part of life;

abstract class ConditionNode {
	int evaluate(ConditionContext context);

	bool operator ==(Object obj);

	int get hashCode;
}

class OperatorConditionNode implements ConditionNode {
	ConditionNode _lhs, _rhs;
	String _operator;

	OperatorConditionNode(this._lhs, this._operator, this._rhs);

	int evaluate(ConditionContext context) {
		int lhs = _lhs.evaluate(context), rhs = _rhs.evaluate(context);
		switch (_operator) {
			case '==':
				return lhs == rhs ? 1 : 0;
			case '!=':
				return lhs != rhs ? 1 : 0;
			case '<':
				return lhs < rhs ? 1 : 0;
			case '>':
				return lhs > rhs ? 1 : 0;
			case '<=':
				return lhs <= rhs ? 1 : 0;
			case '>=':
				return lhs >= rhs ? 1 : 0;
			case '+':
				return lhs + rhs;
			case '-':
				return lhs - rhs;
			case '*':
				return lhs * rhs;
			case '/':
				return lhs ~/ rhs;
			case '%':
				return lhs % rhs;
			case '&&':
				return _lhs != 0 && _rhs != 0 ? 1 : 0;
			case '||':
				return _lhs != 0 || _rhs != 0 ? 1 : 0;
			default:
				throw new Error();
		}
	}

	bool operator ==(Object obj) => (obj is OperatorConditionNode) &&
	(obj._operator == _operator) && (obj._lhs == _lhs) && (obj._rhs == _rhs);

	int get hashCode => hash3(_lhs, _operator, _rhs);
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

	int get hashCode => _state.hashCode;
}

class AgeConditionNode implements ConditionNode {
	int evaluate(ConditionContext context) {
		return context.age;
	}

	bool operator ==(Object obj) => (obj is AgeConditionNode);

	int get hashCode => 0;
}

class GenerationConditionNode implements ConditionNode {
	int evaluate(ConditionContext context) {
		return context.generation;
	}

	bool operator ==(Object obj) => (obj is GenerationConditionNode);

	int get hashCode => 0;
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

	int get hashCode => _value;
}
