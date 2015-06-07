# Cellular Sandbox

Inspired by Conway's Game of Life, this web application allows you to customize the rules of a 
cellular automata within the bounds of a 100x100 cell grid.  Specify the possible cell states, 
their possible transitions to other states, and the conditions under which those transitions 
occur with a simple json configuration file described below.

## Condition

A condition is an equation used to specify when a state transition should occur.  For example,
a condition describing when a "DEAD" cell should transition to "LIVE" in Conway's Game of Life 
would be `LIVE == 2 || LIVE == 3`. The symbols available in a condition are:

### Values

#### Integers
Any string of digits (0-9). For example, `3` or `52`.    
Resolves to the **number** represented by this string.
	
#### State Variables
Any string matching a state specified in the current configuration (case sensitive). For 
example, `dead` or `LIVE`.  
Resolves to the **number** of neighbors of the current cell that are in this state.

#### Temporal Variables (Coming Soon)
One of the strings `[AGE]` and `[GEN]` (case insensitive).  
`[AGE]`: Resolves to the **number** of consecutive generations prior to the current generation
where the current cell was in its current state.  
`[GEN]`: Resolves to the **number** of generations that have passed since the first generation 
(in other words, the current generation).

### Operators

#### Comparison Operators
One of the strings `==`, `!=`, `<`, `>`, `<=`, and `>=`. These are binary operators that expect two 
*number* arguments.
`==`: Resolves to a **bool** indicating whether the two arguments are equal.  
`!=`: Resolves to a **bool** indicating whether the two arguments are not equal.  
`<`: Resolves to a **bool** indicating whether the lhs is less than the rhs.  
`>`: Resolves to a **bool** indicating whether the lhs is greater than the rhs.  
`<=`: Resolves to a **bool** indicating whether the lhs is less than or equal to the rhs.  
`>=`: Resolves to a **bool** indicating whether the lhs is greater than or equal to the rhs.  

#### Logical Operators
One of the strings `||` and `&&`. These are binary operators that expect two **bool** arguments.  
`||`: Resolves to a **bool** indicating whether at least one of the arguments is true.  
`&&`: Resolves to a **bool** indicating whether both of the arguments are true.

Operators will convert arguments of the wrong type to the right type according to the following 
conversions:
- **number** to **bool**: The number 0 is converted to false, all other numbers are converted to true.
- **bool** to **number**: The bool false is converted to 0 and the bool true is converted to 1.

The comparison operators have a higher precedence than the logical operators.  That means in a 
condition such as `LIVE == 3 || LIVE > 5`, the comparision operators `==` and `>` will be evaluated 
before the logical operator `||`.  Consecutive operators in the same class will be evaluated left to 
right.

## Transition

## Configuration

