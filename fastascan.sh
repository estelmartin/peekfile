#how many fasta/fa files are in X folder? 
if [[ -z $1 ]]; then X=$1 ; else X=.; fi

echo The total number of fasta/fa files in X folder is:
fastafiles=$(find $X -type f -name "*.fasta" -or -type f -name "*.fa") 
echo $fastafiles | wc -w

touch fastaIDs 
for file in $fastafiles;
do 
awk '$1~/>/{print $1}' $file >> fastaIDs
done

echo The number of unique fasta IDs is:
sort fastaIDs | uniq | wc -l
