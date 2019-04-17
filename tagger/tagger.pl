#Andy Huynh 03/16/18
#This program was created to tag the "most likely tag" baseline for a given word by 
#using training data that the program learns and then compares the results with a manually tagged solution.
#Finding th most likely tag baseline would give us a general idea of what the part of speach of a word could be.
#Example of inputs to put into the program:
#perl tagger.pl pos-train.txt pos-test.txt>>result.txt
#this takes in command line arguments, it takes it in the format of perl (tells the terminal that it is
#perl file), program name (tagger.pl is the file in this case), txt file 1 (this is the training data that the program will learn all the parts of speech), 
#txt file 2 (this is where the file will tag all the words based on the most frequently occurred tag for that given word), 
#and output txt file (this is the file that will have the output of the tagged words)
#The alogrithm used was given as follows: first read in the training file
#create a hash of hashes, and put the words as keys, and the tags the second pair of keys, as the value, you would put
#the amount of times that tag had occurred given the word.
#the frequency was then found by dividing by the given word, for each pair of words and tags.
#The most occuring tag was then found by comparing the values of each word key.
#Then the most occuring tag with its word is placed into another hash table.
#The second file is read in, put into an array, then searched through the most occurring 
#tag hash table to see if the word exists in the array.  If it does then the tag associated with the word key
#is the tag in the second file and will be printed as such.
#if the word does not exist in the training file but in the test file, the word will automatically be considered a noun (NN).
#After all the words have been tagged, it is outputted to a file.  This new file will be compared to the gold standard file
#which is a file that has manually tagged tags of words.
#The file scorer.pl was created to compare the files and calculate the accuracy.
#In the algorithm for scorer.pl each word and tag has been compared, if it is shown that 
#they are the same, a counter for the amount correct is incremented.
#Also all the words in gold standard file was counted.
#The accuracy of the tagging was found by the formula "(correct / total amount of words) * 100".
#Once the first round of calculating the accuracy, the confusion matrix was created.
#This showed where most of the problems lies with the inaccuracies by comparing the predicted values with the expected values
#5 rules were created to increase the accuracy, which are showned in this program below and in the scorer file
#The accuracy from each rule and before were labeled.

#! /usr/local/bin/perl -w

$text1 = $ARGV[0];	#takes in command line argument
$text2 = $ARGV[1];
%freq = {}; 		#hash of hashes for calculating the frequencies
%w_occur = {};		#amount of times the word occurs is put into this hash table
%tagged = {};		#contains the most likely tagged tag and its given word

use Data::Dumper qw(Dumper);	#used to print out the hash table to see if all is correct

open(INPUT_FILE, $text1);	#opens the text file

while (<INPUT_FILE>) {
	chomp;			#removes new line
	@array = split/\s+/;	#split each word based on white space
	foreach $word (@array) {
		$word=~s/[\[\]]//g;	#removes the brackets
		$word=~s/\s+//g;	#split on white space again
		if($word=~m/(.*)(\/)(.*)/) {	#regex for splitting the word and the tag
		$freq{$1}{$3}++;		#take in the word as key1 and tag as key 2 and increment the amount of times it is seen
		$w_occur{$1}++;			#take in the word and see how many times it occurs
		}
	}
}
close(INPUT_FILE);		#closes the file

foreach $key (keys %freq) {		#go through first part of hash table
	foreach $value (keys %{$freq{$key}}) {	#goes through second part of hash table
		$float = ($freq{$key}{$value})/($w_occur{$key});	#calculate the probability of the tag occurence
		$freq{$key}{$value} = $float;				#assign it the calculated value
	}
}	

foreach $key (keys %freq) {
	$max = 0;		#every iteration, reset max value to 0
	while (my($tag, $value) = each %{ $freq{$key}}) {	#goes through each value of the hash of hashes
		if ($value == 1) {				#if value = 1, then that is the only tag occurence, return it
			$tagged{$key} = $tag;
		}
		else {
			if ($value > $max) {		#if occurence of tag is higher than max value assign it to the new max value
				$max = $value;
				$tags = $tag;		#$tags is used to save the value of the tag with the higher max value for this iteration
				$tagged{$key} = $tags;	#assigns or replaces the value for the key in the hash table
				}
			}
		}
	}

open(INPUT_FILE2, $text2);	#reads second file

while (<INPUT_FILE2>) {
	chomp;			#removes new line
	@array2 = split/\s+/;		#split based on white spaces
	foreach my $words(@array2) {
		$words=~s/[\[\]]//g;	#take out brackets
		$temp = "/NN";		#All words are considered NN at first
		if (exists $tagged{$words}) {		#if word/tag from output file is in the key, then go through loop
			if ($tagged{$words} eq "NN") {		#if it is a noun
				if ($words=~m/([A-Z][A-Za-z]+)|(A-Z)+/) {	 #Rule 1, if word is a noun and has a capital letter or an acronym, it is a proper noun.
					$temp = "/NNP";
				}
			}
			
			elsif ($words=~m/^[0-9]+.*/) {		#Rule 2, anything that has numbers is a cardinal number
			$temp = "/CD";
		}
		
			elsif ($words=~m/(\w+-\w+((-\w+)*))/) {  #Rule 3, anything with a hyphen is an adjective
				$temp = "/JJ";
			}
		
			elsif ($words=~m/.*d\b/) {		#Rule 4, anything that ends in "d" is a past tense verb.
				$temp = "/VBD";
			}
		
			elsif ($words=~m/.*ing\b/) {		#Rule 5, anything that ends in "ing" is a gerund or present participle
				$temp = "/VBG";
			}
			
			else {
				$temp = "/$tagged{$words}";	#else it is the same as the "most likely tag" tag from the output file
			}
		}
			
		elsif ($words=~m/([A-Z][A-Za-z]+)|(A-Z)+/) {	 #Rule 1, if word is a noun and has a capital letter or an acronym, it is a proper noun.
			$temp = "/NNP";		
		}
		
		elsif ($words=~m/^[0-9]+.*/) {		#Rule 2, anything that has numbers is a cardinal number
			$temp = "/CD";
		}
		
		elsif ($words=~m/(\w+-\w+((-\w+)*))/) {  #Rule 3, anything with a hyphen is an adjective
			$temp = "/JJ";
		}
		
		elsif ($words=~m/.*d\b/) {		#Rule 4, anything that ends in "d" is a past tense verb.
			$temp = "/VBD";
		}
		
		elsif ($words=~m/.*ing\b/) {		#Rule 5, anything that ends in "ing" is a gerund or present participle
			$temp = "/VBG";
		}
		
		print "$words". "" ."$temp\n";	#prints the word and its tag.
	
	}	
}
close(INPUT_FILE2); #close the file
			
		
	
#print Dumper \%tagged;