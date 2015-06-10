# Cellular Sandbox

Inspired by Conway's Game of Life, this web application allows you to customize the rules of a 
cellular automata within the bounds of a 100x100 cell grid.  Specify the possible cell states, 
their possible transitions to other states, and the conditions under which those transitions 
occur with a simple json configuration file described below. Checkout some example [configurations](https://github.com/sstrick22/CellularSandbox/tree/master/web/configurations) 
for inspiration and start making your own rules of life!

## Condition

A condition is an equation used to specify when a state transition should occur.  For example,
a condition describing when a "LIVE" cell should transition to "DEAD" in Conway's Game of Life 
would be `LIVE < 2 || LIVE > 3`. A condition evaluates to true or false indicating whether the 
condition is met. The empty condition is a special case that always evaluates to true. The 
symbols available in a condition are:

### Values

#### Integers
Any string of digits (0-9). For example, `3` or `52`.    
Resolves to the **number** represented by this string.
	
#### State Variables
Any string of letters (a-z,A-Z) matching a state specified in the current configuration 
(case sensitive). For example, `dead` or `LIVE`.  
Resolves to the **number** of neighbors of the current cell that are in the state represented 
by this string.

#### Temporal Variables
One of the strings `{AGE}` and `{GEN}` (case insensitive).  
`{AGE}`: Resolves to the **number** of consecutive generations prior to the current generation
where the current cell was in its current state.  
`{GEN}`: Resolves to the **number** of generations that have passed since the first generation 
(in other words, the current generation).

### Operators

#### Airthmetic Operators
One of the strings `+`, `-`, `*`, `/`, and `%`. These are binary operators that expect two 
**number** arguments and resolve to a **number**.  
`+`: Resolves to the sum of the two arguments.  
`-`: Resolves to the lhs minus the rhs.  
`*`: Resolves to the product of the two arguments.  
`/`: Resolves to the lhs divided by the rhs (integer division).  
`%`: Resolves to the remainder of dividing the lhs by the rhs (integer division).  

#### Comparison Operators
One of the strings `==`, `!=`, `<`, `>`, `<=`, and `>=`. These are binary operators that expect two 
*number* arguments and resolve to a **bool**.
`==`: Resolves to a **bool** indicating whether the two arguments are equal.  
`!=`: Resolves to a **bool** indicating whether the two arguments are not equal.  
`<`: Resolves to a **bool** indicating whether the lhs is less than the rhs.  
`>`: Resolves to a **bool** indicating whether the lhs is greater than the rhs.  
`<=`: Resolves to a **bool** indicating whether the lhs is less than or equal to the rhs.  
`>=`: Resolves to a **bool** indicating whether the lhs is greater than or equal to the rhs.  

#### Logical Operators
One of the strings `||` and `&&`. These are binary operators that expect two **bool** arguments
and resolve to a **bool**.  
`||`: Resolves to a **bool** indicating whether at least one of the arguments is true.  
`&&`: Resolves to a **bool** indicating whether both of the arguments are true.

#### Argument Conversion
Operators will convert arguments of the wrong type to the right type according to the following 
conversions:
- **number** to **bool**: The number 0 is converted to false, all other numbers are converted to true.
- **bool** to **number**: The bool false is converted to 0 and the bool true is converted to 1.

#### Order of Operations
The operators have verious levels of precedence, which can determine their order of evaluation.  
- Level 1: `*`, `/`, `%`  
- Level 2: `+`, `-` 
- Level 3: `==`, `!=`, `<`, `>`, `<=`, `>=`  
- Level 4: `||`, `&&`  

That means that a condition such as `LIVE == DEAD + 1 * 2 || DEAD > 5` will be interpreted as 
`((LIVE == (DEAD + (1 * 2))) || (DEAD > 5))`. Explicitly type parenthesis into your condition 
formula to override this behavior. Consecutive operators in the same level will be evaluated 
left to right.

## Transition

A transition encapsulates a path that a cell in a specific state can take to become another state. 
The two properties of a transition are the `condition` (described above) that must be met for the 
transition to take place, and the `next` state (or states) that a cell can take if the condition is met.  

For a deterministic transition, `next` can simply be a string matching a state specified in the current  configuration (case sensitive). For example, a transition that a `DEAD` cell can take to become `LIVE` 
in Conway's Game of Life would be:

```json
{
  "condition": "LIVE == 3",
  "next": "LIVE"
}
```

For a non-deterministic transition, `next` can be a map of state to an integer weight. In this case, 
the next state is determined randomly each time the transition is taken in a process analogous to 
spinning a roulette wheel with each state owning a number of slots equal to its weight.  Whichever slot 
the ball lands in is the next state for that specific cell transition.  For example, a transition where 
a cell would become `LIVE` 1% of the time and `DEAD` 99% of the time if the cell has no `LIVE` neighbors 
would be:

```json
{
  "condition": "LIVE == 0",
  "next": {
    "LIVE": 1,
    "DEAD": 99,
  }
}
```

## State

A state encapsulates a possible state that a cell can be in during a given generation. The three 
properties of a state are the `name` of the state, the hex `color` that a cell will be when in the 
state, and the `transitions` that the state can take to become another state. For example, the "LIVE" 
state in Conway's Game of Life can be represented as:

```json
{
  "name": "LIVE",
  "color": "#FFFF00",
  "transitions": [
    {
      "condition": "LIVE < 2 || LIVE > 3",
      "next": "DEAD",
    }
  ]
}
```

The order of the `transitions` list is important.  During a generation shift for a cell, the 
transition conditions for the cell's state will be evaluated in the order that the transitions 
are listed. The first transition whose condition evaluates to true will be taken. If no transition 
conditions evaluate to true, the cell's state will not change for the next generation.  For example, 
a permanent dead state could be easily written as:

```json
{
  "name": "PERMADEAD",
  "color": "#000000",
  "transitions": []
}
```

## Configuration

A configuration encapsulates the rules of a cellular automata that this application can simulate.  The three properties of a configuration are the `name` of the configuration, the possible `states` that a cell can be 
using this configuration, and the `default` state that cells will be on generation 0 (and that all cells 
outside of the 100x100 grid are permanently).  For example, Conway's Game of Life can be represented as:

```json
{
  "name": "Conway's Game of Life",
  "states": [
    {
      "name": "DEAD",
      "color": "#808080",
      "transitions": [
        {
          "condition": "LIVE == 3",
          "next": "LIVE"
        }
      ]
    },
    {
      "name": "LIVE",
      "color": "#FFFF00",
      "transitions": [
        {
          "condition": "LIVE < 2 || LIVE > 3",
          "next": "DEAD"
        }
      ]
    }
  ],
  "default": "DEAD"
}
```
