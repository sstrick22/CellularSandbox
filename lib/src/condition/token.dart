part of life;

class ConditionToken {
	static const String NUMBER_TYPE = "number";
	static const String STATE_TYPE = "state";
  static const String VARIABLE_TYPE = "variable";
	static const String OPERATOR_TYPE = "operator";
	static const String LPAREN_TYPE = "lparen";
	static const String RPAREN_TYPE = "rparen";

	String _type, _text;

	String get type => _type;
	String get text => _text;

	ConditionToken(this._type, this._text);

	bool operator ==(Object obj) => (obj is ConditionToken) && (obj._type == _type) && (obj._text == _text);
  int get hashCode => hash2(_type, _text);
}