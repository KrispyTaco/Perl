#This file finds the accuracy of the tagged file compared to the golden standard
#This file also contains the confusion matrix
#Accuracy with first attempt without using rules is: 67.02%
#Accuracy with adding first rule is: 69.98%
#Accuracy with adding second rule is : 70.54%
#Accuracy with adding third rule is: 70:96%
#Accuracy with adding fourth rule is: 71.33%
#Accuracy with adding fifth rule is:  71.60%

#! /usr/local/bin/perl -w

$text1 = $ARGV[0];	#first command line argument
$text2 = $ARGV[1];	#second command line arg
$count = 0;		#keeps track of how many words are tagged correctly
$total = 0;		#keeps track of how many words are in the file
%tagged = {};		#hash table that contains the words/tags that were tagged from the test file
%list = {};		#list of tags
%confusion_matrix = {};	#confusion matrix that contains the predicted value against the expected value
@test_key;		#array for storing the keys of the %tagged hash table@test_tag_array;	#array that contains the tested tag words
@golden_key;		#array that contains the golden standard tags
@row_for_table;		#row for the confusion matrix
@column_for_table;	#column for the confusion matrix


use Data::Dumper qw(Dumper);	#used to print out the hash table

open(INPUT_FILE, $text1);	#open file 1

while (<INPUT_FILE>) {
	chomp;
	@test = split/\s+/;
	foreach $words (@test) {	#input the words/tags from the test into the hash table
	$tagged{$words}++;	}
	
}
close(INPUT_FILE);	#close the file

foreach $tag (keys %tagged) {
	push (@test_key, $tag);		#push to the end of the array each tag from the hash table
	}
	
foreach $val (@test_key) {
		if ($val=~m/(.*)(\/)(.*)/) {	#get the tag and assign it to val
			$val = $3;
		}
		push(@test_tag_array, $val);	#push to the end of the array the tag
}
	
open(INPUT_FILE2, $text2);

while (<INPUT_FILE2>) {
	chomp;
	$match = ~s/[\[\]]//g;	#removes the brackets
	@correct = split/\s+/;
	foreach my $word(@correct) {
		$total++;	#gets the total amount of words in the gold standard
		if (exists $tagged{$word}) {	#compares the hash table to the array to see if there exists a key(which is a word/tag) and the current word/tag
			$count++;		#gets the correct amount of tagged words
		}
	}

	for $i (0..$#correct) {
	@golden_key = split/\//, $correct[$i];	#splits the words/tags into just words and tags
	$golden_tag = @golden_key[$#golden_key]; #adds the last value of the array to the variable $golden_tag, which is always gonna be the tag in this case
	$test_tag = $test_tag_array[$i];	#adds the tag from the test_tag_array
		if ($golden_tag=~m/(.*)(\|)(.*)/) {
		$golden_tag = $1;	#grabs the first tag, if there are more than one tags
		}
			$confusion_matrix{$golden_tag}{$test_tag}++;  #get the occurrences of the expected tag given the predicted tag
			$list{$golden_tag}++;  #gets the list of tags
		
	}
}	
close(INPUT_FILE2);
	
$accuracy = ($count/$total)*100;	#calculates the accuracy
print "Amount of words with tags =". " " ."$total\n";
print "Correct tagging =". " " ."$count\n";
printf "Accuracy of tagging program: %.2f%\n" , $accuracy;
print "Confusion matrix: \n";

	foreach $key (keys %list) {	#goes through all the tags
		if ($key=~m/.*/) {
			push (@row_for_table, $key);  #adds the keys to end of the array
			push (@column_for_table, $key);
			print "|$key|";			#print the top row for the tags
		}
	}
		
	for $i (0..$#row_for_table) {		#goes through the rows
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
	}#print Dumper \%confusion_matrix;