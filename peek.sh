if [[ -z $2 ]] ; then numlines=3 ; else numlines=$2 ; fi 

head -n $numlines $1 
echo "..."
tail -n $numlines $1 

