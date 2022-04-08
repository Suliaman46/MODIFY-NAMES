
usage() { 

cat<<EOT 1>&2
Usage: 
 $0 [-r] [-l|-u] <dir/file names>
 $0 [-r] <sed pattern> <dir/file names>
EOT
exit 1;

}

sedValidityCheck() {
	#run sed command on empty string
	# print exit code and message
	sedResult=$(echo "" | sed "$1" 2>&1)
	exitCode=$?
	
	if [ $exitCode == 0 ]; then
		return 0
	else
		echo "Fail, Message:'$sedResult', ErrorCode:'$exitCode'"
	fi  

}

operation() {

	# We check if we the argument is a directory or a file
	if  [ -d "$1" ]; then
		#If it is a directory we check the recursion flag
		
		#If the recursion flag is high we iterate over the file/directories and perform 			#the necessary recursion
		if [ $r == 1 ]; then
			for file in "$1"/* ;do

				operation "$file"
			done
		fi
		
		#After having gone deeper into the directory we come back to change name of the 			#directory itself
		updateName $1
		
		
	elif [ -f "$1" ]; then

		updateName "$1"
	fi
				   
}

updateName() {
	#We isolate the basename from our argument because that is what will attempt to change
	fileName=`basename "$1"`
	#We need the dirname to add it back to our result after applying our upp or low operation
	dirName=`dirname "$1"`
	
	if [ "`realpath $0`" = "`realpath $fileName`" ]; then
		echo "Cannot change name of the program itself"
		
	else
	
		if [ $l == 1 ]; then
			#lowercase
			temp=$(echo "$fileName" | tr 'A-Z' 'a-z')
		elif [ $u == 1 ]; then
			#uppercase
			temp=$(echo "$fileName" | tr 'a-z' 'A-Z')
		else
			#sedPattern
			temp=$(echo "$fileName" | sed "$SEDPATTERN" 2>&1)
		fi
		
		#The temp variable hold the result after we have performed the operation
		#We combine it with dirname to get our potential new  path
		
		result="$dirName/$temp"
		
		#We check if this new name already exists and if not we change the name of our 			#target file or directory
		if [ -f "$result" ] || [ -d "$result" ]; then
			echo "The "$result" name exists"
		else
		mv "$1" "$result"
		echo "Changed from \""$1"\" to \""$result"\" "
		fi
	fi

}


iterator() {

	#We iterate over each argument checking if it's a file or a directory 
	while [ -n "$1" ]; do
	
		if [ -f "$1" ]; then
			#If it's a file then we attempt to update the name
			updateName "$1"
		elif [ -d "$1" ]; then
			#If it's a directory then we go to our function operation which handles 				#directories
			operation "$1" 
		else
			#If neither case is true then the name does not exist and we let the 			#user know
			echo "The file "$1" does not exist"
		fi
		shift
	done

}


r=0;l=0;u=0;

while getopts ":rlu" o; do
    case "${o}" in
        r)
            r=1
            ;;
        l)
            l=1
            ;;
        u)
            u=1
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


if [ $l == 1 ] && [ $u == 1 ]; then
	#Wrong usage of flags by User
    	usage

elif [ $l == 0 ] && [ $u == 0 ]; then
    #THE SED Pattern case

	#We first check that atleast two parameters have been passed 
	if [ $# -ge 2 ]; then
	
	#Now we check the validity of the sed pattern by running it on an empty string
	sedValidityCheck $1
	
	if [ $? == 0 ]; then
		echo "Succesful Sed Validity Check";
		SEDPATTERN="$1"
		shift
		#We figured out the sed pattern and it's validity 
		#Now on to the handling the arguments
		iterator "$@"
	fi
	else
	echo "Not Enough Arguments"
	usage
	fi

elif [ $l == 1 ] || [ $u == 1 ]; then
	# We start handling the arguments
	iterator $@
   
fi




