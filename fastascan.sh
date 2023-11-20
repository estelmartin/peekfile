#how many fasta/fa files are in X folder? 
if [[ -z $1 ]]; then X=$1 ; else X=.; fi

echo The total number of fasta/fa files \(and symlinks\) in the folder is:
fastafiles=$(find $X -type f,l -name "*.fasta" -or -type f,l -name "*.fa") 
echo $fastafiles | wc -w
#teh same bash has suggested me to use a comma "," to separate conditions of "type"

touch fastaIDs 
for file in $fastafiles;
do 
awk '$1~/>/{print $1}' $file >> fastaIDs
done

echo The number of unique fasta IDs is:
sort fastaIDs | uniq | wc -l

#for each file
echo Characteristics of each file: 
for file in $fastafiles;
do 
echo $file
if [[ -h $file ]]; then 
	echo The file is a symlink; else
	echo The file is NOT a symlink 
fi
done
