#pragma once
#include <string>
#include <iostream>
#include <vector>

enum type {
	t_node,
	t_expr,
	t_int,
	t_float,
	t_string,
	t_bool,
	t_var,
	t_binop,
	t_list,
	t_func,
	t_line,
	t_lines,
	t_assign,
	t_if,
	t_while
};
#define strOfType std::vector<std::string>{ \
"node", \
"expression", \
"int", \
"float", \
"string", \
"bool", \
"var", \
"binary operation", \
"list", \
"function", \
"line", \
"lines", \
"assignment", \
"if statement", \
"while statement" \
}

// Base class for all nodes; will never be used explicitly
class Node {
public:
	// A string representation of the node
	virtual std::string Str() { std::cout << "\033[0;31mInternalError: \033[0;0mattempted to find string representation of empty node\n"; exit(1); }
	// The type of the node
	type Type = t_node;
};

// Base class for all expression nodes; represents void values
class Expression : public Node {
public:
	// Stores whether the value is calculated at compile or run time
	bool isConst = false;
	// Stores if the value is a binary operator
	bool isBinOp = false;
	// Stores if the value is one value or a group of them
	bool isList = false;
	type Type = t_expr;
	std::string Str() { return "void"; }
};

// Integer literal
class Int : public Expression {
public:
	int64_t val;
	Int(int val) : val(val) { isConst = true; Type = t_int; }
	std::string Str() override { return std::to_string(val); }
};

// Floating point literal
class Float : public Expression {
public:
	float val;
	Float(float val) : val(val) { isConst = true; Type = t_float; }
	std::string Str() override { return std::to_string(val); }
};
// String literal
class String : public Expression {
public:
	std::string *val;
	String(std::string *val) : val(val) { isConst = true; Type = t_string; }
	std::string Str() override { return '"' + *val + '"'; }
};
// Boolean literal
class Bool : public Expression {
public:
	bool val;
	Bool(bool val) : val(val) { isConst = true; Type = t_bool; }
	std::string Str() override { return val ? "true" : "false"; }
};
// An access to a variable
class Var : public Expression {
public:
	std::string *val;
	Var(std::string *val) : val(val) { Type = t_var; }
	std::string Str() override { return *val; }
};
// A binary operation on two expression values
class BinOp : public Expression {
public:
	Expression *left, *right;
	std::string op;
	BinOp(Expression *left, Expression *right, std::string op) : left(left), right(right), op(op) { isConst = left->isConst && right->isConst; isBinOp = true; Type = t_binop; }
	std::string Str() override { return "(" + left->Str() + " " + op + " " + right->Str() + ")"; }
};
// A call to a function
class Func : public Expression {
public:
	std::string name;
	Expression *val;
	Func(std::string name, Expression *val) : name(name), val(val) { Type = t_func; }
	std::string Str() { if (val) return name + "(" + val->Str() + ")"; else return name + "()"; }
};
// A list of values
class List : public Expression {
public:
	std::vector<Expression *> contents;
	List(Expression *first) : contents(std::vector<Expression *>{ first }) { isList = true; Type = t_list; }
	std::string Str() override {
		std::string str = "(";
		if (contents.size()) str += contents[0]->Str();
		for (int i = 1; i < contents.size(); i++)
			str += ", " + contents[i]->Str();
		return str + ")";
	}
};

// One line of code and the corresponding indent
class Line : public Node {
public:
	// The original line, used for errors
	std::string self = "";
	// The original line number, used for errors
	int num = 0;
	int indent;
	// Used for identifying the indent placement during AST generation by `Lines.AddLine()`
	// Will be 0 for any properly placed line
	int _indent;
	Line(int indent) : indent(indent), _indent(indent) { Type = t_line; }
	// Increments `indent` and `_indent`
	void Indent() {
		indent++;
		_indent++;
	}
	// Stores if the current line is a container for other lines (if, while, etc)
	bool isBlock = false;
	virtual std::string Str() override { return "empty line"; }
	// Should only be called if `isBlock` is true
	virtual void AddLine(Line *line, int indent = 0) {}
};

// A vector of lines of code
class Lines : public Node {
public:
	std::vector<Line *> *contents;
	Lines(Line *content) : contents(new std::vector<Line *>{ content }) { if (!(*contents)[0]) { contents->pop_back(); } Type = t_lines; }
	void AddLine(Line *line, int indent = 0) {
		if (!line) return;
		if (line->_indent == 0) {
			line->indent = indent;
			contents->push_back(line);
		}
		else {
			if (contents->size() && contents->back()->isBlock) {
				line->_indent--;
				contents->back()->AddLine(line, indent + 1);
			}
			else {
				std::cout << "\033[0;31mSyntaxError: \033[0;0munexpected indent\n";
				std::cout << line->num << " | " << line->self;
				exit(1);
			}
		}
	}
	std::string Str() {
		std::string str = "";
		int len = contents->size();
		if (len > 0) {
			len--;
			str += (*contents)[0]->Str();
		}
		int i = 0;
		while (i < len) {
			i++;
			str += "\n" + (*contents)[i]->Str();
		}
		return str;
	}
};

// An assignment to a variable
class Assign : public Line {
public:
	std::string *name;
	Expression *val;
	Assign(std::string *name, Expression *val, int indent) : name(name), val(val), Line(indent) { Type = t_assign; }
	std::string Str() override { if (name) return std::string(indent, '\t') + *name + " = " + val->Str(); else return std::string(indent, '\t') + val->Str(); }
};

// An if statement
class If : public Line {
public:
	// Condition for executing the contents in the if statement
	Expression *cond;
	Lines contents;
	If(Expression *cond, Line *line, int indent) : cond(cond), contents(line), Line(indent) { if (contents.contents->size()) contents.contents->back()->indent = indent + 1; isBlock = true; Type = t_if; }
	void AddLine(Line *line, int indent = 0) override { contents.AddLine(line, indent); }
	std::string Str() override { return std::string(indent, '\t') + "if " + cond->Str() + "\n" + contents.Str(); }
};

// A while loop
class While : public Line {
public:
	// Condition for executing the contents in the if statement
	Expression *cond;
	Lines contents;
	While(Expression *cond, Line *line, int indent) : cond(cond), contents(line), Line(indent) { if (contents.contents->size()) contents.contents->back()->indent = indent + 1; isBlock = true; Type = t_while; }
	void AddLine(Line *line, int indent = 0) override { contents.AddLine(line, indent); }
	std::string Str() override { return std::string(indent, '\t') + "while " + cond->Str() + "\n" + contents.Str(); }
};

inline Expression *interpretConsts(Expression *expr, Line *thisLine) {
	if (expr->Type == t_binop && expr->isConst) {
		BinOp *binop = (BinOp *)expr;
		Expression *left = interpretConsts(binop->left, thisLine);
		Expression *right = interpretConsts(binop->right, thisLine);
		switch (binop->op[0]) {
		case '+':
			if (left->Type == t_int) {
				if (right->Type == t_int) {
					return new Int(((Int *)left)->val + ((Int *)right)->val);
				}
				if (right->Type == t_float) {
					return new Float(((Int *)left)->val + ((Float *)right)->val);
				}
			}
			if (left->Type == t_float) {
				if (right->Type == t_int) {
					return new Float(((Float *)left)->val + ((Int *)right)->val);
				}
				if (right->Type == t_float) {
					return new Float(((Float *)left)->val + ((Float *)right)->val);
				}
			}
			if (left->Type == t_string && right->Type == t_string) {
				std::string str = *((String *)left)->val + *((String *)right)->val;
				return new String(&str);
			}
			std::cout << "\033[0;31mTypeError: \033[0;0mcannot add " << strOfType[left->Type] << " and " << strOfType[right->Type] << "\n";
			std::cout << thisLine->num << " | " << thisLine->self;
			exit(1);
			break;
		case '-':
			if (left->Type == t_int) {
				if (right->Type == t_int) {
					return new Int(((Int *)left)->val - ((Int *)right)->val);
				}
				if (right->Type == t_float) {
					return new Float(((Int *)left)->val - ((Float *)right)->val);
				}
			}
			if (left->Type == t_float) {
				if (right->Type == t_int) {
					return new Float(((Float *)left)->val - ((Int *)right)->val);
				}
				if (right->Type == t_float) {
					return new Float(((Float *)left)->val - ((Float *)right)->val);
				}
			}
			std::cout << "\033[0;31mTypeError: \033[0;0mcannot subtract " << strOfType[left->Type] << " and " << strOfType[right->Type] << "\n";
			std::cout << thisLine->num << " | " << thisLine->self;
			exit(1);
			break;
		case '*':
			if (left->Type == t_int) {
				if (right->Type == t_int) {
					return new Int(((Int *)left)->val * ((Int *)right)->val);
				}
				if (right->Type == t_float) {
					return new Float(((Int *)left)->val * ((Float *)right)->val);
				}
			}
			if (left->Type == t_float) {
				if (right->Type == t_int) {
					return new Float(((Float *)left)->val * ((Int *)right)->val);
				}
				if (right->Type == t_float) {
					return new Float(((Float *)left)->val * ((Float *)right)->val);
				}
			}
			std::cout << "\033[0;31mTypeError: \033[0;0mcannot multiply " << strOfType[left->Type] << " and " << strOfType[right->Type] << "\n";
			std::cout << thisLine->num << " | " << thisLine->self;
			exit(1);
			break;
		case '/':
			if (left->Type == t_int) {
				if (right->Type == t_int) {
					return new Int(((Int *)left)->val / ((Int *)right)->val);
				}
				if (right->Type == t_float) {
					return new Float(((Int *)left)->val / ((Float *)right)->val);
				}
			}
			if (left->Type == t_float) {
				if (right->Type == t_int) {
					return new Float(((Float *)left)->val / ((Int *)right)->val);
				}
				if (right->Type == t_float) {
					return new Float(((Float *)left)->val / ((Float *)right)->val);
				}
			}
			std::cout << "\033[0;31mTypeError: \033[0;0mcannot divide " << strOfType[left->Type] << " and " << strOfType[right->Type] << "\n";
			std::cout << thisLine->num << " | " << thisLine->self;
			exit(1);
			break;
		case '=':
			if (left->Type == t_int) {
				if (right->Type == t_int) {
					return new Bool(((Int *)left)->val == ((Int *)right)->val);
				}
				if (right->Type == t_float) {
					return new Bool(((Int *)left)->val == ((Float *)right)->val);
				}
			}
			if (left->Type == t_float) {
				if (right->Type == t_int) {
					return new Bool(((Float *)left)->val == ((Int *)right)->val);
				}
				if (right->Type == t_float) {
					return new Bool(((Float *)left)->val == ((Float *)right)->val);
				}
			}
			std::cout << "\033[0;31mTypeError: \033[0;0mcannot divide " << strOfType[left->Type] << " and " << strOfType[right->Type] << "\n";
			std::cout << thisLine->num << " | " << thisLine->self;
			exit(1);
			break;
		case '>':
			if (binop->op.size() == 1) {
				if (left->Type == t_int) {
					if (right->Type == t_int) {
						return new Bool(((Int *)left)->val > ((Int *)right)->val);
					}
					if (right->Type == t_float) {
						return new Bool(((Int *)left)->val > ((Float *)right)->val);
					}
				}
				if (left->Type == t_float) {
					if (right->Type == t_int) {
						return new Bool(((Float *)left)->val > ((Int *)right)->val);
					}
					if (right->Type == t_float) {
						return new Bool(((Float *)left)->val > ((Float *)right)->val);
					}
				}
				std::cout << "\033[0;31mTypeError: \033[0;0mcannot compare " << strOfType[left->Type] << " and " << strOfType[right->Type] << "\n";
				std::cout << thisLine->num << " | " << thisLine->self;
				exit(1);
				break;
			}
			else {
				if (left->Type == t_int) {
					if (right->Type == t_int) {
						return new Bool(((Int *)left)->val >= ((Int *)right)->val);
					}
					if (right->Type == t_float) {
						return new Bool((float)((Int *)left)->val >= ((Float *)right)->val);
					}
				}
				if (left->Type == t_float) {
					if (right->Type == t_int) {
						return new Bool(((Float *)left)->val >= (float)((Int *)right)->val);
					}
					if (right->Type == t_float) {
						return new Bool(((Float *)left)->val >= ((Float *)right)->val);
					}
				}
				std::cout << "\033[0;31mTypeError: \033[0;0mcannot compare " << strOfType[left->Type] << " and " << strOfType[right->Type] << "\n";
				std::cout << thisLine->num << " | " << thisLine->self;
				exit(1);
				break;
			}
		case '<':
			if (binop->op.size() == 1) {
				if (left->Type == t_int) {
					if (right->Type == t_int) {
						return new Bool(((Int *)left)->val < ((Int *)right)->val);
					}
					if (right->Type == t_float) {
						return new Bool(((Int *)left)->val < ((Float *)right)->val);
					}
				}
				if (left->Type == t_float) {
					if (right->Type == t_int) {
						return new Bool(((Float *)left)->val < ((Int *)right)->val);
					}
					if (right->Type == t_float) {
						return new Bool(((Float *)left)->val < ((Float *)right)->val);
					}
				}
				std::cout << "\033[0;31mTypeError: \033[0;0mcannot compare " << strOfType[left->Type] << " and " << strOfType[right->Type] << "\n";
				std::cout << thisLine->num << " | " << thisLine->self;
				exit(1);
				break;
			}
			else {
				if (left->Type == t_int) {
					if (right->Type == t_int) {
						return new Bool(((Int *)left)->val <= ((Int *)right)->val);
					}
					if (right->Type == t_float) {
						return new Bool((float)((Int *)left)->val <= ((Float *)right)->val);
					}
				}
				if (left->Type == t_float) {
					if (right->Type == t_int) {
						return new Bool(((Float *)left)->val <= (float)((Int *)right)->val);
					}
					if (right->Type == t_float) {
						return new Bool(((Float *)left)->val <= ((Float *)right)->val);
					}
				}
				std::cout << "\033[0;31mTypeError: \033[0;0mcannot compare " << strOfType[left->Type] << " and " << strOfType[right->Type] << "\n";
				std::cout << thisLine->num << " | " << thisLine->self;
				exit(1);
				break;
			}
		}
	}
	if (expr->isBinOp) {
		BinOp *binop = (BinOp *)expr;
		binop->left = interpretConsts(binop->left, thisLine);
		binop->right = interpretConsts(binop->right, thisLine);
	}
	return expr;
}

inline void interpretConsts(Line *line) {
	switch (line->Type) {
	case t_assign:
		((Assign *)line)->val = interpretConsts(((Assign *)line)->val, line);
		break;
	default:
		break;
	}
}

inline void interpretConsts(Lines *lines) {
	for (int i = 0; i < lines->contents->size(); i++)
		interpretConsts((*lines->contents)[i]);
}
