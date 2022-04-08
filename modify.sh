
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
	#echo "recursive called"

	if  [ -d "$1" ]; then

		if [ $r == 1 ]; then
			for file in "$1"/* ;do

				operation "$file"
			done
		fi
		updateName $1
		
		
	elif [ -f "$1" ]; then

		updateName "$1"
	fi
				   
}

updateName() {
	fileName=`basename "$1"`
	dirName=`dirname "$1"`
	
	#echo $fileName
	if [ "$fileName" = "modify.sh" ]; then
		echo "Cannot change name of the program itself"
		
	else
	
		if [ $l == 1 ]; then
			#lowercase "$1"
			temp=$(echo "$fileName" | tr 'A-Z' 'a-z')
		elif [ $u == 1 ]; then
			#uppercase "$1"
			temp=$(echo "$fileName" | tr 'a-z' 'A-Z')
		else
			#sedPattern "$1"
			temp=$(echo "$fileName" | sed "$SEDPATTERN" 2>&1)
		fi
		result="$dirName/$temp"
		if [ -f "$result" ] || [ -d "$result" ]; then
			echo "The "$result" name exists"
		else
		mv "$1" "$result"
		echo "Changed from \""$1"\" to \""$result"\" "
		fi
	fi

}


iterator() {

	while [ -n "$1" ]; do
	
		if [ -f "$1" ]; then
			updateName "$1"
		elif [ -d "$1" ]; then
			operation "$1" 
		else
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
    usage

elif [ $l == 0 ] && [ $u == 0 ]; then
    #THE SED Pattern case
    #echo "Sed"
    if [ $# -ge 2 ]; then
    	sedValidityCheck $1
    	if [ $? == 0 ]; then
    		echo "Succesful Sed Validity Check";
    		SEDPATTERN="$1"
    		shift
    		#Figured out the sed pattern and it's validity 
    		#Now on to the renaming

		iterator "$@"
        fi
    else
    	echo "Not Enough Arguments"
    	usage
    fi

elif [ $l == 1 ] || [ $u == 1 ]; then

	iterator $@
    
else
    echo "lowercase"
fi




