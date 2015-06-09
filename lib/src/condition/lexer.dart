part of life;

class LexingException extends ConfigurationException {
	LexingException(String message) : super("Lexing Error - " + message);
}

class ConditionLexer {
	static List<ConditionToken> lexCondition(String condition) {
		LexerInput input = new LexerInput(condition);
		List<ConditionToken> tokens = new List<ConditionToken>();

		int currentPos;
		String currentChar;
		while (!input.end()) {
			currentPos = input.pos;
			currentChar = input.current();

			if (isDigit(currentChar))
				tokens.add(lexNumber(input));
			else if (isLetter(currentChar))
				tokens.add(lexState(input));
			else if (isWhitespace(currentChar))
				input.consume();
			else
				tokens.add(lexSymbol(input));

			// We must consume some characters every iteration
			if (input.pos <= currentPos)
				throw new Error();
		}

		return tokens;
	}

	static ConditionToken lexNumber(LexerInput input) {
		int startPos = input.pos;

		while (isDigit(input.current())) {
			input.consume();
		}

		return new ConditionToken(ConditionToken.NUMBER_TYPE, input.text.substring(startPos, input.pos));
	}

	static ConditionToken lexState(LexerInput input) {
		int startPos = input.pos;

		while (isLetter(input.current())) {
			input.consume();
		}

		return new ConditionToken(ConditionToken.STATE_TYPE, input.text.substring(startPos, input.pos));
	}

  static ConditionToken lexVariable(LexerInput input) {
    int startPos = input.pos;

    while (!input.end() && input.current() != '}') {
      input.consume();
    }

    if (input.end())
      throw new LexingException("Variable reference missing end '}'");

    // Consume the end brace
    input.consume();

    return new ConditionToken(ConditionToken.VARIABLE_TYPE, input.text.substring(startPos, input.pos));
  }

	static ConditionToken lexSymbol(LexerInput input) {
		int startPos = input.pos;

		String char = input.current();
		if (char == '=' || char == '!') {
			input.consume();
			if (input.consumeChar('='))
				return new ConditionToken(ConditionToken.OPERATOR_TYPE, input.text.substring(startPos, input.pos));
		} else if (char == '<' || char == '>') {
			input.consume();
			input.consumeChar('=');
			return new ConditionToken(ConditionToken.OPERATOR_TYPE, input.text.substring(startPos, input.pos));
		} else if (char == '&' || char == '|') {
      input.consume();
      if (input.consumeChar(char))
        return new ConditionToken(ConditionToken.OPERATOR_TYPE, input.text.substring(startPos, input.pos));
    } else if (char == '+' || char == '-' || char == '*' || char == '/' || char == '%') {
      input.consume();
      return new ConditionToken(ConditionToken.OPERATOR_TYPE, input.text.substring(startPos, input.pos));
		} else if (char == '(') {
			input.consume();
			return new ConditionToken(ConditionToken.LPAREN_TYPE, '(');
		} else if (char == ')') {
			input.consume();
			return new ConditionToken(ConditionToken.RPAREN_TYPE, ')');
		} else if (char == '{') {
      return lexVariable(input);
    }

		if (input.end())
			throw new LexingException("Unexpected end of condition");
		else
			throw new LexingException("Unexpected character '" + input.current() + "' at position " + input.pos.toString());
	}
}

class LexerInput {
	String _text;
	int _pos;

	String get text => _text;
	int get pos => _pos;

	LexerInput(this._text, [this._pos = 0]) {
		if (_pos < 0)
			throw new Error();
	}

	String current () {
		if (_pos >= _text.length)
			return null;

		return _text[_pos];
	}

	bool consume() {
		if (_pos < _text.length) {
			_pos++;
			return true;
		}

		return false;
	}

	bool consumeChar(String char) {
		if (_pos < _text.length && _text[_pos] == char) {
			_pos++;
			return true;
		}

		return false;
	}

	bool end() {
		return _pos >= _text.length;
	}
}

bool isDigit(String char) {
	if (char == null || char.length != 1)
		return false;

	return char.compareTo('0') >= 0 && char.compareTo('9') <= 0;
}

bool isLetter(String char) {
	if (char == null || char.length != 1)
		return false;

	return (char.compareTo('a') >= 0 && char.compareTo('z') <= 0) ||
			(char.compareTo('A') >= 0 && char.compareTo('Z') <= 0);
}

bool isWhitespace(String char) {
	if (char == null || char.length != 1)
		return false;

	return char == ' ' || char == '\n' || char == '\r';
}