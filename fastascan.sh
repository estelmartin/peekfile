#how many fasta/fa files are in X folder? 
if [[ -z $1 ]]; then X=$1 ; else X=.; fi

echo The total number of fasta/fa files in X folder is: $(find $X -type f -name "*.fasta" -or -type f -name "*.fa" | wc -l)



