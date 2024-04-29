#include <string>
#include <iostream>
#include <vector>
//#include <llvm/IR/Value.h>

// Base class for all nodes; will never be used explicitly
class Node {
public:
	// A string representation of the node
	virtual std::string Str() { return "empty node"; }
};

// Base class for all expression nodes
class Expression : public Node {
public:
	std::string Str() { return "void"; }
};

// Integer literal
class Int : public Expression {
public:
	int val;
	Int(int val) : val(val) {}
	std::string Str() { return std::to_string(val); }
};
// Floating point literal
class Float : public Expression {
public:
	float val;
	Float(float val) : val(val) {}
	std::string Str() { return std::to_string(val); }
};
// String literal
class String : public Expression {
public:
	std::string *val;
	String(std::string *val) : val(val) {}
	std::string Str() { return *val; }
};
// Boolean literal
class Bool : public Expression {
public:
	bool val;
	Bool(bool val) : val(val) {}
	std::string Str() { return val ? "true" : "false"; }
};
// An access to a variable
class Var : public Expression {
public:
	std::string *val;
	Var(std::string *val) : val(val) {}
	std::string Str() { return *val; }
};
// A binary operation on two expression values
class BinOp : public Expression {
public:
	Expression *left, *right;
	std::string op;
	BinOp(Expression *left, Expression *right, std::string op) : left(left), right(right), op(op) {}
	std::string Str() { return "(" + left->Str() + " " + op + " " + right->Str() + ")"; }
};

// One line of code and the corresponding indent
class Line : public Node {
public:
	int indent;
	// Used for identifying the indent placement during AST generation by `Lines.AddLine()`
	// Will be 0 for any properly placed line
	int _indent;
	Line(int indent) : indent(indent), _indent(indent) {}
	// Stores if the current line a container for other lines (if, while, etc)
	bool isBlock = false;
	// Should only be called on certain derived classes (if, while, etc.)
	virtual void AddLine(Line *line) {}
	virtual std::string Str() { return "empty line"; }
};

// A vector of lines of code
class Lines : public Node {
public:
	std::vector<Line *> contents;
	Lines(Line *contents) : contents(std::vector<Line *>{contents}) {}
	void AddLine(Line *line) {
		if (line->_indent == 0) {
			contents.push_back(line);
		} else {
			if (contents.back()->isBlock) {
				line->_indent--;
				contents.back()->AddLine(line);
			} else {
				std::cout << "\033[0;31mError: \033[0;0msyntax error, unexpected INDENT\n"; exit(1);
			}
		}
	}
	std::string Str() {
		std::string str;
		int len = contents.size();
		// Uncomment the following line if compiling with Clang to prevent a segmentation fault (Why? I have no idea)
		// int USELESS = len;
		if (len > 0) {
			len--;
			str += contents[0]->Str();
		}
		int i;
		while (i < len) {
			i++;
			str += "\n" + contents[i]->Str();
		}
		return str;
	}
};

// Assignment to a variable
class Assign : public Line {
public:
	std::string *name;
	Expression *val;
	Assign(std::string *name, Expression *val, int indent) : name(name), val(val), Line(indent) {}
	std::string Str() { return std::string(indent, '\t') + *name + " = " + val->Str(); }
};

// Node to store an if statement
class If : public Line {
public:
	// Condition for executing the contents in the if statement
	Expression *cond;
	Lines contents;
	If(Expression *cond, Lines contents, int indent) : cond(cond), contents(contents), Line(indent) { isBlock = true; }
	void AddLine(Line *line) { contents.AddLine(line); }
	std::string Str() { return "if " + cond->Str() + " :\n" + contents.Str(); }
};