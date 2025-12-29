#include <iostream>
#include <cstring>

using namespace std;

int main() {
    // well be using fixed size buffers to correcty communicate with asm
    char* buffer = new char[4096];
    cout << "Welcome to the string parser program!\nType help to list avalaible commands." << endl;
    while (true) {
        cout << ">> " << endl;
        // using fgets to read user input
        if (fgets(buffer, 4096, stdin) == NULL) {
            cout << "Internal read error." << endl;
        } else {
            // delete the final \n
            int len = strlen(buffer);
            
        }
    }
    return 0;
}