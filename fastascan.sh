#how many fasta/fa files are in X folder? 
if [[ -z $1 ]]; then X=$1 ; else X=.; fi

fastafiles=$(find $X -type f,l -name "*.fasta" -or -type f,l -name "*.fa") 
echo The total number of fasta/fa files \(and symlinks\) in the folder is: $(echo $fastafiles | wc -w)
#the same bash has suggested me to use a comma "," to separate conditions of "type"

touch fastaIDs 
for file in $fastafiles;
do 
awk '$1~/>/{print $1}' $file >> fastaIDs
done

echo The number of unique fasta IDs is: $(sort fastaIDs | uniq | wc -l)
echo "" # empty line to separate 

rm fastaIDs

#for each file
echo Characteristics of each file: 
for file in $fastafiles;
do 

#define a variable called header with the name of the file

#determine if the file is a symlink or not and add this to the variable
header=--">"$file 
if [[ -h $file ]]; then 
	header=$header$'\t'"| "Symlink; else
	header=$header$'\t'"| "no_simlink
fi 

#determine the number of sequences

if [[ $(grep ">" $file | wc -l) -eq 0 ]]; then header=$header$'\t'"| ""It is not a current file, it is a binary file"; echo $header; echo ""; continue; 
else header=$header$'\t'"| "Num_Sequences:$(awk '$1~/>/' $file | wc -l); fi

#determine the total sequences length
header=$header$'\t'"| "Total_Length:$(awk '!($1~/>/)' $file | tr -d '\n' | sed 's/-//g' | wc -c)

#detemrine if the file is nucleotide or amino acid
if [[ $(awk '!($1~/>/)' $file)==[A,G,T,C] ]]; then header=$header$'\t'"| "Nucleotide
else header=$header$'\t'"| "Amino_acid
fi

echo $header
echo "" #empty line to facilitate visualization
done
