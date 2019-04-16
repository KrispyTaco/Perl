#Andy Huynh
#This project created a Question and Answering system, where the user asks a question
#and we try to retrieve the answer from Wikipedia by using rewrites of the question in an answer format.
#An example of this is: "When is the White House?" can be rewritten as "The White House is located at", "The address of the White House is",
#or "Location of the White House is" to name a few.
#Input should start with Who, What, Where, and When and end with a question mark.
#Example: "Who was George Washington?" or "Where is the White House?"
#To create this QA system, I first broke down the question and split them into different variables which would be used later
#One of the things split from the question was the subject of the question
#The subject was fed into a method from the cpan module used to connect to Wikipedia
#The content returned was then fed into regexes of answer rewrites to find the correct answers
#This is then printed out


#! /usr/local/bin/perl -w

$log = $ARGV[0];	#write the decision list the program learns to this output file

open(OUTPUT_FILE, '>', $log);			#write to the log file

print "This is a QA system by Andy Huynh. It will try to answer questions that start with Who, What, When, or Where. \nEnter \"exit\" to leave the program.\n";
$exit = "exit";

use WWW::Wikipedia;		#cpan module to connect to Wikipedia

my $wiki = WWW::Wikipedia->new( clean_html => 1);
		
while (STDIN ne $exit) {		#infinite loop until user types in exit
	
	$input = <STDIN>;
	
	exit 0 if $input=~m/\bexit\b/;	#exit if user types in exit
	
	my $sent;			#variable for sentences formed by splitting up the question
	my $content;			#variable for the subject of the question
	
	if ($input=~m/\bWho (is|was|are|were) (.*)\?/) {	#regex that grabs Who questions
		$question = "Who";				#set the type of question	
		
		if($input=~m/(.*) (the) (.*)\?/) {		#if sentence has "the" in it
			$the = ucfirst($2);			#capitalize it, as it will be the first word in the sentence
			$content = $3;
			$sent = "$the $content $verb";
			
		}
		
		else {
			$content = $2;
			$verb = $1;
			$sent = "$content $verb";
		}
	}
	
	if ($input=~m/\bWhat (is a|is|was|are|were) (.*)\?/) {	#regex that grabs What questions
		$question = "What";				#grabs the type of question
		$content = $2;
		$verb = $1;
		
		if($input=~m/(.*) (the) (.*)\?/) {
			$the = ucfirst($2);
			$content = $3;
			$sent = "$the $content $verb";
			
		}
		
		else {
			$sent = "$content $verb";
			
		}
	}
	
	
	if ($input=~m/\bWhen (is|was|are|were) (.*)\?/) {	#regex that grabs When Questions
		$question = "When";
		if ($input=~m/\bWhen (is|was|are|were) (.*) born\?/) {	#regex for questions that include "born"
			$content = $2;
			$sent = "$content $1 born";			#born is not part of the subject
		}
		
		
		elsif ($input=~m/(.*) (the) (.*)\?/) {
			$the = ucfirst($2);
			$content = $3;
			$sent = "$the $content $verb";
			
		}
		
		else {
			$content = $2;
			$verb = $1;
			$sent = "$content $verb";
			
			
		}
		
	}
	
	if ($input=~m/\bWhere (is|was|are|were) (.*)\?/) {	#regex that grabs Where questions
		$question = "Where";				#grabs the type of question
		$content = $2;
		$verb = $1;
		
		
		if($input=~m/(.*) (the) (.*)\?/) {
			$the = ucfirst($2);
			$content = $3;
			$sent = "$the $content $verb";
			
		}
		
		else {
			$sent = "$content $verb";
			
		}
	}


	my $result = $wiki->search($content);		#search for the subject in Wikipedia
	
	if ($result) {
		$answer = $result->text();		#if we get a match, grab the text of the matched
		$answer=~s/\n/ /g;			#remove every new line and replace it with a space so that we can have everything in one line
		print OUTPUT_FILE "$answer\n";			#prints out the text of the matched subject
		
		if ($question eq "Where") {		#if question is a Where question
			$answer=~s/\./\n/g;		#remove the periods with new lines so I can distinguish where end of first sentence is
			$answer=~s/\|//g;		#removes pipe lines from the infobox
			
			
			if ($answer=~m/location(\s+)?(=)? ([^,]*)(,)? ([^,]*)?/) {	#regexes that match general cases found when retrieving answers from Wikipedia
				print "$sent located in $3$4 $5.\n";			#matches location from info box
			}
		
			elsif ($answer=~m/located (.*)(\n)([A-Z])/) {			#matches location from the text
				
				print "$sent located in $1.$3.\n";
			}
			
			elsif ($answer=~m/address (=)? (.*)/) {				#matches address from the text
				
				print "$the address of $the $content $verb $2\n";
			}
			
			elsif ($answer=~m/locale = ([^,]*)(,)? ([^,]*)?/) {		#matches a specific instance where they use locale
				
					print "$sent located in $3$4 $5.\n";
			}

			else {
				print "I'm sorry, I don't know the answer.\n";		#can't find answer
			}
		}
			
		elsif ($question eq "What") {		#if question is a What queestion
			$answer=~s/\./\n/g;
			$content2 = "$content". "" ."s";	#create another variable in case subject has plural form in Wikipedia
			$content2 = ucfirst($content2);
			if ($answer=~m/\'$content\'(,)?\s?(.*) is a (.*)\n/) {	#matches in answer where sentence has "is a" in it
				print "A $content is a $3.\n";
			}
			
			elsif ($answer=~m/\'$content2\'(,)?\s?(.*) (are|is) a (.*)\n/) {  #matches the same above but instead this is for the plural form of the subject
				print "$content2 $3 a $4.\n";
			
			}
			
			elsif ($answer=~m/A \'$content\' (.*)\n/) {			#matches subjects that don't have the keyword "is a" in it
				print "A $content $1.\n";
			} 
			
			else {
				print "I'm sorry, I don't know the answer.\n";		#can't find answer
			}
		}
		
		
		elsif ($question eq "When") {					#if question is a When question
			if ($content=~m/[A-Z][a-z]* [A-Z][a-z]*(.*)/) {		#if name, split so we can match entries with middle names/suffixes
				@array = split/\s/, $content;
					$firstname = $array[0];
					$lastname = $array[1];
				}
				
			if ($sent=~m/born/) {		#if question has "born" in it
				
				if ($answer=~m/\'$firstname(.*)? $lastname((.*)\.)?\' \((([A-Za-z]* [0-9]*, [0-9]{4})(.*))\) (is|was)/) {	#match instances found to be repeating in Wikipedia results
					print "$content was born on $5.\n";									#from the result, the subject, if it is a person, usually has their birthdate right after their name
					

				}
				
				elsif ($answer=~m/'$firstname(.*)? $lastname((.*)\.)?\' \((([0-9]* [A-Za-z]* [0-9]{4})(.*))\) (is|was)/) {	#same as above but in a different order
					print "$content was born on $5.\n";
				}
				
				elsif ($answer=~m/'$firstname(.*)? $lastname((.*)\.)?\' \((born ([A-Za-z]* [0-9]*, [0-9]{4}))\)/) {		#some have born before their birthdate
					print "$content was born on $5.\n";
				}
				
				else {
					print "I'm sorry, I don't know the answer.\n";
				}
				
			}
			
			elsif ($answer=~m/\'$content\' (.*) on ([A-Za-z]* [0-9]*, [0-9]{4})/) {			#finds subject date but using the keyword "on"
					print "$the $content was on $2.\n";			
				
			}
			
			
			elsif ($answer=~m/date=([A-Za-z]* [0-9]*, [0-9]{4})/) {					#finds the date of events by using the infobox date
					print "$the $content was on $1.\n";
				
			}
				
			
			else {
				print "I'm sorry, I don't know the answer.\n";
			}
		}
		
		
		elsif ($question eq "Who") {			#if Question is a Who question
			$answer=~s/\./\n/g;
			if ($content=~m/[A-Z][a-z]* [A-Z][a-z]*/) {	#if name, split so we can match entries with middle names/suffixes
					@array = split/\s/, $content;
					$firstname = $array[0];
					$lastname = $array[1];
			}
			
			if ($answer=~m/\'$firstname (.*)? $lastname((.*)\n)?\'(.*)?(is|was) (.*)\n/) {		#finds person/thing by using the keyword "is" or "was" if the person might have a suffix in their name
				print "$content $5 $6.\n";
			}
			
			elsif ($answer=~m/\'$firstname (.*)? $lastname\'(.*)?(is|was) (.*)\n/) {		#finds person/thing by using the keyword "is" or "was" if the person might have a middle name in their name
				print "$content $3 $4.\n";
			}
			
			
			elsif ($answer=~m/\'$firstname $lastname\'(.*)?(is|was) (.*)\n/) {			#finds person/thing by using the keyword "is" or "was"
				print "$content $2 $3.\n";
			}
			
			else {
				print "I'm sorry, I don't know the answer.\n";
			}
		}
			
		else {
			print "I'm sorry, I don't know the answer.\n";
		}
	}
	
	
	else {								#if couldn't find any answer at all or couldn't match to get a result from search, return statement
		print "I'm sorry, I don't know the answer.\n";
	}
	
}


close(OUTPUT_FILE);