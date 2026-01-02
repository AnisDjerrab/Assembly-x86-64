## Assembly x86-64
Some quite adavanced Projects I made while learning Assembly x86-64 (amd64)

# Password Manager
A shell with a couple of built-in commands to manage passwords: store them, remove or add them, in addition to a couple of other functionnalities.
```
Usage :
   help : print the utility.
   list : list all passwords and their name.
   delete <--number|-N x>|<--name|-n name_of_the_password> : erase a password entry.
   add <--password|-p max_size_20_Bytes> <-n|--name max_size_40_Bytes> : add a new password entry.
   clear : clears all previously defined passwords.
   set </path/to/file>|<file> : defines the output file.
   date : display creation date.
   q|quit : quit this program.
```

# String Parser
This a quit advanced programming language prototype, with complete parsing, tokenisation, tree creation, and support for nested structures. it's also case-insensitive.
Here, evrything's a string. even numbers. so everything must be '' or " ", and both of them have exactly the same purpose.
```
Usage :
  * basic commands *
   q|quit : quit the program.
   h|help : display this help utility.
  * functions *
   help() => <helpUtility> : returns this help utility string.
   eraseSpaces(<arg>) => <argWithoutSpaces> : remove all spaces from a string.
   down(<arg>) => <argWithAllCaractersDown> : convert all characters to lowercase.
   up(<arg>) => <argWithAllCaractersUp> : convert all characters to uppercase.
   merge(<arg1>, <arg2>) => <mergeArgs> : concatenates two args.
   trim(<arg>) => <argWithoutSpacesAtTheBeginningOrEnd> : remove all spaces at the beginning and end.
   strcmp(<arg1>, <arg2>) => <result> : returns if arg1 is bigger, smaller, or equal, compared to arg2.
   print(<arg>) => <void> : outputs a mesage on the screen.
   input(<args>) => <enteredMessage> : outputs a message on the screen and gets user input.
   newLine() => <newLine> : returns a newline caracter.
   strlen(<arg>) => <lenOfTheArg> : returns the string-converted len of the arg.
   add(<num1>, <num2>) => <sumOfTheTwoNumber> : converts the two numbers in integer, do the addition, and converted the result back.
   sub(<num1>, <num2>) => <num1MinusNum2> : converts the two numbers in integer, do the subtraction, and converted the result back.
   mul(<num1>, <num2>) => <num1MultipliedByNum2> : converts the two numbers in integer, do the multiplication, and converted the result back.
   div(<num1>, <num2>) => <num1DividedByNum2> : converts the two numbers in integer, do the division, and converted the result back.
  * examples *
   >> up(merge('the message entered is : ', input('enter anything : ')))
   >> ADD(strlen ( 'a message' ), sub ( '-12', '14' ) ) 
```
