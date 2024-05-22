#pragma once
#include <typeindex>
#include <typeinfo>
#include <unordered_map>
#include "ast.hpp"

class Object {
    bool isStatic;
    std::unordered_map<std::string, std::type_index> variables;
    std::unordered_map<std::string, Object *> objects;
    std::vector<Assign> body;
};