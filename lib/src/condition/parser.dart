part of life;

class ParsingException extends ConfigurationException {
	ParsingException(String message) : super("Parsing Error - " + message);
}

class ConditionParser {
	// These are the different classes of binary operators used for order of operation.
	static Set<String> BOOLEAN_OPERATORS = new Set.from(["&&", "||"]);
	static Set<String> COMPARISON_OPERATORS = new Set.from(["==", "!=", "<", ">", "<=", ">="]);

	static ConditionNode parseCondition(List<ConditionToken> tokens) {
		ParserInput input = new ParserInput(tokens);
		ConditionNode tree = parseExpression(input);

		if (!input.end())
			throw new ParsingException("Unexpected content after valid condition");

		return tree;
	}

	static ConditionNode parseExpression(ParserInput input) {
		return parseBooleanOperator(input);
	}

	static ConditionNode parseBooleanOperator(ParserInput input) {
		return parseBinaryOperator(input, parseComparisonOperator, BOOLEAN_OPERATORS);
	}

	static ConditionNode parseComparisonOperator(ParserInput input) {
		return parseBinaryOperator(input, parseTerm, COMPARISON_OPERATORS);
	}

	static ConditionNode parseBinaryOperator(ParserInput input, ConditionNode parseSubtree(ParserInput input), Set<String> operators) {
		ConditionNode lhs = parseSubtree(input);

		ConditionToken operatorToken = input.next();
		if (operatorToken == null)
			return lhs;

		if (operatorToken.type != ConditionToken.OPERATOR_TYPE || !operators.contains(operatorToken.text)) {
			input.stepBack();
			return lhs;
		}

		/*
    	 * We implement LEFT ASSOCIATIVITY here by performing an iterative approach of parsing a rhs node to complete
    	 * an operator node, which is assigned as the lhs for the next operator node.  This causes the LEFTMOST tokens
    	 * in a string of equal precedence operators to end up at the deepest level of the subtree, which is evaluated
    	 * first.  To implement RIGHT ASSOCIATIVITY, a recursive approach would be more suitable.
    	 */
		ConditionNode rhs, result;
		while (true) {
			rhs = parseSubtree(input);

			// We have successfully parsed an operator expression
			result = new OperatorConditionNode(lhs, operatorToken.text, rhs);

			operatorToken = input.next();
			if (operatorToken == null)
				break;

			if (operatorToken.type != ConditionToken.OPERATOR_TYPE || !operators.contains(operatorToken.text)) {
    			input.stepBack();
    			break;
    		}

			// We have another operator expression for which to parse the rhs
			lhs = result;
		}

		return result;
	}

	static ConditionNode parseTerm(ParserInput input) {
		ConditionToken token = input.next();
		if (token == null)
			throw new ParsingException("Unexpected end of condition");

		switch (token.type) {
			case ConditionToken.STATE_TYPE:
				return new StateConditionNode(token.text);
      case ConditionToken.VARIABLE_TYPE:
        String upperCaseText = token.text.toUpperCase();

        if (upperCaseText == "{AGE}")
          return new AgeConditionNode();
        else if (upperCaseText == "{GEN}")
          return new GenerationConditionNode();

        throw new ParsingException("Invalid variable reference '" + token.text + "'");
			case ConditionToken.NUMBER_TYPE:
				return new NumberConditionNode(token.text);
			case ConditionToken.LPAREN_TYPE:
				ConditionNode subNode = parseExpression(input);
				ConditionToken rParenToken = input.next();

				if ((rParenToken == null) || rParenToken.type != ConditionToken.RPAREN_TYPE)
					throw new ParsingException("Missing closing parenthesis");

				return subNode;
		}

		throw new ParsingException("Missing term in expression");
	}
}

class ParserInput {
	List<ConditionToken> _tokens;
	int _pos;

	ParserInput(this._tokens, [this._pos = 0]);

	ConditionToken next() {
		if (_pos < _tokens.length)
			return _tokens[_pos++];

		return null;
	}

	void stepBack() {
		if (_pos > 0)
			_pos--;
	}

	bool end() {
		return _pos >= _tokens.length;
	}
}