library life;

import 'dart:collection' show SplayTreeSet, SplayTreeMap;
import 'dart:convert' show JSON;
import 'dart:html';
import 'dart:math' show Random;
import 'package:unittest/unittest.dart';

part 'configuration.dart';
part 'graphics.dart';
part 'grid.dart';
part 'transition.dart';
part 'condition/condition.dart';
part 'condition/token.dart';
part 'condition/node.dart';
part 'condition/lexer.dart';
part 'condition/parser.dart';

/**
 * Testing Code
 */
void main() {
	String json1 = '{"name":"Original","states":[{"name":"DEAD","color":"#808080","transitions":[{"condition":"LIVE == 3","next":"LIVE"}]},{"name":"LIVE","color":"#FFFF00","transitions":[{"condition":"LIVE < 2 || LIVE > 3","next":"DEAD"}]}],"default":"DEAD"}';
	String json2 = '{"name":"Original Genesis","states":[{"name":"DEAD","color":"#808080","transitions":[{"condition":"LIVE == 3","next":"LIVE"},{"condition":"LIVE == 0","next":{"LIVE":1,"DEAD":9}}]},{"name":"LIVE","color":"#FFFF00","transitions":[{"condition":"LIVE < 2 || LIVE > 3","next":"DEAD"}]}],"default":"DEAD"}';

	group('Configuration parsing', () {
		test("Original", () => expect(new Configuration.fromJson(json1), equals(
			new Configuration(
            	"Original",
            	"DEAD",
            	["DEAD", "LIVE"],
            	new SplayTreeMap.from({"DEAD":"#808080", "LIVE":"#FFFF00"}),
            	new SplayTreeMap.from({
            		"DEAD": [new Transition(new Condition("LIVE == 3"), new ConstantNextStateGenerator("LIVE"))],
            		"LIVE": [new Transition(new Condition("LIVE < 2 || LIVE > 3"), new ConstantNextStateGenerator("DEAD"))]
            	})
            )
		)));
        test("Original Genesis", () => expect(new Configuration.fromJson(json2), equals(
    		new Configuration(
            	"Original Genesis",
            	"DEAD",
            	["DEAD", "LIVE"],
            	new SplayTreeMap.from({"DEAD":"#808080", "LIVE":"#FFFF00"}),
            	new SplayTreeMap.from({
            		"DEAD": [
            			new Transition(new Condition("LIVE == 3"), new ConstantNextStateGenerator("LIVE")),
            			new Transition(new Condition("LIVE == 0"), new RandomNextStateGenerator(new SplayTreeMap.from({"DEAD":9, "LIVE":1}), 10))
            		],
            		"LIVE": [new Transition(new Condition("LIVE < 2 || LIVE > 3"), new ConstantNextStateGenerator("DEAD"))]
            	})
            )
        )));
	});

	String condition1 = "DEAD == 0";
	String condition2 = "LIVE < 2 || LIVE > 3";
	String condition3 = "(LIVE >= 3 && DEAD == 0) || (LIVE <= 2 && IMMORTAL != 0)";

	group('Condition lexing', () {
		test(condition1, () {
			expect(ConditionLexer.lexCondition(condition1), orderedEquals(
				[
					new ConditionToken(ConditionToken.STATE_TYPE, "DEAD"),
					new ConditionToken(ConditionToken.OPERATOR_TYPE, "=="),
					new ConditionToken(ConditionToken.NUMBER_TYPE, "0")
				]
			));
		});
		test(condition2, () {
			expect(ConditionLexer.lexCondition(condition2), orderedEquals(
				[
					new ConditionToken(ConditionToken.STATE_TYPE, "LIVE"),
					new ConditionToken(ConditionToken.OPERATOR_TYPE, "<"),
					new ConditionToken(ConditionToken.NUMBER_TYPE, "2"),
					new ConditionToken(ConditionToken.OPERATOR_TYPE, "||"),
					new ConditionToken(ConditionToken.STATE_TYPE, "LIVE"),
					new ConditionToken(ConditionToken.OPERATOR_TYPE, ">"),
					new ConditionToken(ConditionToken.NUMBER_TYPE, "3")
				]
			));
		});
		test(condition3, () {
			expect(ConditionLexer.lexCondition(condition3), orderedEquals(
				[
					new ConditionToken(ConditionToken.LPAREN_TYPE, "("),
					new ConditionToken(ConditionToken.STATE_TYPE, "LIVE"),
					new ConditionToken(ConditionToken.OPERATOR_TYPE, ">="),
					new ConditionToken(ConditionToken.NUMBER_TYPE, "3"),
					new ConditionToken(ConditionToken.OPERATOR_TYPE, "&&"),
					new ConditionToken(ConditionToken.STATE_TYPE, "DEAD"),
					new ConditionToken(ConditionToken.OPERATOR_TYPE, "=="),
					new ConditionToken(ConditionToken.NUMBER_TYPE, "0"),
					new ConditionToken(ConditionToken.RPAREN_TYPE, ")"),
					new ConditionToken(ConditionToken.OPERATOR_TYPE, "||"),
					new ConditionToken(ConditionToken.LPAREN_TYPE, "("),
					new ConditionToken(ConditionToken.STATE_TYPE, "LIVE"),
					new ConditionToken(ConditionToken.OPERATOR_TYPE, "<="),
					new ConditionToken(ConditionToken.NUMBER_TYPE, "2"),
					new ConditionToken(ConditionToken.OPERATOR_TYPE, "&&"),
					new ConditionToken(ConditionToken.STATE_TYPE, "IMMORTAL"),
					new ConditionToken(ConditionToken.OPERATOR_TYPE, "!="),
					new ConditionToken(ConditionToken.NUMBER_TYPE, "0"),
					new ConditionToken(ConditionToken.RPAREN_TYPE, ")")
				]
			));
		});
	});

	group('Condition parsing', () {
		test(condition1, () {
			expect(ConditionParser.parseCondition(ConditionLexer.lexCondition(condition1)), equals(
				new OperatorConditionNode(
					new StateConditionNode("DEAD"),
					"==",
					new NumberConditionNode("0")
				)
			));
		});
		test(condition2, () {
			expect(ConditionParser.parseCondition(ConditionLexer.lexCondition(condition2)), equals(
				new OperatorConditionNode(
					new OperatorConditionNode(
    					new StateConditionNode("LIVE"),
    					"<",
    					new NumberConditionNode("2")
    				),
    				"||",
    				new OperatorConditionNode(
    					new StateConditionNode("LIVE"),
    					">",
    					new NumberConditionNode("3")
    				)
				)
			));
		});
		test(condition3, () {
			expect(ConditionParser.parseCondition(ConditionLexer.lexCondition(condition3)), equals(
				new OperatorConditionNode(
					new OperatorConditionNode(
						new OperatorConditionNode(
	    					new StateConditionNode("LIVE"),
	    					">=",
	    					new NumberConditionNode("3")
	    				),
	    				"&&",
	    				new OperatorConditionNode(
	    					new StateConditionNode("DEAD"),
	    					"==",
	    					new NumberConditionNode("0")
	    				)
					),
					"||",
					new OperatorConditionNode(
						new OperatorConditionNode(
	    					new StateConditionNode("LIVE"),
	    					"<=",
	    					new NumberConditionNode("2")
	    				),
	    				"&&",
	    				new OperatorConditionNode(
	    					new StateConditionNode("IMMORTAL"),
	    					"!=",
	    					new NumberConditionNode("0")
	    				)
					)
				)
			));
		});
	});
}