[TOC]

# 1. Introduction

This document specifies the new input language of the automated theorem prover [SCTLProV](https://github.com/terminatorlxj/SCTLProV). This input language is designed much like a ML-style real world programming language, in order to ease the task of generating Kripke models out of real world computer systems. 

# 2. The New Input Language

The specification of the new input language is organized to 4 parts: 

1. Lexical tokens;
2. Datatype declarations;
3. Expression and function declarations;
4. Programe structures.  

## 2.1 Lexical tokens

The content of an input file is an sequence of characters, which will be recognized as a sequence of lexical tokens by a lexical analyzer. Among these tokens, a number is a sequence of digits, an identifier is a sequence of characters beginning with an alphabetic character, and followed by any sequence of characters in the set `{A-Z, a-Z, 0-9, _}`.

The keywords are listed below:

```
	Model  Var  Define Init Transition Atomic Spec
	true  false  TRUE FALSE  not  AX  EX  AF  EG  AR  EU
	datatype value function let match with if then else 
```

Any other tokens are in quotes in the syntax descriptions.

## 2.2 Datatype declarations

Like in read world programming languages, the new input language consists of base types, compound types, and user defined types.

### 2.2.1 Base types

Base types are listed as follows.

1. `unit`: the unit type. `()` the only one constant of type `unit`. Besides, the type of commands is also `unit`;
2. `int`: integer type, whose range depends on the implementation platform of the prover SCTLProV. For instance, if SCTLProV is implemented in 32-bit OCaml platform, then the range of the type `int` is [-2^31^, 2^31^-1]; 
3. `float`: double precision (64 bits) floating-point type, following the IEEE 754 standard;
4. `bool`: boolean type, which consists two dinsguishable values: `true` and `false`;

### 2.2.2 Compound types

* Tuple

  A tuple type with n fields is of the form `(t1, t2, ... , tn) `, where `t1`, `t2`, …, `tn` are data types. A term of a tuple type with n fields is of the form `(e1, e2, ... ,en)`, where `e1`, `e2`, … , `en` are expressions of type  `t1`, `t2`, …, `tn`, respectively.

* Record

  Records are tuples where each field has an identical name. A record with n fields is of the form `{l1: t1; l2: t2; ... ; ln: tn}`, where `l1`, `l2`, … , `ln` are name of the labels of each field. 

* Array 

  Array is a polymorphic type of the form `array t`, where `t` is a type.

* List

  List is a polymorphic type of the form `list t`, where `t` is a type. 


### 2.2.2 User defined types

In addition to the compound types, the definition of user defined data types is another way to define new data types. Besides of defining new data types, user defined types can also be used to define type aliases, i.e., to define an alternative representation of a predefined data type.

Users can define types in the following form.

```
udt ::= variant_type | record_type 

variant_type ::= constructor {"|" constructor}*
constructor ::= Iden | Iden type 

record_type ::= "{" {type_bingding}* "}"
type_binding ::= iden ":" type ";"
```

**Remark:**  An `Iden` is an `iden` with the first letter in upper case.

The syntax of `type` is specified as follows.

```
type ::= 
	     unit | int | float | bool 		(*base types*)
	   | (type, type, ... , type)								(*tuple type*)
	   | "{" {iden ":" type ";"}* iden ":" type "}"	
	   															(*record type*)
	   | array type												(*array type*)
	   | list type												(*list type*)
	   | udt													(*user defined type*)
	   | type "->" type											(*function type*)
```

User defined data types can be defined in a program as follows.

```
udt_def ::=   "datatype" iden "=" type (*to define new types or type aliases*)
```

## 2.3 Expressions

Expressions are terms of given types. 

```
expr ::=
        iden                (*variable or constructor name*)
      | expr "." iden		(*select one field of a record*)
      | expr "[" expr "]"	(*select one field of a array*)
      | "!" expr            (*logical negation*)
      | expr "&&" expr      (*logical and*)
      | expr "||" expr      (*logical or*)
      | "-" expr            (*integer negation*)
      | expr "+" expr       (*integer addition*)
      | expr "-" expr       (*integer subtraction*)
      | expr "*" expr       (*integer multiplication*)
      | "-." expr 			(*float negation*)
      | expr "+." expr		(*float addition*)
      | expr "-." expr 		(*float subtraction*)
      | expr "*." expr 		(*float multiplication*)
      | expr "=" expr       (*expression equivalence*)
      | expr "!=" expr      (*expression non-equivalence*)
      | expr "<" expr       (*less than*)
      | expr "<=" expr      (*less than or equal*)
      | expr ">" expr       (*larger than*)
      | expr ">=" expr      (*larger than or equal*)
      | "(" expr ")"		(*expression grouping*)
      | "let" pattern "=" expr					(*declare local variables*)
      | "if" expr "then" expr [ "else" expr ] 	(*if expression*)
      | while expr do expr						(*while expression*)
      | "for" expr "in" "[" expr "," expr "]" do expr	(*for expression*)
      | expr ";" expr							(*expression with effect*)
      | expr "<-" expr							(*assignment*)
      | match_expr								(*pattern matching*)
      | expr "with" "{" {iden "=" expr ";"}* iden "=" expr "}"
      						(*a record with changed bindings*)
      

constant ::= ()
		   | number
		   | "[]"
		   | "[||]"
		   | "true"
		   | "false"
      
match_expr ::= "match" expr "with" {"|" pattern "->" expr}+

pattern ::= iden 
		  | constant
		  | pattern "::" pattern	(*list*)
		  | {pattern ","}+ pattern 	(*tuple*)
		  | "_"						(*match any case*)
```

Expressions can be used to define constants, variables, and functions in a program.

### 2.3.1 Values

```
value_def ::= "value" iden "=" expr		(*values*)
```

### 2.3.2 Functions

```
fun_def ::= iden "(" args ")" "=" expr

args ::= pattern [":" type] {"," pattern [":" type]}*
```

## 2.4 Kripke model

The Kripke model is specified by the declaration as follows.

```
kripke_def ::= "Model" "{"
				[
					"Vars"  "{" 
						{iden ":" type ";"}+ 
					"}" 
				]
				[
                  	"Init" "{"
                  		{iden ":=" expr ";"}+
                  	"}"
				]
				"Transition" "{"
					"next" iden ":=" {expr ":" expr ";"}+
 				"}"
				"Atomic" "{"
					{iden "(" {iden ","}* iden ")" ":=" expr ";"}*
				"}"
				"Fairness" "{"
					{formula ";"}* formula
				"}"
				"Spec" "{"
					{iden ":=" formula ";"}+
				"}"
			"}"
			
formula ::= iden "(" iden {"," iden}* ")"
		  | "not" formula
		  | formula "/\" formula
		  | formula "\/" formula
		  | "EX" "(" iden "," formula "," expr ")"
		  | "AX" "(" iden "," formula "," expr ")"
		  | "EG" "(" iden "," formula "," expr ")"
		  | "AF" "(" iden "," formula "," expr ")"
		  | "EU" "(" iden "," iden "," formula "," formula "," expr ")"
		  | "AR" "(" iden "," iden "," formula "," formula "," expr ")"
```

## 2.5 Program Structure

Programs are organized as modules. Each modules contains a set of declarations.

```
kripke_model ::= 
		{"import" iden}*
		{udt_def | value_def | fun_def}*
		[kripke_def]
```

