#include <iostream>
#include <cstring>
#include <vector>
#include <map>
#include <string>
#include <variant>
#include <cstdlib>

using namespace std;

// calling the Assembly functions
namespace AsmFuncs {
    extern "C" void asm_memcpy(void*, void*, int) asm("memcpy");
    extern "C" char* help();
    extern "C" void eraseSpacesExceptApostrophies(char*);
    extern "C" void eraseSpaces(char*);
    extern "C" void down(char*);
    extern "C" void up(char*);
    extern "C" void print(char*); 
    extern "C" char* merge(char*, char*);
    extern "C" char* input(char*);
    extern "C" char* newLine() asm("nwLine");
    extern "C" char* asm_strlen(char*) asm("strlen_spc");
    extern "C" bool checkNumber(char*);
    extern "C" char* add(char*, char*) asm("Addition");
    extern "C" char* sub(char*, char*) asm("Subtraction");
    extern "C" char* mul(char*, char*) asm("Multiplication");
    extern "C" char* asm_div(char*, char*) asm("Division");
    extern "C" void trim(char*);
    extern "C" char* asm_strcmp(char*, char*);
}

struct node {
    string name;
    vector<variant<node*, char*>> children;
    ~node() {}
};


void freeMemoryVector(vector<char*>& vec) {
    for (char* c : vec) {
        if (c != nullptr) {
            free(c);
            c = nullptr;
        }
    }
}

void freeMemoryVectorExcept(vector<char*>& vec, int index) {
    for (int i = 0; i < vec.size(); i++) {
        if (i != index) {
            if (vec[i] != nullptr) {    
                free(vec[i]);
                vec[i] = nullptr;
            }
        }
    }
}

void clearChildren(node* head) {
    for (int i = 0; i < head->children.size(); i++) {
        if (holds_alternative<char*>(head->children[i])) {
            free(get<char*>(head->children[i]));
            get<char*>(head->children[i]) = nullptr;
        } else if (holds_alternative<node*>(head->children[i])) {
            clearChildren(get<node*>(head->children[i]));
        }
    }
    delete head;
    head = nullptr;
}
node* createTheTree(vector<char*>* tokens, map<string, int>& map, int& index) {
    string element = string(tokens->at(index));
    auto found = map.find(element);
    if (found != map.end()) {
        int NumberOfArgs = map[element];
        if ((index+NumberOfArgs+2) >= tokens->size()) {
            cout << "error : invalid function declaration : " << tokens->at(index) << endl;
            return nullptr;
        }
        if (!(strcmp(tokens->at(index + 1), "(") == 0)) {
            cout << "error : invalid function declaration : " << tokens->at(index) << endl;
            return nullptr;
        }
        index++;
        index++;
        vector<variant<node*, char*>> children;
        for (int o = 0; o < NumberOfArgs; o++) {
            if (strlen(tokens->at(index)) == 0) {
                cout << "error : invalid token size." << endl;
                return nullptr;
            } 
            if (tokens->at(index)[0] == '"' || tokens->at(index)[0] == '\'') {
                int tokenLen = strlen(tokens->at(index));
                if (tokenLen < 2) {
                    cout << "error : invalid arg size." << endl;
                    return nullptr;
                }
                char* arg = (char*)malloc(tokenLen - 1);
                AsmFuncs::asm_memcpy(arg, tokens->at(index) + 1, tokenLen - 2);
                arg[tokenLen - 2] = 0;
                children.push_back(arg);
                index++;
            } else if (!(strcmp(tokens->at(index), ",") == 0)) {
                node* arg = createTheTree(tokens, map, index);
                if (arg == nullptr) {
                    for (int i = 0; i < children.size(); i++) {
                        if (holds_alternative<char*>(children[i])) {
                            delete[] get<char*>(children[i]);
                            get<char*>(children[i]) = nullptr;
                        } else if (holds_alternative<node*>(children[i])) {
                            clearChildren(get<node*>(children[i]));
                        }
                    }
                    return nullptr;
                }      
                index++;
                children.push_back(arg);  
            } else {
                NumberOfArgs++;
                index++;
            }
        }
        if (!(strcmp(tokens->at(index), ")") == 0)) {
            cout << "error : function not ended." << endl;
            return nullptr;
        }
        node* n = new node();
        n->name = element;
        n->children = children;
        return n;
    } else {
        cout << "error : unknown command : " << tokens->at(index) << endl;
    }
    return nullptr;
}
char* executeCode(node* head, map<string, int>& map) {
    vector<char*> args;
    for (int i = 0; i < head->children.size(); i++) {
        char* element;
        if (holds_alternative<char*>(head->children[i])) {
            element = (char*)malloc(strlen(get<char*>(head->children[i])) + 1);
            strcpy(element, get<char*>(head->children[i]));
            args.push_back(element);
        } else if (holds_alternative<node*>(head->children[i])) {
            element = executeCode(get<node*>(head->children[i]), map);
            if (element == nullptr) {
                freeMemoryVector(args);
                return nullptr;
            }
            args.push_back(element);
        }
    }
    // now, execute code and return an output
    int NumberOfArgsRequired = map[head->name];
    if (NumberOfArgsRequired != args.size()) {
        cout << "error : invalid number of arguments in function : " << head->name << endl;
        freeMemoryVector(args);
        return nullptr;
    }
    if (head->name == "help") {
        char* helpMessage = AsmFuncs::help();
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return helpMessage;
    } else if (head->name == "erasespaces") {
        AsmFuncs::eraseSpaces(args[0]);
        freeMemoryVectorExcept(args, 0);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return args[0];
    } else if (head->name == "down") {
        AsmFuncs::down(args[0]);
        freeMemoryVectorExcept(args, 0);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return args[0];
    } else if (head->name == "print") {
        AsmFuncs::print(args[0]);
        freeMemoryVector(args);
        char* returnChar = (char*)malloc(1);
        returnChar[0] = 0;
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return returnChar;
    } else if (head->name == "merge") {
        char* output = AsmFuncs::merge(args[0], args[1]);
        freeMemoryVector(args);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return output;
    } else if (head->name == "input") {
        char* output = AsmFuncs::input(args[0]);
        freeMemoryVector(args);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return output;
    } else if (head->name == "newline") {
        char* output = AsmFuncs::newLine();
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return output;
    } else if (head->name == "strlen") {
        char* output = AsmFuncs::asm_strlen(args[0]);
        freeMemoryVector(args);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return output;
    } else if (head->name == "up") {
        AsmFuncs::up(args[0]);
        freeMemoryVectorExcept(args, 0);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return args[0];
    } else if (head->name == "add") {
        AsmFuncs::trim(args[0]);
        AsmFuncs::trim(args[1]);
        if (!(AsmFuncs::checkNumber(args[0]) && AsmFuncs::checkNumber(args[1]))) {
            cout << "error : invalid number." << endl;
            freeMemoryVector(args);
            return nullptr;
        }
        char* output = AsmFuncs::add(args[0], args[1]);
        freeMemoryVector(args);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return output;
    } else if (head->name == "trim") {
        AsmFuncs::trim(args[0]);
        freeMemoryVectorExcept(args, 0);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return args[0];
    } else if (head->name == "sub") {
        AsmFuncs::trim(args[0]);
        AsmFuncs::trim(args[1]);
        if (!(AsmFuncs::checkNumber(args[0]) && AsmFuncs::checkNumber(args[1]))) {
            cout << "error : invalid number." << endl;
            freeMemoryVector(args);
            return nullptr;
        }
        char* output = AsmFuncs::sub(args[0], args[1]);
        freeMemoryVector(args);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return output;
    } else if (head->name == "mul") {
        AsmFuncs::trim(args[0]);
        AsmFuncs::trim(args[1]);
        if (!(AsmFuncs::checkNumber(args[0]) && AsmFuncs::checkNumber(args[1]))) {
            cout << "error : invalid number." << endl;
            freeMemoryVector(args);
            return nullptr;
        }
        char* output = AsmFuncs::mul(args[0], args[1]);
        freeMemoryVector(args);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return output;
    } else if (head->name == "div") {
        AsmFuncs::trim(args[0]);
        AsmFuncs::trim(args[1]);
        if (!(AsmFuncs::checkNumber(args[0]) && AsmFuncs::checkNumber(args[1]))) {
            cout << "error : invalid number." << endl;
            freeMemoryVector(args);
            return nullptr;
        }
        char* output = AsmFuncs::asm_div(args[0], args[1]);
        freeMemoryVector(args);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return output;
    } else if (head->name == "strcmp") {
        cout << args[0] << endl;
        cout << args[1] << endl;
        cout.flush();
        char* output = AsmFuncs::asm_strcmp(args[0], args[1]);
        freeMemoryVector(args);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return output;
    } else {
        cout << "error : unknown command : " << head->name << endl;
        freeMemoryVector(args);
        if (head != nullptr) {
            delete head;
            head = nullptr;
        }
        return nullptr;
    }
    freeMemoryVector(args);
    if (head != nullptr) {
        delete head;
        head = nullptr;
    }
    return nullptr;
}


int main() {
    // well be using fixed size buffers to correcty communicate with asm
    char* buffer = new char[4096];
    cout << "Welcome to the string parser program!\nType help to list avalaible commands." << endl;
    // now, init the vector that'll have the tokens
    vector<char*>* tokens = new vector<char*>();
    map<string, int> allowedCommands = {
        {"help", 0},
        {"down", 1}, 
        {"erasespaces", 1},
        {"print", 1},
        {"merge", 2},
        {"input", 1}, 
        {"newline", 0},
        {"strlen", 1},
        {"up", 1},
        {"add", 2},
        {"trim", 1},
        {"sub", 2},
        {"mul", 2},
        {"div", 2},
        {"strcmp", 2}
    };
    while (true) {
    ReadLoop:
        cout << ">> ";
        cout.flush();
        // using fgets to read user input
        if (fgets(buffer, 4096, stdin) == NULL) {
            cout << "Internal read error." << endl;
        } else {
            // delete the final \n
            int len = strlen(buffer);
            if (len < 4095 && len > 0) {
                len -= 1;
                buffer[len] = '\0';
            }
            // check if the command is empty
            if (len == 0) {
                goto ReadLoop;
            }
            // check basic commands
            if (strcmp(buffer, "help") == 0) {
                char* helpMessage = AsmFuncs::help();
                AsmFuncs::print(helpMessage);
                if (helpMessage != nullptr) {
                    free(helpMessage);
                    helpMessage = nullptr;
                }
                goto ReadLoop;
            }
            if (strcmp(buffer, "h") == 0) {
                char* helpMessage = AsmFuncs::help();
                AsmFuncs::print(helpMessage);
                if (helpMessage != nullptr) {
                    free(helpMessage);
                    helpMessage = nullptr;
                }
                goto ReadLoop;
            }
            if (strcmp(buffer, "quit") == 0) {
                break;
            }
            if (strcmp(buffer, "q") == 0) {
                break; 
            }
            // now, parse it to get the real set of commands
            // first : get rid of all the spaces 
            AsmFuncs::eraseSpacesExceptApostrophies(buffer);
            // now, check the potential syntax errors
            bool error = false;
            len = strlen(buffer);
            {
                bool hasParenthesis = false;
                int parenthesisCounter = 0;
                bool inApostropheSimple = false;
                bool inApostropheDouble = false;
                for (int i = 0; i < len; i++) {
                    if (buffer[i] == '(') {
                        if (!(inApostropheSimple || inApostropheDouble)) {
                            parenthesisCounter++;
                            hasParenthesis = true;
                        }
                    } else if (buffer[i] == ')') {
                        if (!(inApostropheSimple || inApostropheDouble)) {
                            parenthesisCounter--;
                        }
                    } else if (buffer[i] == '\"') {
                        if (!(inApostropheSimple)) {
                            inApostropheDouble ^= 1;
                        }
                    } else if (buffer[i] == '\'') {
                        if (!(inApostropheDouble)) {
                            inApostropheSimple ^= 1;
                        }
                    } else if (buffer[i] == ',') {
                        if (!(inApostropheSimple || inApostropheDouble)) {
                            if (i == len - 1) {
                                cout << "error : misplaced comma." << endl;
                                error = true;
                                break;
                            } 
                        }
                    } else if (!((buffer[i] >= 'a' && buffer[i] <= 'z') || (buffer[i] >= 'A' && buffer[i] <= 'Z'))) {
                        if (!(inApostropheSimple || inApostropheDouble)) {
                            cout << "error : invalid caracter : " << buffer[i] << endl;
                            error = true;
                            break;
                        }
                    }
                }
                if (inApostropheSimple || inApostropheDouble) {
                    cout << "error : invalid apostrophe closing." << endl;
                    error = true;
                }
                if (parenthesisCounter != 0) {
                    cout << "error : invalid parenthesis closing." << endl;
                    error = true;
                }
                if (!(hasParenthesis)) {
                    cout << "error : no parenthesis present." << endl;
                    error = true;
                }
            }
            if (error) {
                goto ReadLoop;
            }
            // now, tokenise it
            tokens->clear();
            {
                bool inElement = false;
                bool inApostropheSimple = false;
                bool inApostropheDouble = false;
                int indexInElement = 0;
                int max_size;
                char* token;
                for (int i = 0; i < len; i++) {
                    if (buffer[i] == ',') {
                        if (!(inApostropheSimple || inApostropheDouble)) {
                            // check a couple of thing
                            if (i == 0) {
                                cout << "error : invalid comma position." << endl;
                                error = true;
                                break;
                            }
                            if (!(buffer[i - 1] == '\'' || buffer[i - 1] == '"' || buffer[i - 1] == ')')) {
                                cout << "error : invalid comma position." << endl;
                                error = true;
                                break;
                            }
                            // add terminaison '\0'
                            if (inElement) {
                                AsmFuncs::down(token);
                                token[indexInElement] = 0;
                                tokens->push_back(token);
                                inElement = false; 
                                indexInElement = 0;
                            }
                            token = new char[2];
                            token[0] = buffer[i];
                            token[1] = 0;
                            tokens->push_back(token);
                            indexInElement = 0;
                        }  else {
                            token[indexInElement] = buffer[i];
                            indexInElement++;
                        }
                    } else if (buffer[i] == '(') {
                        if (!(inApostropheSimple || inApostropheDouble)) { 
                            // check that what's before is expected
                            if (i == 0) {
                                cout << "error : invalid parenthesis position." << endl;
                                error = true;
                                break;
                            }
                            if (token[0] == '\'' || token[0] == '"' || buffer[i - 1] == '(' || buffer[i - 1] == ')' || buffer[i - 1] == ',') {
                                cout << "error : invalid parenthesis position or closing." << endl;
                                error = true;
                                break;
                            }
                            // add terminaison '\0'
                            if (inElement) {
                                AsmFuncs::down(token);
                                token[indexInElement] = 0;
                                tokens->push_back(token);
                                inElement = false; 
                                indexInElement = 0;
                            }
                            token = new char[2];
                            token[0] = buffer[i];
                            token[1] = 0;
                            tokens->push_back(token);
                            indexInElement = 0;
                        }  else {
                            token[indexInElement] = buffer[i];
                            indexInElement++;
                        }
                    } else if (buffer[i] == ')') {
                        if (!(inApostropheSimple || inApostropheDouble)) {
                            // check if what was before is according to the rules
                            if (i == 0) {
                                cout << "error : invalid parenthesis position." << endl;
                                error = true;
                                break;
                            }
                            if (!(token[0] == '\'' || token[0] == '"' || buffer[i - 1] == '(' || buffer[i - 1] == ')')) {
                                cout << "error : invalid parenthesis position or closing." << endl;
                                error = true;
                                break;
                            }
                            // add terminaison '\0'
                            if (inElement) {
                                AsmFuncs::down(token);
                                token[indexInElement] = 0;
                                tokens->push_back(token);
                                inElement = false; 
                                indexInElement = 0;
                            }
                            token = new char[2];
                            token[0] = buffer[i];
                            token[1] = 0;
                            tokens->push_back(token);
                            indexInElement = 0;
                        }  else {
                            token[indexInElement] = buffer[i];
                            indexInElement++;
                        }
                    } else if (buffer[i] == '\'') {
                        if (!(inApostropheDouble)) {
                            if (inApostropheSimple) {
                                if (!inElement) {
                                    error = true;
                                    cout << "error : parsing problem occured." << endl;
                                }
                                inApostropheSimple = false;
                                token[indexInElement] = '\'';
                                indexInElement++;
                                token[indexInElement] = 0;
                                tokens->push_back(token);
                                inElement = false;
                            } else {
                                if (inElement) {
                                    error = true;
                                    cout << "error : parsing problem occured." << endl;
                                }
                                inApostropheSimple = true;
                                max_size = 1;
                                for (int o = i + 1; o < len; o++) {
                                    max_size += 1;
                                    if (buffer[o] == '\'') {
                                        break;
                                    }
                                }
                                token = new char[max_size + 1];
                                inElement = true;
                                token[0] = '\'';
                                indexInElement = 1;
                            }
                        } else {
                            token[indexInElement] = buffer[i];
                            indexInElement++;
                        }
                    } else if (buffer[i] == '\"') {
                        if (!(inApostropheSimple)) {
                            if (inApostropheDouble) {
                                if (!inElement) {
                                    error = true;
                                    cout << "error : parsing problem occured." << endl;
                                }
                                inApostropheDouble = false;
                                token[indexInElement] = '\"';
                                indexInElement++;
                                token[indexInElement] = 0;
                                tokens->push_back(token);
                                inElement = false;
                            } else {
                                if (inElement) {
                                    error = true;
                                    cout << "error : parsing problem occured." << endl;
                                }
                                inApostropheDouble = true;
                                max_size = 1;
                                for (int o = i + 1; o < len; o++) {
                                    max_size += 1;
                                    if (buffer[o] == '\"') {
                                        break;
                                    }
                                }
                                token = new char[max_size + 1];
                                inElement = true;
                                token[0] = '\"';
                                indexInElement = 1;
                            }
                        } else {
                            token[indexInElement] = buffer[i];
                            indexInElement++;
                        }
                    } else {
                        if (inElement) {
                            token[indexInElement] = buffer[i];
                            indexInElement++; 
                        } else {
                            inElement = true;
                            max_size = 1;
                            for (int o = i; o < len; o++) {
                                max_size += 1;
                                if (buffer[o] == '\"' || buffer[o] == '\'' || buffer[o] == '(' || buffer[o] == ')' || buffer[o] == ',') {
                                    break;
                                } 
                            }
                            token = new char[max_size + 1];
                            indexInElement = 0;
                            token[indexInElement] = buffer[i];
                            indexInElement++;
                        }
                    }
                }
            }
            if (error) {
                goto ReadLoop;
            }
            // now, create the tree
            int index = 0;
            node* head = createTheTree(tokens, allowedCommands, index);
            for (char* c : *tokens) {
                if (c != nullptr) {
                    delete[] c;
                    c = nullptr;
                }
            }
            if (head != nullptr) {
                // finally... well, execute the code!
                char* output = executeCode(head, allowedCommands);
                AsmFuncs::print(output);
                if (output != nullptr) {
                    free(output);
                    output = nullptr;
                }
            } else {
                cout << "error : failed to create the tree." << endl;
            }
        }
    }
    if (buffer != nullptr) {
        delete[] buffer;
        buffer = nullptr;
    }
    if (tokens != nullptr) {
        delete tokens;
        tokens = nullptr;
    }
    return 0;
}
