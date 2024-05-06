#include "ast.hpp"

void validate(Expression *expr) {

}

void validate(Line *line) {

}

void validate(Lines *lines) {
    for (int i = 0; i < lines->contents->size(); i++)
        validate((*(lines->contents))[i]);
}