import 'dart:collection' show SplayTreeSet, SplayTreeMap;
import 'package:unittest/unittest.dart';
import 'package:life/life.dart' as life;

void main() {
	String json1 = '{"name":"Original","states":[{"name":"DEAD","color":"#808080","transitions":[{"condition":"LIVE == 3","next":"LIVE"}]},{"name":"LIVE","color":"#FFFF00","transitions":[{"condition":"LIVE < 2 || LIVE > 3","next":"DEAD"}]}],"default":"DEAD"}';
	String json2 = '{"name":"Original Genesis","states":[{"name":"DEAD","color":"#808080","transitions":[{"condition":"LIVE == 3","next":"LIVE"},{"condition":"LIVE == 0","next":{"LIVE":1,"DEAD":9}}]},{"name":"LIVE","color":"#FFFF00","transitions":[{"condition":"LIVE < 2 || LIVE > 3","next":"DEAD"}]}],"default":"DEAD"}';

	group('Configuration parsing', () {
		test("Original", () => expect(new life.Configuration.fromJson(json1), equals(
			new life.Configuration(
				"Original",
				"DEAD",
				["DEAD", "LIVE"],
				new SplayTreeMap.from({"DEAD":"#808080", "LIVE":"#FFFF00"}),
				new SplayTreeMap.from({
					"DEAD": [new life.Transition(new life.Condition("LIVE == 3"),
					new life.ConstantNextStateGenerator("LIVE"))],
					"LIVE": [new life.Transition(new life.Condition("LIVE < 2 || LIVE > 3"),
					new life.ConstantNextStateGenerator("DEAD"))]
				})
			)
		)));
		test("Original Genesis", () => expect(new life.Configuration.fromJson(json2), equals(
			new life.Configuration(
				"Original Genesis",
				"DEAD",
				["DEAD", "LIVE"],
				new SplayTreeMap.from({"DEAD":"#808080", "LIVE":"#FFFF00"}),
				new SplayTreeMap.from({
					"DEAD": [
						new life.Transition(new life.Condition("LIVE == 3"),
						new life.ConstantNextStateGenerator("LIVE")),
						new life.Transition(new life.Condition("LIVE == 0"),
						new life.RandomNextStateGenerator(new SplayTreeMap.from({"DEAD":9, "LIVE":1}),
						10))
					],
					"LIVE": [new life.Transition(new life.Condition("LIVE < 2 || LIVE > 3"),
					new life.ConstantNextStateGenerator("DEAD"))]
				})
			)
		)));
	});

	String condition1 = "DEAD == 0";
	String condition2 = "LIVE < 2 || LIVE > 3";
	String condition3 = "(LIVE >= 3 && DEAD == 0) || (LIVE <= 2 && IMMORTAL != 0)";
	String condition4 = "{aGe} > 0 && {GEN} < 100 && LIVE == 3";
	String condition5 = "DEAD < LIVE + IMMORTAL * 2 && {GEN} % 2 == 0";
	String condition6 = "{GEN} < 2 && LIVE == 0";

	group('Condition lexing', () {
		test(condition1, () {
			expect(life.ConditionLexer.lexCondition(condition1), orderedEquals(
				[
					new life.ConditionToken(life.ConditionToken.STATE_TYPE, "DEAD"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "=="),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "0")
				]
			));
		});
		test(condition2, () {
			expect(life.ConditionLexer.lexCondition(condition2), orderedEquals(
				[
					new life.ConditionToken(life.ConditionToken.STATE_TYPE, "LIVE"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "<"),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "2"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "||"),
					new life.ConditionToken(life.ConditionToken.STATE_TYPE, "LIVE"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, ">"),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "3")
				]
			));
		});
		test(condition3, () {
			expect(life.ConditionLexer.lexCondition(condition3), orderedEquals(
				[
					new life.ConditionToken(life.ConditionToken.LPAREN_TYPE, "("),
					new life.ConditionToken(life.ConditionToken.STATE_TYPE, "LIVE"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, ">="),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "3"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "&&"),
					new life.ConditionToken(life.ConditionToken.STATE_TYPE, "DEAD"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "=="),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "0"),
					new life.ConditionToken(life.ConditionToken.RPAREN_TYPE, ")"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "||"),
					new life.ConditionToken(life.ConditionToken.LPAREN_TYPE, "("),
					new life.ConditionToken(life.ConditionToken.STATE_TYPE, "LIVE"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "<="),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "2"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "&&"),
					new life.ConditionToken(life.ConditionToken.STATE_TYPE, "IMMORTAL"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "!="),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "0"),
					new life.ConditionToken(life.ConditionToken.RPAREN_TYPE, ")")
				]
			));
		});
		test(condition4, () {
			expect(life.ConditionLexer.lexCondition(condition4), orderedEquals(
				[
					new life.ConditionToken(life.ConditionToken.VARIABLE_TYPE, "{aGe}"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, ">"),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "0"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "&&"),
					new life.ConditionToken(life.ConditionToken.VARIABLE_TYPE, "{GEN}"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "<"),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "100"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "&&"),
					new life.ConditionToken(life.ConditionToken.STATE_TYPE, "LIVE"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "=="),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "3")
				]
			));
		});
		test(condition5, () {
			expect(life.ConditionLexer.lexCondition(condition5), orderedEquals(
				[
					new life.ConditionToken(life.ConditionToken.STATE_TYPE, "DEAD"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "<"),
					new life.ConditionToken(life.ConditionToken.STATE_TYPE, "LIVE"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "+"),
					new life.ConditionToken(life.ConditionToken.STATE_TYPE, "IMMORTAL"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "*"),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "2"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "&&"),
					new life.ConditionToken(life.ConditionToken.VARIABLE_TYPE, "{GEN}"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "%"),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "2"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "=="),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "0")
				]
			));
		});
		test(condition6, () {
			expect(life.ConditionLexer.lexCondition(condition6), orderedEquals(
				[
					new life.ConditionToken(life.ConditionToken.VARIABLE_TYPE, "{GEN}"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "<"),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "2"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "&&"),
					new life.ConditionToken(life.ConditionToken.STATE_TYPE, "LIVE"),
					new life.ConditionToken(life.ConditionToken.OPERATOR_TYPE, "=="),
					new life.ConditionToken(life.ConditionToken.NUMBER_TYPE, "0")
				]
			));
		});
	});

	group('Condition parsing', () {
		test(condition1, () {
			expect(life.ConditionParser.parseCondition(life.ConditionLexer.lexCondition(condition1)),
			equals(
				new life.OperatorConditionNode(
					new life.StateConditionNode("DEAD"),
					"==",
					new life.NumberConditionNode("0")
				)
			));
		});
		test(condition2, () {
			expect(life.ConditionParser.parseCondition(life.ConditionLexer.lexCondition(condition2)),
			equals(
				new life.OperatorConditionNode(
					new life.OperatorConditionNode(
						new life.StateConditionNode("LIVE"),
						"<",
						new life.NumberConditionNode("2")
					),
					"||",
					new life.OperatorConditionNode(
						new life.StateConditionNode("LIVE"),
						">",
						new life.NumberConditionNode("3")
					)
				)
			));
		});
		test(condition3, () {
			expect(life.ConditionParser.parseCondition(life.ConditionLexer.lexCondition(condition3)),
			equals(
				new life.OperatorConditionNode(
					new life.OperatorConditionNode(
						new life.OperatorConditionNode(
							new life.StateConditionNode("LIVE"),
							">=",
							new life.NumberConditionNode("3")
						),
						"&&",
						new life.OperatorConditionNode(
							new life.StateConditionNode("DEAD"),
							"==",
							new life.NumberConditionNode("0")
						)
					),
					"||",
					new life.OperatorConditionNode(
						new life.OperatorConditionNode(
							new life.StateConditionNode("LIVE"),
							"<=",
							new life.NumberConditionNode("2")
						),
						"&&",
						new life.OperatorConditionNode(
							new life.StateConditionNode("IMMORTAL"),
							"!=",
							new life.NumberConditionNode("0")
						)
					)
				)
			));
		});
		test(condition4, () {
			expect(life.ConditionParser.parseCondition(life.ConditionLexer.lexCondition(condition4)),
			equals(
				new life.OperatorConditionNode(
					new life.OperatorConditionNode(
						new life.OperatorConditionNode(
							new life.AgeConditionNode(),
							">",
							new life.NumberConditionNode("0")
						),
						"&&",
						new life.OperatorConditionNode(
							new life.GenerationConditionNode(),
							"<",
							new life.NumberConditionNode("100")
						)
					),
					"&&",
					new life.OperatorConditionNode(
						new life.StateConditionNode("LIVE"),
						"==",
						new life.NumberConditionNode("3")
					)
				)
			));
		});
		test(condition5, () {
			expect(life.ConditionParser.parseCondition(life.ConditionLexer.lexCondition(condition5)),
			equals(
				new life.OperatorConditionNode(
					new life.OperatorConditionNode(
						new life.StateConditionNode("DEAD"),
						"<",
						new life.OperatorConditionNode(
							new life.StateConditionNode("LIVE"),
							"+",
							new life.OperatorConditionNode(
								new life.StateConditionNode("IMMORTAL"),
								"*",
								new life.NumberConditionNode("2")
							)
						)
					),
					"&&",
					new life.OperatorConditionNode(
						new life.OperatorConditionNode(
							new life.GenerationConditionNode(),
							"%",
							new life.NumberConditionNode("2")
						),
						"==",
						new life.NumberConditionNode("0")
					)
				)
			));
		});
		test(condition6, () {
			expect(life.ConditionParser.parseCondition(life.ConditionLexer.lexCondition(condition6)),
			equals(
				new life.OperatorConditionNode(
					new life.OperatorConditionNode(
						new life.GenerationConditionNode(),
						"<",
						new life.NumberConditionNode("2")
					),
					"&&",
					new life.OperatorConditionNode(
						new life.StateConditionNode("LIVE"),
						"==",
						new life.NumberConditionNode("0")
					)
				)
			));
		});
	});
}