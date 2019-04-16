#Andy Huynh 02/18/18
#This program was designed to generate random sentences from a text chosen by the user.
#The randomly generated sentences are selected by n-grams, which choose words given their
#frequency.
#This program only accepts command line arguments, in the format, "perl file_name (number of n-grams) (number of sentences to generate) input file(s)
#An example of this would be, "perl ngram.pl 3 10 text1.txt text2.txt text3.txt".
#This generates 10 random sentences from the 3 texts based in a tri-gram. 
#The algorithm used: put the input texts into an array, then split the array by whitespace and punctuation.
#Then put the array into a hash of hashes.  The hash table on the outside has the keys of the words with the values of the n-gram that it had obtained.
#The hash within, has the n-gram as the key and the value is how many times that n-gram had occured.
#To generate the sentences, we basically went through a for loop based on the amount of sentences the user wanted to generate.
#Before that, we had to find the probabilities of the words.  To do this, we had to had to find the frequencies and used the n-gram logic to find the probabilities.
#Next, we had a random number generated so that it could be compared to the probabilities of the words.  If a word was within the range of this random number, it would be put into the sentence.
#The words would continue being printed until it reached a period, question, or exclamation mark.

#! /usr/local/bin/perl -w

$n = $ARGV[0];  #takes in the n-gram as a command line arg
$m = $ARGV[1];	#takes in the amount of sentences as a command line arg
$n = shift;
$m = shift;
%tokens = {};	#an empty hash table for the tokens
%prev = {};	#an empty hash table for n-1 of the current n-gram
$count = 0;	#count for tokens
$sent_count = 0;	#sentence counter so that it can break out of the for loop when producing the sentences

print "This program generates random sentences based on an n-gram model.  Created by Andy Huynh.\n";	#print statement
print "Command line settings: ngram.pl $ARGV[0] $ARGV[1]\n";						#print statement


use Data::Dumper qw(Dumper);

while( <> ) {			#reads file					
	chomp;			#takes out newline
	@array = split/\b/;	#split texts input by punctuation, commas, spaces, etc.
	foreach $word (@array) {	#goes through entire array
	  
		if ( $word=~m/\./) {  		#if there is a period, replace it with a period a start tag
			$word=~s/\./. <start>/g;	
		}
	
		if ($word=~m/\?/) {		#if there is a question mark, replace it with a question mark and start tag
			$word=~s/\?/? <start>/g;	
		}
	
		if ($word=~m/\!/) {		#if there is an exclamation mark, replace it with an exclamation mark and start tag
			$word=~s/\!/! <start>/g;	
		}
		
	}
	  
	for my $i(0..$#array) {		#iterate through the for loop until it reaches the end of the array		
		my $j = $i + $n - 1;	#this is for the current n-gram
		my $l = $i + $n - 2;	#this is for the n-1 gram	
		my $first = $array[$i];		#this takes in the word so that it can be a key for the hash table
		$first = lc($first);		#this makes it lowercase	
		my $ngram = "";			#set the ngram as an empty string
		my $ngram2 = "";		#set the ngram for the n-1 ngram as an empty string
		if($j > $#array) {		#continue unless it is less than the size of the array	
			next;
		}	
		for my $k ($i..$j) {			#iterate through the loop	
			$ngram .= "$array[$k] ";	#add the value of array at index k to the ngram variable
			$ngram = lc($ngram);		#change the words that were grabbed by the n-gram to lowercase
		}
		for my $m ($i..$l) {			#iterate through the loop
			$ngram2 .= "$array[$m] ";	#add the value of array at index m to the n-1 ngram variable
			$ngram2 = lc($ngram2);		#change the words that were grabbed by the n-1 n-gram to lowercase
		}
		chomp $ngram;				#take out the new line
		chomp $ngram2;				#take out the new line
		$tokens{$first}{$ngram}++;		#increment the value every time the tokens has been seen in the hash table
		$prev{$first}{$ngram2}++;		#increment the value every time the tokens has been seen in the hash table
		$count++;				#increment the counter everytime we iterate through the loop
		}
	
}
	
	if ($n == 1) {					#if user ask for a unigram		
			foreach $key (keys %tokens) {			#go through first part of hash table
				foreach $value (keys %{$tokens{$key}}) {	#goes through second part of hash table
					$float = ($tokens{$key}{$value})/(\$count);	#calculate the probability of a unigram and store it into a float
					$tokens{$key}{$value} = $float;			#put the value into the hash table
				}				
			}
				
				for $sent(0..$m){		#loop for the sentences
				foreach $key (keys %tokens) {		#goes through first part of the hash table
					foreach $value (keys %{$tokens{$key}}) {	#goes through second part of hash table
						if ($sent_count != $m) {		#stops more sentences from being generated if the amount of sentences equal m
						my $r = rand();				#creates a random number each time it runs in the loop
						if ( $r/$count <= $tokens{$key}{$value}) {	#values are really low so I divided by count to get similar values as the tokens value, if r is lower, then it chooses that word
							if ( $key=~m/[\W\s]+<start>/) {		#if the key from the hash has a start tag and punctuation, then go through this loop	
								$key =~s/\. <start>/./g;	#replaces the start tag with just the punctuation
								$key =~s/\? <start>/?/g;	#same as above
								$key =~s/\! <start>/!/g;	#same as above
								$key =~s/\.<start>/./g;		#same as above
								$key =~s/\?<start>/?/g;		#same as above
								$key =~s/\!<start>/!/g;		#same as above
								$key =~s/  //;			#if there are double spaces, replace them with no space at all
								print "$key\n";			#print the key
								$sent_count++;			#increment the amount of sentences since we found a punctuation mark, we indicate that is the end of a sentence
								last;				#break out of the loop
							}
							else {
								
								$key =~s/\s+//;			#replace multiple spaces with no space at all
								print "$key ";			#print the key
								
							}
						}
					}
				}
			}
			}
		}
	
	else {					#if the user is looking for anything other than a unigram
		foreach $key (keys %tokens) {			#go through the first part of the hash table
			foreach $value (keys %{$tokens{$key}}) {	#goes through the second part of the hash
				$float = ($tokens{$key}{$value})/(\$prev{$key}{$value});	#calculates the probability of any n-gram other than a unigram and stores it into a float
				$tokens{$key}{$value} = $float;					#puts this value into the hash table
			}
		}
		for $sent(0..$m){		#for loop for the amount of sentences we are trying to generate
			$before = $n;		#variable that would enable us to keep looping through until we have enough to equal the n-gram.
				foreach $key (keys %tokens) {			#goes through the first part of the hash
					foreach $value (keys %{$tokens{$key}}) {	#goes through the second part of the hash
						if ($sent_count != $m) {		#stops more sentences from being generated if the amount of sentences equal m
						my $r = rand();				#generated a random number
						if ( $r/$count <= $tokens{$key}{$value}) {	#if r is lower, then it chooses that word
							if ( $key=~m/[\W\s]+<start>/) {		#if the key from the hash has a start tag and punctuation, then go through this loop
								$key =~s/\. <start>/./g;	#replaces the start tag with just the punctuation
								$key =~s/\? <start>/?/g;	#same as above
								$key =~s/\! <start>/!/g;	#same as above
								$key =~s/\.<start>/./g;		#same as above
								$key =~s/\?<start>/?/g;		#same as above
								$key =~s/\!<start>/!/g;		#same as above
								if ( $before == $n) {		#if there was nothing before the punctuation we found, go back into the loop
									next;
								}
								else{				#otherwise print the key and increase the count of the sentence and break out of the current iteration
								print "$key\n";
								$sent_count++;
								last;
								}
							}
							else {
								
								$key =~s/\s+//;			#removes multiple white spaces with no space at all
								print "$key ";			#print the key
								$before++;			#increment this variable so that we know that there is something before the punctuation mark.
								
							}
						}
					}
				}
			}
			}
	}