if [[ -z $2 ]] ; then numlines=3 ; else numlines=$2 ; fi 

WC=$( cat $1 | wc -l)
if [[ $WC -le  $(( $numlines * 2 )) ]] ; then cat $1  
else 
	echo warning: too many lines
	head -n $numlines $1 
	echo "..."
	tail -n $numlines $1 
fi
