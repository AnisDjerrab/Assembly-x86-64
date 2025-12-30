#include <iostream>
#include <cstring>
#include <vector>

using namespace std;

// calling the Assembly functions
extern "C" void help();
extern "C" void eraseSpaces(char*);

struct node {
    string name;
    vector<node*> children;
};

int main() {
    // well be using fixed size buffers to correcty communicate with asm
    char* buffer = new char[4096];
    cout << "Welcome to the string parser program!\nType help to list avalaible commands." << endl;
    // now, init the vector that'll have the tokens
    vector<char*>* token = new vector<char*>();
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
                help();
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
            {
                bool hasParenthesis = false;
                int parenthesisCounter = 0;
                bool inApostropheSimple = false;
                bool inApostropheDouble = false;
                int len = strlen(buffer);
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
        }
    }
    delete[] buffer;
    for (char* c : *token) {
        delete[] c;
    }
    delete token;
    return 0;
}