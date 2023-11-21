#how many fasta/fa files are in X folder? 
if [[ -z $1 ]]; then X=. ; else X=$1; fi

fastafiles=$(find $X -type f,l -name "*.fasta" -or -type f,l -name "*.fa") 
echo DIRECTORY OVERVIEW:
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


echo FILES INFORMATION: 

#FOR EACH FILE
for file in $fastafiles;
do 

if [[ ! -r $file ]]; then echo --\>$file THIS FILE IS NOT READABLE, it will be skipped. To make it readable, change permissions \(chmod a+r $file\); echo ""; else 
#define a variable called header with the name of the file
header=--">"$file 
#determine if the file is a symlink or not and add this to the variable
if [[ -h $file ]]; then 
	header=$header$'\t'"| "Symlink; else
	header=$header$'\t'"| "no_simlink
fi 

#determine the number of sequences

if [[ $(grep -c ">" $file) -eq 0 ]]; then header=$header$'\t'"| ""WARNING! It is not a current file, it is a binary file"; echo $header; echo ""; continue; 
else header=$header$'\t'"| "Num_Sequences:$(awk '$1~/>/' $file | wc -l); fi

#determine the total sequences length
header=$header$'\t'"| "Total_Length:$(awk '!($1~/>/)' $file | tr -d '\n' | sed 's/-//g' | wc -c)

#determine if the file has nucleotides or amino acids
if [[ $(awk '!($1~/>/)' $file)==[AGTCNU] ]]; then header=$header$'\t'"| "Nucleotide
else header=$header$'\t'"| "Amino_acid
fi

#content display
if [[ -z $2 ]]; then N=0 ; else N=$2; fi

echo $header
echo "" #empty line to facilitate visualization

if [[ $(cat $file | wc -l) -le $(($N * 2)) ]]; then cat $file; echo ""
elif [[ $(cat $file | wc -l) -gt $(($N * 2)) ]]; then 
head -n $N $file
echo ...
tail -n $N $file
echo ""
elif [[ $N -eq 0 ]]; then continue
fi

fi
done
