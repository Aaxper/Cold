#pragma once
#include <string>
#include <iostream>
#include <vector>
#include <llvm/IR/Value.h>

// Base class for all nodes; will never be used explicitly
class Node {
public:
	// A string representation of the node
	virtual std::string Str() { return "empty node"; }
	// Convert to LLVM's AST
	virtual llvm::Value *codegen() { return nullptr; }
};

// Base class for all expression nodes
class Expression : public Node {
public:
	// Stores whether the value is calculated at compile or run time
	bool isConst = false;
	std::string Str() { return "void"; }
};

// Integer literal
class Int : public Expression {
public:
	int64_t val;
	Int(int val) : val(val) { isConst = true; }
	std::string Str() override { return std::to_string(val); }
	llvm::Value *codegen() override;
};
// Floating point literal
class Float : public Expression {
public:
	float val;
	Float(float val) : val(val) { isConst = true; }
	std::string Str() override { return std::to_string(val); }
	llvm::Value *codegen() override;
};
// String literal
class String : public Expression {
public:
	std::string *val;
	String(std::string *val) : val(val) { isConst = true; }
	std::string Str() override { return *val; }
	llvm::Value *codegen() override;
};
// Boolean literal
class Bool : public Expression {
public:
	bool val;
	Bool(bool val) : val(val) { isConst = true; }
	std::string Str() override { return val ? "true" : "false"; }
	llvm::Value *codegen() override;
};
// An access to a variable
class Var : public Expression {
public:
	std::string *val;
	Var(std::string *val) : val(val) {}
	std::string Str() override { return *val; }
	llvm::Value *codegen() override;
};
// A binary operation on two expression values
class BinOp : public Expression {
public:
	Expression *left, *right;
	std::string op;
	BinOp(Expression *left, Expression *right, std::string op) : left(left), right(right), op(op) { isConst = left->isConst && right->isConst; }
	std::string Str() override { return "(" + left->Str() + " " + op + " " + right->Str() + ")"; }
	llvm::Value *codegen() override;
};

// One line of code and the corresponding indent
class Line : public Node {
public:
	int indent;
	// Used for identifying the indent placement during AST generation by `Lines.AddLine()`
	// Will be 0 for any properly placed line
	int _indent;
	Line(int indent) : indent(indent), _indent(indent) {}
	// Increases both indent and _indent by 1
	void Indent() {
		indent++;
		_indent++;
	}
	// Stores if the current line a container for other lines (if, while, etc)
	bool isBlock = false;
	// Should only be called on certain derived classes (if, while, etc.)
	virtual void AddLine(Line *line) {}
	virtual std::string Str() override { return "empty line"; }
};

// A vector of lines of code
class Lines : public Node {
public:
	std::vector<Line *> *contents;
	Lines(Line *content) : contents(new std::vector<Line *>{ content }) {
		if (!((*contents)[0]))
			contents->pop_back();
	}
	void AddLine(Line *line, int indent = -1) {
		if (line->_indent == 0) {
			line->indent = indent + 1;
			contents->push_back(line);
		}
		else {
			if (contents->back()->isBlock) {
				line->_indent--;
				contents->back()->AddLine(line);
			}
			else {
				std::cout << "\033[0;31mError: \033[0;0msyntax error, unexpected INDENT\n";
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
	Assign(std::string *name, Expression *val, int indent) : name(name), val(val), Line(indent) {}
	std::string Str() override { return std::string(indent, '\t') + *name + " = " + val->Str(); }
	llvm::Value *codegen() override;
};

// A node to store an if statement
class If : public Line {
public:
	// Condition for executing the contents in the if statement
	Expression *cond;
	Lines contents;
	If(Expression *cond, Line *line, int indent) : cond(cond), contents(line), Line(indent) { if (contents.contents->size()) contents.contents->back()->indent++; isBlock = true; }
	void AddLine(Line *line) override { contents.AddLine(line, indent); }
	std::string Str() override { return std::string(indent, '\t') + "if " + cond->Str() + ":\n" + contents.Str(); }
	llvm::Value *codegen() override;
};

// A node to store a while loop
class While : public Line {
public:
	// Condition for executing the contents in the if statement
	Expression *cond;
	Lines contents;
	While(Expression *cond, Line *line, int indent) : cond(cond), contents(line), Line(indent) { if (contents.contents->size()) contents.contents->back()->indent++; isBlock = true; }
	void AddLine(Line *line) override { contents.AddLine(line, indent); }
	std::string Str() override { return std::string(indent, '\t') + "while " + cond->Str() + ":\n" + contents.Str(); }
	llvm::Value *codegen() override;
};