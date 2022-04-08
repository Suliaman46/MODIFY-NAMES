#!/bin/sh

rm -r testing
mkdir testing
cd testing
mkdir dir1
mkdir dir2
cd dir1
touch file1
touch file2
mkdir dir11
cd dir11
touch file3.txt
cd ../..
cd dir2
touch file4.txt
touch file5.txt
cd ..
mkdir dir3
cd dir3
touch 'file with space'
mkdir emptyDirectory
touch oppexists
touch OPPEXISTS
cd ..

echo "Before any Operation"
ls -R  

#1.
echo "\n 1. Making all of dir1 uppercase recursively - 'modify.sh -r -u dir1' \n"

bash ../modify.sh -r -u dir1
echo "\nAfter Completion"
ls -R


#2. 
echo "\n 2. Making files in dir2 and itself uppercase without recursion - 'modify.sh -u dir2/file4.txt dir2/file5.txt dir2' \n"

bash ../modify.sh -u dir2/file4.txt dir2/file5.txt dir2
echo "\nAfter Completion"

echo "\n 2.1 Please note for this case the order is important and if the user attempted 'modify.sh -u dir2 dir2/file4.txt dir2/file5.txt' the name of the dir2 would first be changed to DIR2 and then the program would not be able to find the files dir2/file4.txt & dir2/file5.txt"
ls -R

#3
echo "\n 3. Recursively making directories DIR1 & DIR2 and everything in them lowercase  - 'modify.sh -r -l DIR1 DIR2' \n"

bash ../modify.sh -r -l DIR1 DIR2
echo "\nAfter Completion"
ls -R

#4
echo "\n 4. Recursively using sed to change names in dir2 - 'modify.sh -r s/file/mile/' \n"

bash ../modify.sh -r s/file/mile/ dir2
echo "\nAfter Completion"
ls -R

#5
echo "\n 5. Attempting to change name but file already exists- 'modify.sh -l dir3/oppexists' \n"

bash ../modify.sh -l dir3/oppexists
echo "\nAfter Completion"
ls -R

#6
echo "\n 6. Attempting to change name but file does not exist- 'modify.sh -l dir3/newFile' \n"

bash ../modify.sh -l dir3/newFile
echo "\nAfter Completion"
ls -R

#7
echo "\n 7. Using sed to change file extensions recursively in the whole root (./) directory- 'modify.sh -r 's/\.txt/\.newext/' ./' \n"

bash ../modify.sh -r 's/\.txt/\.newext/' ./
echo "\nAfter Completion"
ls -R

#8
echo "\n 8. Try to operate on empty directory - '../modify.sh -r -l dir3' \n"

bash ../modify.sh -r -l dir3
echo "\nAfter Completion"
ls -R

#9 
echo "\n 9. Making everything in the root directory uppercase recursively - 'modify.sh -r -u ./' \n"

bash ../modify.sh -r -u ./
echo "\nAfter Completion"
ls -R





