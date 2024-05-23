#pragma once
#include <typeindex>
#include <typeinfo>
#include <unordered_map>
#include <algorithm>
#include "ast.hpp"
#include <llvm/IR/Value.h>

class Object {
public:
    bool isStatic;
    std::unordered_map<std::string, std::type_index> variables;
    std::unordered_map<std::string, llvm::Value *> values;
    std::unordered_map<std::string, Object *> objects;
    std::vector<Line> body;
};

Object *astToObjectTree(Lines *lines) {
    Object *object;
    for (Line *line : *lines->contents) {
        switch (line->Type) {
        case t_assign:
            if (!object->variables.count(*((Assign *)line)->name)) {}
            break;
        default:
            break;
        }
    }
    return object;
}
