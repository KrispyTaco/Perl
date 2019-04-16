#This file finds the accuracy of the tagged file compared to the answer key
#This file also contains the confusion matrix
#! /usr/local/bin/perl -w

$text1 = $ARGV[0];	#first command line argument
$text2 = $ARGV[1];	#second command line arg
$count = 0;		#keeps track of how many words are tagged correctly
$total = 0;		#keeps track of how many answers are in the file
%test_file = {};	#
%confusion_matrix = {};	#confusion matrix that contains the predicted value against the expected value
%sense = {};@test;	#array that contains the tested tag words
@golden_key;		#array that contains the golden standard tags
@row_for_table;		#row for the confusion matrix
@column_for_table;	#column for the confusion matrix

use Data::Dumper qw(Dumper);	#used to print out the hash table

open(INPUT_FILE, $text1);	#open file 1

while (<INPUT_FILE>) {		#split the file by the new line and remove extraneous things to match the my answer file to the answer key
	chomp;
	@array = split/\n/;
	foreach $word (@array) {
		$word=~s/>//g;
		$word=~s/\"//g;
		$test_file{$word}++;	#save the answer instance and sense
		
		}	
}

close(INPUT_FILE);	#close the file
	
open(INPUT_FILE2, $text2);
while(<INPUT_FILE2>) {		#split the file by the new line and remove extraneous things ot match the my answer file to the answer key
	chomp;
	@array2 = split/\n/;
	foreach $word2 (@array2) {
		$total++;
		$word2=~s/>//g;
		$word2=~s/\"//g;
		if($word2=~m/senseid=(.*)\//) {
		$sense{$1}++;		#add just the sense to a hash table, which will be used for the confusion matrix
		push(@test, $1);
		}
			if (exists $test_file{$word2}) {	#if the answer file matches the answers in the key, increment the count
				$count++;
			}
			
	}
	for $i (0..$#array2) {
	@golden_key = split/\s/, $array2[$i];	#splits the array by the whitespace
	$golden_tag = @golden_key[$#golden_key]; #adds the last value of the array to the variable $golden_tag, which is always gonna be the sense in this case
		for $i (0..$#test) {		#goes through the test file with answers array
			$test_sense = $test[$i];	#set the sense from the current index
		}
				if ($golden_tag=~m/senseid=(.*)\//) {
		$golden_tag = $1;	#grabs just the sense
		}
			$confusion_matrix{$golden_tag}{$test_sense}++;  #get the occurrences of the expected sense given the predicted sense
			
		
	}
} 
	
close(INPUT_FILE2);
	
print $total2;
$accuracy = ($count/$total)*100;	#calculates the accuracy
print "Amount of words with tags =". " " ."$total\n";
print "Correct tagging =". " " ."$count\n";
printf "Accuracy of tagging program: %.2f%\n" , $accuracy;
print "Confusion matrix: \n";
print "     ";
	foreach $key (keys %sense) {	#goes through all the values in array2
		
		if ($sense{$key} eq undef) {
				delete $sense{$key};
				next;
			}
			push (@row_for_table, $key);  #adds the keys to end of the array
			push (@column_for_table, $key);
		
			print "|$key|";			
	}
	print "\n";
	for $i (0..$#row_for_table) {		#goes through the rows
	print "$row_for_table[$i] | ";		#prints the row for the confusion matrix
	
		for $j (0..$#column_for_table) {	#goes through the columns
			if (exists $confusion_matrix{$row_for_table[$i]}{$column_for_table[$j]}) {	#if there is something in the position of the confusion matrix, print it out
				print $confusion_matrix{$row_for_table[$i]}{$column_for_table[$j]};
			}
			
			else {
				print "0";	#otherwise the value is 0
			}

			print " | ";
		}
		print "\n";
	}#print Dumper \%test_file;