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

	bool evaluate(Map<String, int> neighborStateDistribution, int age, int generation) {
		if (_tree == null)
			return true;
		else
			return _tree.evaluate(new ConditionContext(neighborStateDistribution, age, generation)) != 0;
	}
}

class ConditionContext {
  Map<String, int> _neighborStateDistribution;
  int _age, _generation;

  Map<String, int> get neighborStateDistribution => _neighborStateDistribution;
  int get age => _age;
  int get generation => _generation;

  ConditionContext(this._neighborStateDistribution, this._age, this._generation);
}