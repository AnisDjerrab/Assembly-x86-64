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