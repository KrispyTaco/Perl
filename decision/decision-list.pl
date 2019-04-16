#Andy Huynh 03/23/18
#In this program, I used a decision list to disambiguate words in a test file
#This is done by using features and putting them into a list
#We have a target word, which could have multiple meanings or word senses
#If we take features, such as the word before or after the target word, or maybe even 2 words before or after the target word
#we could possiblu disambiguate a test file that didn't have the answer of the word sense
#by comparing if a that sentence that contained the target word, had the features in the sentence
#if it did, it is likely that it would be the sense we associated with those features
#To run the program, you would need to put in the command line: perl decision-list.pl line-train.txt line-test.txt my-decision-list.txt > my-line-answers.txt
#The first commmand line argument is the training file, the second is the test file where we are looking to disambiguate the target words
#The third is where we save our decison-list, log-likelihood, and the sense it predicts
#The output file is where we tag all the answer instances with a senseid
#The algorithm used to solve this problem is in the following steps:
#grab the senses and associate them with features near the target word
#calculate the probabilites of a feature given it's sense
#with that, calculate the log-likelihood if it had more than one sense
#get the features from the test file and compare them to the training file
#if they are the same, set the sense from the training file to that instance

#! /usr/local/bin/perl -w

$text1 = $ARGV[0];	#training file
$text2 = $ARGV[1];	#test fiile
$output = $ARGV[2];	#write the decision list the program learns to this output file
%list = {}; 		#hash of hashes for calculating the probabilities of the decision list
%freq = {};		#hash for count of the features
%max_occur = {};	#hash for max occurences for the features given their senses
%log_like = {};		#hash for log-likelihood
%sense_hash = {};	#hash for saving the sense;
$max_sense = "";	#have max sense be the empty string

use Data::Dumper qw(Dumper);	#used to print out the hash table to see if all is correct

open(INPUT_FILE, $text1);	#opens the text file

while (<INPUT_FILE>) {
	chomp;			#removes new line
	@array = split/[\s]/;	#split on white space
	for my $i (0..$#array) {	#iterate through the array
		
		if ($array[$i]=~m/senseid=("(.*)")/) {	#gets the sense
			$sense = $2;
			$sense_hash{$sense}++;
		}
		
			if ($array[$i]=~m/<head>line(s)?<\/head>/) {	#gets the sentence that contains the word "line"
				$before = $array[$i-1];			#gets the word from the left of line
				$before2 = $array[$i-2];		#gets two words from the left of line
				
				if ($array[$i] ne $#array || $#array-1) {	#checks to see if the current index is not the size of the array or one before the end of the array
					$after = $array[$i+1];			#gets one word to the right of line
					$after2 = $array[$i+2];			#gets the second word to the right of line
				}
				
				$feature = "$before $after";			#feature one puts both the first word to the right and left of the word line
				$feature2 = "$before $after2";			#feature 2 puts both the first word to the left of line and the second word to the right of line
				$feature3 = "$before2 $after";			#feature 3 puts both the first word to the right of line and the second word to the left of line
				$feature4 = "$before2 $after2";			#feature 4 puts both the second word to the right and left of line
				$feature5 = "$before2 $before";			#feature 5 puts both the first and second word to the left of line
				$feature6 = "$after $after2";			#feature 6 puts both the first and second word to the right of line
				$feature7 = "$before";				#feature 7 puts just the first word to the left of the word line
				$feature8 = "$after";				#feature 8 puts just the first word to the right of line
				$list{$feature}{$sense}++;			#increments the amount of times feature one given it's sense is seen together
				$list{$feature2}{$sense}++;			#increments the amount of times feature 2 given it's sense is seen together
				$list{$feature3}{$sense}++;			#increments the amount of times feature 3 given it's sense is seen together
				$list{$feature4}{$sense}++;			#increments the amount of times feature 4 given it's sense is seen together
				$list{$feature5}{$sense}++;			#increments the amount of times feature 5 given it's sense is seen together
				$list{$feature6}{$sense}++;			#increments the amount of times feature 6 given it's sense is seen together
				$list{$feature7}{$sense}++;			#increment the amount of times feature 7 given it's sense is seen together
				$list{$feature8}{$sense}++;			#increment the amount of times feature 8 given it's sense is seen together
				$freq{$feature7}++;				#gets the amount of occurences of the features
				$freq{$feature8}++;
				$freq{$feature}++;
				$freq{$feature2}++;
				$freq{$feature3}++;
				$freq{$feature4}++;
				$freq{$feature5}++;
				$freq{$feature6}++;
			
			}	
		}
}	
close(INPUT_FILE);			#close the file after done reading it

foreach $key (keys %list) {		#This calculates the probability of the sense given the feature
	foreach $value (keys %{$list{$key}}) {	#goes through second part of hash table
		$float = ($list{$key}{$value})/($freq{$key});	#calculate the probability of the sense given the feature
		$list{$key}{$value} = $float;				#assign it the calculated value
	}
}

foreach $key (keys %sense_hash) {	#get the max sense that occurs in the training file
	
	if ($sense_hash{$key} > $max) {
		
		$max = $sense_hash{$key};
		$max_sense = $key;
	}
}

foreach $key (keys %list) {	#this gets the max occurence of the feature given it's sense
	$max = 0;		#every iteration, reset max value to 0
	$sense1 = 0;		#every iteration, reset sense 1 and 2 to 0
	$sense2 = 0;
	while (my($senses, $value) = each %{$list{$key}}) {	#goes through each value of the hash of hashes
		if ($value == 1) {				#if value = 1, then that is the only word sense, return it
			$max_occur{$key} = $sense;
		}
		else {
			if ($value > $max) {			#if occurence of sense is higher than max value assign it to the new max value
				$max = $value;
				$sense = $senses;		#$sense is used to save the value of the sense with the higher max value for this iteration
				$max_occur{$key} = $sense;		#assigns or replaces the value for the key in the hash table
				
			}
		}
	}
}
foreach $key (keys %list) {					#This gets the log-likelihood of features that have more than one sense
	$sense1 = 0;						#reset sense 1 and 2 to 0
	$sense2 = 0;
	while (my($senses, $value) = each %{$list{$key}}) {	#goes through each value of the hash of hashes
		if ($value == 1) {				#if value = 1, then that is the only word sense occurence, return it
			next;					#go to the next iteration
		}
		else {
			if ($sense1 == 0) {
				$sense1 = $value;		#if we don't have a a probability stored for sense 1, store the first one we see that has a feature with more than one word sense
				next;				#stop and go to the next iteration
			}
			
			if ($sense1 != 0 ) {			#if sense 1 has a value, assign the next sense probabilty to sense 2
				$sense2 = $value;
			}
			
			if ($sense1 && $sense2 != 0) {		#if both are not 0 or empty, then take the log of both and store that value into the hash table
				
				$log = abs(log($sense1/$sense2));
				$log_like{$key} = $log;
			}
		}
	}
}
open(INPUT_FILE2, $text2);					#open next file

while (<INPUT_FILE2>) {
	chomp;
	@array2 = split/\s/;					#split on whitespace
	for my $i(0..$#array2){
		
		if ($array2[$i]=~m/id="(.*)"/) {		#get the id of the instance
			$id = $1;
			
		}
		
		if ($array2[$i]=~m/id="(.*})/) {			#since I split it on white space, some of the instance ids had it's id split up, this is to rectify that situation
			$l = $i;
			$id = $1;				#set id to whatever is we found first in the parenthesis in the regex
			until ($array2[$l]=~m/:/) {		#continue to we find a colon in one of the index values
				$temp3 = $array2[$l+1];		#set a temp variable to store the next iteration value
				$id = "$id $temp3";		#concatenate it with the id
				$l++;				#increment $l to go to the next iteration until we find the colon
			
			}
		}
	
		if ($array2[$i]=~m/<head>line(s)?<\/head>/) {	#this is used to add to the left and right of the sentence containing line
			$before = $array2[$i-1];			#gets the word from the left of line
			$before2 = $array2[$i-2];		#gets two words from the left of line
				
				if ($array2[$i] ne $#array2 || $#array2-1) {	#checks to see if the current index is not the size of the array or one before the end of the array
					$after = $array2[$i+1];			#gets one word to the right of line
					$after2 = $array2[$i+2];			#gets the second word to the right of line
				}
				
				$feature = "$before $after";			#feature one puts both the first word to the right and left of the word line
				$feature2 = "$before $after2";			#feature 2 puts both the first word to the left of line and the second word to the right of line
				$feature3 = "$before2 $after";			#feature 3 puts both the first word to the right of line and the second word to the left of line
				$feature4 = "$before2 $after2";			#feature 4 puts both the second word to the right and left of line
				$feature5 = "$before2 $before";			#feature 5 puts both the first and second word to the left of line
				$feature6 = "$after $after2";			#feature 6 puts both the first and second word to the right of line
				$feature7 = "$before";				#feature 7 puts just the first word to the left of the word line
				$feature8 = "$after";				#feature 8 puts just the first word to the right of line
				$sen = "$max_sense";				#set sense to the default with the max sense
				$log = -123433;					#set the log value to an arbitray number
				
				foreach my $feat (keys %max_occur) {		#goes through all the features in the decision list
				
					if ($feature eq $feat) {		#compare the features with feature 1 from the test file
						foreach $key (%log_like) {	#go through the log_likelihood senses
		  					if ($key eq $feature) {		#if the feature equals the feature in the log-likelihood hash set the log value to the current log-likelihood value and set the sense to the current sense and then exit the loop
								
								if ($log_like{$key} > $log) {
									$log = $log_like{$key};
									$sen = $max_occur{$feat};
								
								last;
								}
							}
							else {				#else if there isn't any log-likelihood features, then set the current sense to the sense from the decision list
						$sen = $max_occur{$feat};
						}
					}
						last;
					
					}
				}
				
				foreach my $feat (keys %max_occur) {
				
					if ($feature2 eq $feat) {	#compare the features with feature 2 from the test file
						foreach $key (%log_like) {
							if ($key eq $feature2) {
								
								if ($log_like{$key} > $log) {
									$log = $log_like{$key};
									$sen = $max_occur{$feat};
								
								last;
								}
							}
						
						else {
						$sen = $max_occur{$feat};
						}
					}
						
						last;
					
					}
				}
				
				foreach my $feat (keys %max_occur) {
				
					if ($feature3 eq $feat) { #compare the features with feature 3 from the test file
						foreach $key (%log_like) {
							if ($key eq $feature3) {
								
								if ($log_like{$key} > $log) {
									$log = $log_like{$key};
									$sen = $max_occur{$feat};
								
								last;
								}
							}
						else {
						$sen = $max_occur{$feat};
						}
					}
						
						last;
					
					}
				}
				
				foreach my $feat (keys %max_occur) {
				
					if ($feature4 eq $feat) { #compare the features with feature 4 from the test file
						foreach $key (%log_like) {
							if ($key eq $feature4) {
							
								if ($log_like{$key} > $log) {
									$log = $log_like{$key};
									$sen = $max_occur{$feat};
								
								last;
								}
							}
							else {
						$sen = $max_occur{$feat};
						}
					}
						
						last;
					
					}
				}
				foreach my $feat (keys %max_occur) {
				
					if ($feature5 eq $feat) {
						foreach $key (%log_like) {
							if ($key eq $feature5) {
							
								if ($log_like{$key} > $log) {
									$log = $log_like{$key};
									$sen = $max_occur{$feat};
							
								last;
								}
							}
							else {
						$sen = $max_occur{$feat};
						}
					}
						last;
					
					}
				}
				
				foreach my $feat (keys %max_occur) {
				
					if ($feature6 eq $feat) {
						foreach $key (%log_like) {
							if ($key eq $feature6) {
								if ($log_like{$key} > $log) {
									$log = $log_like{$key};
									$sen = $max_occur{$feat};
								
								last;
								}
							}
							else {
						$sen = $max_occur{$feat};
						}
					}
					
						last;
					
					}
					
				}
				
				
				foreach my $feat (keys %max_occur) {
				
					if ($feature7 eq $feat) {
						foreach $key (%log_like) {
							if ($key eq $feature7) {
								if ($log_like{$key} > $log) {
									$log = $log_like{$key};
									$sen = $max_occur{$feat};
								last;
								}
							}
							else {
						$sen = $max_occur{$feat};
						}
					}
						last;
					
					}
				}
				
				foreach my $feat (keys %max_occur) {
				
					if ($feature8 eq $feat) {
						foreach $key (%log_like) {
							if ($key eq $feature8) {
								if ($log_like{$key} > $log) {
									$log = $log_like{$key};
									$sen = $max_occur{$feat};
								last;
								}
							}
							else {
						$sen = $max_occur{$feat};
						}
					}

						last;
					
					}
				}
				
				print "<answer instance=\"$id senseid=\"$sen\"\/\n>";			#print out the answer to the output file
		}
	}
}

close(INPUT_FILE2);

open(OUTPUT_FILE, '>', $output);			#write the decision list, log-likelihood list, and the sense predicted to the text file called "my-decision-list"
	print OUTPUT_FILE "Decision list: \n";
	print OUTPUT_FILE Dumper (\%list);
	print OUTPUT_FILE "Log-likelihood: \n";
	print OUTPUT_FILE Dumper \%log_like;
	print OUTPUT_FILE "Sense predicted: \n";
	print OUTPUT_FILE Dumper \%max_occur;

close(OUTPUT_FILE);

#print Dumper \%log_like;