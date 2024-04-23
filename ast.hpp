#include <string>
#include <iostream>
// #include <llvm-12/llvm/IR/Value.h>

class Node
{
public:
    std::string str = "empty node";
};

class Expression : public Node
{
};

class Int : public Expression
{
public:
    int val;
    Int(int val) : val(val) { str = std::to_string(val); }
};
class Float : public Expression
{
public:
    float val;
    Float(float val) : val(val) { str = std::to_string(val); }
};
class String : public Expression
{
public:
    std::string *val;
    String(std::string *val) : val(val) { str = *val; }
};
class Bool : public Expression
{
public:
    bool val;
    Bool(bool val) : val(val) { str = val ? "true" : "false"; }
};
class Var : public Expression
{
public:
    std::string *val;
    Var(std::string *val) : val(val) { str = "{" + *val + "}"; }
};
class BinOp : public Expression
{
public:
    Expression *left, *right;
    char op;
    BinOp(Expression *left, Expression *right, char op) : left(left), right(right), op(op) { str = "(" + left->str + " " + op + " " + right->str + ")"; }
};

class Assign : public Node
{
public:
    std::string *name;
    Expression *val;
    Assign(std::string *name, Expression *val) : name(name), val(val) { str = *name + " = " + val->str; }
};