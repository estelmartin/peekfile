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

#loop through each file of the fastafind variable created that contain all the fa/fasta files in that directory, to make a header with some file information, followed by (some of) the content of the file
for file in $fastafiles;
do 

#skip non readable files
if [[ ! -r $file ]]; then echo ---\>$file THIS FILE IS NOT READABLE, it will be skipped. To make it readable, change permissions \(chmod a+r $file\); echo ""; else 

#define a variable called header with the name of the file
header=---\>$file 

#determine if the file is a symlink or not and add this to the variable
if [[ -h $file ]]; then 
	header=$header$'\t'"| "Symlink; else
	header=$header$'\t'"| "no_simlink
fi 

#determine the number of sequences of the file
if [[ $(grep -c ">" $file) -eq 0 ]]; then header=$header$'\t'"| ""WARNING! It is not an ordinary file, it is a binary file"; echo $header; echo ""; continue; 
else header=$header$'\t'"| "Num_Sequences:$(awk '$1~/>/' $file | wc -l); fi

#determine the total sequences length
header=$header$'\t'"| "Total_Length:$(awk '!($1~/>/)' $file | tr -d '\n' | sed 's/-//g' | wc -c)

#determine if the file has nucleotides or amino acids
#if [[ $(awk '!($1~/>/)' $file)==[AGTCNU] ]]; then header=$header$'\t'"| "Nucleotide
#else header=$header$'\t'"| "Amino_acid

#(grep -v 3gAGCT, case insensitive 

#grep -iqE 
if [[ -z $(awk '!($1~/>/)' $file | grep -iqvE [QWERYIPSDFHKLVM"\n"]) ]]; then 
header=$header$'\t'"| "Amino_acid
else header=$header$'\t'"| "Nucleotide
fi 



#print the header
echo $header
#echo "" #empty line to facilitate visualization

#content display
if [[ -z $2 ]]; then N=0 ; else N=$2; fi

if [[ $N -eq 0 ]]; then echo ""; continue
else
if [[ $(cat $file | wc -l) -le $(($N * 2)) ]]; then cat $file; echo ""
elif [[ $(cat $file | wc -l) -gt $(($N * 2)) ]]; then 
head -n $N $file && echo ... && tail -n $N $file
echo ""
fi
fi

fi
done
