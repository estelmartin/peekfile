#!/usr/bin/env bash

##how many fasta/fa files are in X folder? 
#define the directory
if [[ -z $1 ]]; then X=. ; else X=$1; fi

fastafiles=$(find $X -type f,l -name "*.fasta" -or -type f,l -name "*.fa") 
echo DIRECTORY OVERVIEW:
echo The total number of fasta/fa files \(and symlinks\) in the folder is: $(echo $fastafiles | wc -w)

##count the total number of fasta IDs in the folder
touch fastaIDs 
for file in $fastafiles; do 
awk '$1~/>/{print $1}' $file >> fastaIDs
done

echo The number of unique fasta IDs is: $(sort fastaIDs | uniq | wc -l)
echo "" # empty line to separate 

rm fastaIDs

###inspect the files one by one
echo FILES INFORMATION: 

##loop through each file of the fastafind variable (which contains all the fa/fasta files in that directory) to make a nice header with some file information, followed by (some of) the content of each file
for file in $fastafiles; 
do 

#define a variable called header with the name of the file
header=---\>$file 

	#skip non readable files, for the readable ones do the for loop
if [[ ! -r $file ]]; then echo $header THIS FILE IS NOT READABLE, it will be 	skipped. To make it readable, change permissions \(chmod a+r $file\); echo ""; else 

	#determine if the file is a symlink or not and add this information to the 	variable "header"
	if [[ -h $file ]]; then 
		header=$header$'\t'"| "Symlink; else
		header=$header$'\t'"| "No_simlink
	fi 

	#determine the number of sequences of the file. If we find a binary file, 
	if [[ $(grep -c ">" $file) -eq 0 ]]; then header=$header$'\t'"| ""WARNING! It is not an ordinary file, it is a binary file"; echo $header; echo ""; continue; 
	else header=$header$'\t'"| "Num_Sequences:$(awk '$1~/>/' $file | wc -l); fi

	#determine the total sequences length
	header=$header$'\t'"| "Total_Length:$(awk '!($1~/>/)' $file | grep -io [A-Z] | wc -l )
	
	#determine if the file has nucleotides or amino acids
	if [[ $(awk '!($1~/>/)' $file | grep -io [QWERTYIPASDFGHKLCVNM] | wc -l ) -gt $(awk '!($1~/>/)' $file | grep -io  [ACTGNU] | wc -l ) ]]; then header=$header$'\t'"| "Amino_Acid
	else header=$header$'\t'"| "Nucleotide
	fi 

	#print the "header"
	echo $header

	##content display
	#define the number of lines N
	if [[ -n $2 ]]; then N=$2 ; else N=0; fi

	#display all or part of the content depend on the file length
	if [[ $N -eq 0 ]]; then echo ""; continue
	elif [[ $(cat $file | wc -l) -gt $(($N * 2)) ]]; then 
	head -n $N $file && echo ... && tail -n $N $file; echo ""
	else
	cat $file; echo ""
	fi
	

fi
done
