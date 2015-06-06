part of life;

class Condition {
	String _condition;
	List<ConditionToken> _tokens;
	ConditionNode _tree;

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
	}

	bool evaluate(Map<String, int> neighborStateDistribution) {
		if (_tree == null)
			return true;
		else
			return _tree.evaluate(neighborStateDistribution) != 0;
	}
}