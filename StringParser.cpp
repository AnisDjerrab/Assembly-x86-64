#include <iostream>
#include <cstring>
#include <vector>
#include <map>
#include <string>
#include <variant>

using namespace std;

// calling the Assembly functions
extern "C" char* help();
extern "C" void eraseSpaces(char*);
extern "C" void down(char*); 

struct node {
    string name;
    vector<variant<node*, char*>> children;
};


node* createTheTree(vector<char*>* tokens, map<string, int>& map, int& index) {
    for (int i = index; i < tokens->size(); i++) {
        index++;
        string element = string(tokens->at(i));
        auto found = map.find(element);
        if (found != map.end()) {
            int NumberOfArgs = map[element];
            if ((i+NumberOfArgs+2) >= tokens->size()) {
                cout << "error : invalid function declaration : " << tokens->at(i) << endl;
                return nullptr;
            }
            if (!(strcmp(tokens->at(i + 1), "(") == 0)) {
                cout << "error : invalid function declaration : " << tokens->at(i) << endl;
                return nullptr;
            }
            i++;
            index++;
            i++;
            index++;
            vector<variant<node*, char*>> children;
            for (int o = 0; o < NumberOfArgs; o++) {
                if (strlen(tokens->at(i)) == 0) {
                    cout << "error : invalid token size." << endl;
                    return nullptr;
                } 
                if (strcmp(tokens->at(i), "\"") == 0 || strcmp(tokens->at(i), "\'") == 0) {
                    char* arg = new char[strlen(tokens->at(i)) + 1];
                    strcpy(arg, tokens->at(i));
                    children.push_back(arg);
                    if (i != NumberOfArgs - 1) {
                        o++;
                        i++;
                        index++;
                    }
                }
                if (!(strcmp(tokens->at(i), ",") == 0)) {
                    node* arg = createTheTree(tokens, map, index);
                    if (arg == nullptr) {
                        return nullptr;
                    }        
                } 
                index++;
                i++;
            }
            if (!(strcmp(tokens->at(i), ")") == 0)) {
                cout << "error : function not ended." << endl;
                return nullptr;
            }
            node* n = new node();
            n->name = element;
            n->children = children;
            return n;
        } else {
            cout << "error : unknown standart function : " << tokens->at(i) << endl;
            return nullptr;
        }
        index++;
    }
}
char* executeCode(node* head, map<string, int>& map) {
    vector<char*> args;
    for (int i = 0; i < head->children.size(); i++) {
        char* element;
        if (holds_alternative<char*>(head->children[i])) {
            element = new char[strlen(get<char*>(head->children[i])) + 1];
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
        char* helpMessage = help();
        return helpMessage;
    } else if (head->name == "eraseSpaces") {
        eraseSpaces(args[0]);
        freeMemoryVectorExcept(args, 0);
        return args[0];
    } else if (head->name == "down") {
        eraseSpaces(args[0]);
        freeMemoryVectorExcept(args, 0);
        return args[0];
    } else {
        cout << "error : unknown command : " << head->name << endl;
        freeMemoryVector(args);
        return nullptr;
    }
    freeMemoryVector(args);
    return nullptr;
}

void freeMemoryVector(vector<char*>& vec) {
    for (char* c : vec) {
        delete[] c;
    }
}

void freeMemoryVectorExcept(vector<char*>& vec, int index) {
    for (int i = 0; i < vec.size(); i++) {
        if (i != index) {
            delete[] vec[i];
        }
    }
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
        {"eraseSpaces", 1}
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
            if (len < 4095) {
                len -= 1;
                buffer[len] = '\0';
            }
            // check basic commands
            if (strcmp(buffer, "help") == 0) {
                char* helpMessage = help();
                printf(helpMessage);
                free(helpMessage);
                goto ReadLoop;
            }
            if (strcmp(buffer, "h") == 0) {
                char* helpMessage = help();
                printf(helpMessage);
                free(helpMessage);
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
            eraseSpaces(buffer);
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
                            } else if (buffer[i + 1] != '\"' && buffer[i + 1] != '\'') {
                                cout << "error : invalid caracter after comma : " << buffer[i + 1] << endl;
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
                    if (buffer[i] == '(' || buffer[i] == ')' || buffer[i] == ',') {
                        if (!(inApostropheSimple || inApostropheDouble)) {
                            // add terminaison '\0'
                            if (inElement) {
                                down(token);
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
                                if (indexInElement > 2) {
                                    token[indexInElement] = 0;
                                    tokens->push_back(token);
                                }
                                inElement = false;
                            } else {
                                if (inElement) {
                                    error = true;
                                    cout << "error : parsing problem occured." << endl;
                                }
                                inApostropheSimple = true;
                                max_size = 0;
                                for (int o = i; o < len; o++) {
                                    max_size += 1;
                                    if (buffer[o] == '\'') {
                                        break;
                                    }
                                }
                                token = new char[max_size];
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
                                if (indexInElement > 2) {
                                    token[indexInElement] = 0;
                                    tokens->push_back(token);
                                }
                                inElement = false;
                            } else {
                                if (inElement) {
                                    error = true;
                                    cout << "error : parsing problem occured." << endl;
                                }
                                inApostropheDouble = true;
                                max_size = 0;
                                for (int o = i; o < len; o++) {
                                    max_size += 1;
                                    if (buffer[o] == '\"') {
                                        break;
                                    }
                                }
                                token = new char[max_size];
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
                            max_size = 0;
                            for (int o = i; o < len; o++) {
                                max_size += 1;
                                if (buffer[o] == '\"' || buffer[o] == '\'' || buffer[o] == '(' || buffer[o] == ')' || buffer[o] == ',') {
                                    break;
                                } 
                            }
                            token = new char[max_size];
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
            for (int i = 0; i < tokens->size(); i++) {
                cout << tokens->at(i) << endl;
            }
            // now, create the tree
            int index = 0;
            node* head = createTheTree(tokens, allowedCommands, index);
            // finally... well, execute the code!
        }
    }
    delete[] buffer;
    for (char* c : *tokens) {
        delete[] c;
    }
    delete tokens;
    return 0;
}
