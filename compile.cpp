#include <map>
#include "llvm/IR/IRBuilder.h"
#include "ast.hpp"

std::unique_ptr<llvm::LLVMContext> Context;
//std::unique_ptr<llvm::IRBuilder<>> Builder(nullptr);
std::unique_ptr<llvm::Module> Module;
std::map<std::string, llvm::Value *> Variables;

llvm::Value *Int::codegen() {
    //std::cout << val;
    //llvm::APInt value(val);
    //return llvm::ConstantInt::get(*Context, value);
    return nullptr;
}

llvm::Value *Float::codegen() {
    return llvm::ConstantFP::get(*Context, llvm::APFloat(val));
}

llvm::Value *String::codegen() {
    return nullptr;
}

llvm::Value *Bool::codegen() {
    return nullptr;
}

llvm::Value *Var::codegen() {
    return nullptr;
}

llvm::Value *BinOp::codegen() {
    return nullptr;
}

llvm::Value *List::codegen() {
    return nullptr;
}

llvm::Value *Function::codegen() {
    return nullptr;
}

llvm::Value *Assign::codegen() {
    return nullptr;
}

llvm::Value *If::codegen() {
    return nullptr;
}

llvm::Value *While::codegen() {
    return nullptr;
}