part of life;

class Condition {
	String _condition;
	List<ConditionToken> _tokens;
	ConditionNode _tree;
	ConditionContext _context;

	String get condition => _condition;

	List<ConditionToken> get tokens => _tokens;

	ConditionNode get tree => _tree;

	Condition(this._condition) {
		if (_condition.isEmpty) {
			_tokens = null;
			_tree = null;
		} else {
			_tokens = ConditionLexer.lexCondition(_condition);
			_tree = ConditionParser.parseCondition(_tokens);
		}
		_context = new ConditionContext();
	}

	bool evaluate(Map<String, int> neighborStateDistribution, int age, int generation) {
		if (_tree == null)
			return true;

		_context.neighborStateDistribution = neighborStateDistribution;
		_context.age = age;
		_context.generation = generation;
		return _tree.evaluate(_context) != 0;
	}
}

class ConditionContext {
	Map<String, int> neighborStateDistribution;
	int age, generation;

	ConditionContext();
}