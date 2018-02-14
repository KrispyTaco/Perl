#Andy Huynh, CMSC 416, 02/04/2017
#This program was created as a pseudo-replication of the Eliza bot, which was a psychotherapist. 
#It's main goal was to help individuals express their issues and talk about it more.  
#This program utilizes regular expressions to find certain keywords and use those words to create questions for the user.  
#This program mainly reflected the thoughts back to the user, for example, if the user said that,"I am hungry", Eliza would reply with, "Why are you hungry?"  
#This method was used because it helps the user look back and think about why something is the way it is.  It is a self-discovery type of therapy.  Eliza is the conduit to helping the user find these realizations.
#Another example: Eliza asks, "How can I help you today?" User replies, "I am sad." Eliza responds with, "Why are you sad?", User says, "I can't dance" in which Eliza responds with "Can you tell me why you can't dance?"
#To use the program: You must answer the questions one after another.  First question will ask you of your name, you must input it in the correct format.  Second question will ask you how you are.  You may put simple replies, while complex questions or gibberish would result in the program not knowing what you are talking about.  You may continue to keep responding to Eliza until you type "quit" or "exit".
#Algorithm: I took the input of the user and reflected it back to the user in the form of a question.  
#To do this, I used regex's to find keywords in the user's statements, and then took the subject after the the keywords, and use it for the subject of the question that would be spit back to the user.

#! /usr/local/bin/perl -w 							#tells UNIX where Perl is

	print "Hi, I'm Eliza.  I'm a psycho...therapist. What is your name?\n"; #Asking the name of the user
	
	while (STDIN ne quit) {							#infinite loop
	$hello = <STDIN>;  							#this takes the answer of the above question from the user, $hello var name was chosen because of the greeting from Eliza in the line above

	if ($hello=~m/((I|i) am)|((I|i)'m)|((M|m)y name is)/) {			#This regex searches for only the first and last name of the user
		$name= ($');							#Set the end of what I was searching for into the variable called name
		$name=~ s/^\s+//;  						#Gets rid of the white space to the right of the name
		$name= ucfirst($name);  					#changes the first character of name to uppercase
		chomp $name;							#removes the /n in name
		print "Hi ". "" .$name. ". " ."How can I help you today?\n";  	#This prints out the name of the user by using the "$&" which copies the matched text by the regex
		last;								#breaks out the infinite loop
	}
	else {
		print STDERR "Sorry, please write in the format, 'I'm', 'I am' or 'My name is'\n";	#if incorrect input was made, the program tells the user which format to input in order to proceed.
	}
	}
	while (STDIN ne "quit") {  						#infinite loop so Eliza can keep asking questions and the user can keep responding
		$help = <STDIN>;  						#this takes the answer of the above question from the user, $help var name was chosen because of the question asked above

		if ($help=~m/((I|i)?'m|am)/) {  				#regex that finds if the user is saying that they are feeling something, such as, "I am sad" or "I'm going through a rough time" by using keywords "I am/I'm.  Many people who go through therapy, the therapist will ask them how they feel at this time or at that time, and they usually tell them "I am" this or that. 
			$why = $';  						#$why stores what the user is feeling.
			$why2 = "Can you tell me more about why you are";	#needed a second string because of swaps replacing "me" with "you" and "you" with "me", which didn't make sense when replying
			chomp $why; 						#removes the /n in $why
			$why=~s/myself/yourself/;				#Swaps words so that the responses would make sense if Eliza were to respond to the user
			$why=~s/(\b(I|i)\b)/you/;				#same as above
			$why=~s/\b\me\b/you/;					#same as above
			$why=~s/\b\my\b/your/; 					#same as above
			print $why2. "" .$why. "" ."?\n";  			# prints out the question based on what they said they were feeling. 	
		}
		elsif ($help=~m/((I|i)? (think))/) { 				#regex that finds the keywords "I think", for example: "I think I am" or "I think I want to". These keywords were chosen because a lot of people in therapy are unsure of what they feel, and would many a times say that they think about this or that.
			$think = $'; 						#$think stores what the user is thinking. $think was chosen because it's relevant to the question of "what is the user thinking about?"
			$think2 = "$name, why do you think";			#needed a second string because of swaps replacing "you" with "me" which didn't make sense when replying to the user.
			chomp $think; 						#removes the /n in $think
			$think=~s/myself/yourself/;  				#This swaps the word "myself" with "yourself", so that when the program replies, it would be grammatically correct and be directed back toward the user.
			$think=~s/\b\I\b/you/;					#This swaps the word "I" with "you", for the same reason above.	
			$think=~s/\b\my\b/your/;				#This swaps the word "my" with "your", for the same reason
			$think=~s/\b\me\b/you/;					#This swaps the word "me" with "you", for the same reason above.
			print $think2. "" .$think. "" ."?\n";      		#prints out the question of "why do they think this way?"
		}
		
		elsif ($help=~m/((I|i) want)/) {				#regex that finds what the user wants to do, for example: "I want to dance."  These keywords were chosen because it is a response that a person undergoing therapy would reply with, if one were to ask them what they wanted or why they are doing x reasons.
			$want = $';						#$want stores what the user wants.  $want was chosen because it's relevant to the question of "what is the user wanting?"
			$want2 = "$name, why do you want";			#needed a second string because of swaps replacing "you" with "me" which didn't make sense when replying to the user.
			chomp $want;						#removes /n in $want
			$want=~s/myself/yourself/;				#Swaps words so that the responses would make sense if Eliza were to respond to the user
			$want=~s/(\b(I|i)\b)/you/;				#same as above
			$want=~s/\b\me\b/you/;					#same as above
			$want=~s/\b\my\b/your/;					#same as above
			print $want2. "" .$want. "" ."?\n";			#prints out the question of "why do you want to do x?"
		}
		
		elsif ($help=~m/((I|i)? need)/) {				#regex that finds what the user needs.  Similar to the above question of what they want.  This keyword was chosen to just cover more area if the user were to say something in a similar fashion but different choice of words.
			$need = $';						#$need stores the question of what the user needs.  $need was chosen because it's relevant to the question of "why does the user need this?"
			$need2 ="$name, why do you need";			#needed a second string because of swaps replacing "you" with "me" which didn't make sense when replying to the user.
			chomp $need;						#removes /n in $need
			$need=~s/myself/yourself/;				#Swaps words so that the responses would make sense if Eliza were to respond to the user
			$need=~s/(\b(I|i)\b)/you/;				#same as above
			$need=~s/\b\me\b/you/;					#same as above
			$need=~s/\b\my\b/your/;					#same as above
			print $need2. "" .$need. "" ."?\n";			#prints out the question of "why do you need x?"
		}
		
		elsif ($help=~m/((I|i)? (can't|cannot))/) {			#regex that finds what the user can't do.  The user responds with, "I can't do such and such" or "I cannot because of x".  These keywords were chosen because the user would probably explain why they cannot do something because of a particular reason.
			$cant = $';						#$cant stores what they can't do.  $cant was chosen because it's relevant to the question of "why can't the user do x?"
			$cant2 = "Can you tell me why you can't";		#needed a second string because of swaps replacing "you" with "me" and "me" with "you", which didn't make sense when replying to the user.
			chomp $cant;						#removes /n in $cant
			$cant=~s/myself/yourself/;				#Swaps words so that the responses would make sense if Eliza were to respond to the user
			$cant=~s/(\b(I|i)\b)/you/;				#same as above
			$cant=~s/\b\me\b/you/;					#same as above
			$cant=~s/\b\my\b/your/;					#same as above
			print $cant2. "" .$cant. "" ."?\n";			#prints out the question of "why can't you do x?"
		}
		
		elsif ($help=~m/(B|b)ecause/) {					#regex that finds the word "because." For example, the user responds with, "I don't want to do that because I would choke."  This keyword was chosen because the user would probably explain why they can't do something because of a particular reason or why something is the way it is.
			$because = $';						#$because stores why something is x. $because was chosen because it's relevant to the question of "why something is x?"
			$because2 = "Can you tell me why";			# needed second string because of swaps replacing "you" with "me" and "me" with "you" which didn't make sense when replying to the user.
			chomp $because;						#removes /n in $because
			$because=~s/myself/yourself/;				#Swaps words so that the responses would make sense if Eliza were to respond to the user
			$because=~s/(\b(I|i)\b)/you/;				#same as above
			$because=~s/\b\me\b/you/;				#same as above
			$because=~s/\b\my\b/your/;				#same as above
			print $because2. "" .$because. "" ."?\n";		#prints out the question of "Can you tell me why this is?"
		}
		
		elsif ($help=~m/(H|h)ave/) {					#regex that finds the word "have". For example, the user responds with, "I have a condition." This keyword was chosen because the user would probably use it when describing what they have and how it may relate to the situation at hand.
			$have = $';						#$have stores what the user has. $have was chosen because it's relevant to the question of "Why do you have x?"
			$have2 = "Why do you have";				#needed a second string because of swaps replacing "you" with "me", which didn't make sense when replying to the user.
			chomp $have;						#removes /n in $have
			$have=~s/myself/yourself/;				#Swaps words so that the responses would make sense if Eliza were to respond to the user
			$have=~s/(\b(I|i)\b)/you/;				#same as above
			$have=~s/\b\me\b/you/;					#same as above
			$have=~s/\b\my\b/your/;					#same as above
			print $have2. "" .$have. "" ."?\n";			#prints out the question of "Why do you have such and such?"
		}
		
		elsif ($help=~m/\b(S|s)he\b/) {					#regex that finds the word "she". For example, the user responds with, "She was my mom."  This keyword was chosen because it provides more context from the user and gives us more understanding on the topic and is a possibility that the user would refer to a female.
			$her = "Can you tell me more about her?\n";		#$her stores a string.  $her was chosen as it's relevant to the topic of the person the user is talking about.
			print $her;						#prints out the question of "Can you tell me more about her?"
		
		}
		
		elsif ($help=~m/\b(H|h)e\b/) {					#regex that finds the word "he". For example, the user responds with, "He was my dad."  This keyword was chosen because it provides more context from the user and gives us more understanding on the topic and is a possibility that the user would refer to a male.
			$him = "Can you tell me more about him?\n";		#$him stores a string.  $her was chosen as it's relevant to the topic of the person the user is talking about.
			print $him;						#prints out the question of "Can you tell me more about him?"
		}
		
		elsif ($help=~m/(\b(I|i)\b)|(\b[Yy]es\b)|(\b[Nn]o\b)|(\b[Yy]eah\b)|(\b[Mm]e\b)|(\b[Mm]aybe\b)|(\b[Nn]ope\b)/) {		#regex that finds any other things that the user would say, such as a yes or no response.  This program is not complex enough to handle all types of inputs but gets the broad area of inputs.  The keyword "I" was chosen because it is most likely they would talk about themselves and what they would do, such as: "I forgot why" or "I saw a man running away." The other keywords, "yes", "no", "maybe", "nope", "yeah", are just typical responses the user may respond with.
			if (($help=~m/([A-Za-z]*e\b)/) ne ($help=~m/(\b[Mm]e\b)|(\b[Mm]aybe\b)|(\b[Nn]ope\b)/)) {			#this if statement is for words that end in "e" that we were searching for above, so that it doesn't conflict with the response that we want to give.
			$change = $&;													#This stores the word that we are searching for, if it passes through the if statement.  $change was selected because its relevant to the what word is going to change.
			$change2 = "Can you tell more about your";									#needed a second string because "you" was being changed by "me".
			chomp $change;						#removes /n in $change
			$change=~s/e$/ing/;					#Swaps words ending in "e" to that word ending in "ing" instead.
			$change=~s/myself/yourself/;				#Swaps words so that the responses would make sense if Eliza were to respond to the user
			$change=~s/(\b(I|i)\b)/you/;				#same as above
			$change=~s/\b\me\b/you/;				#same as above
			$change=~s/\b\my\b/your/;				#same as above
			print $change2. " " .$change. "" ."?\n";		#prints out the question, "Can you tell me more about your x?"
		}
			else{
			$tell = "Please tell me more";				#This is a simple statement that is made to return to the user so that they could talk more about the situation and perhaps return to the other questions covered by this Program.
			print $tell. "" .".\n";					#prints out the statement of asking the user to tell Eliza more.
			}
		}
		
			elsif ($help=~m/([A-Za-z]*e\b)/) {			#regex that finds any word that ends in "e". This word spot was chosen because it helps personalize and show that the program can understand the user when they say they perhaps "crave" something or "love" something.
			$change = $&;						#This stores the word that we are searching for.  $change was selected because its relevant to the what word is going to change.
			$change2 = "Can you tell more about your";		#needed a second string because "you" was being changed by "me".
			chomp $change;						#removes /n in $change
			$change=~s/e$/ing/;					#Swaps words ending in "e" to that word ending in "ing" instead.
			$change=~s/myself/yourself/;				#Swaps words so that the responses would make sense if Eliza were to respond to the user
			$change=~s/(\b(I|i)\b)/you/;				#same as above
			$change=~s/\b\me\b/you/;				#same as above
			$change=~s/\b\my\b/your/;				#same as above
			print $change2. " " .$change. "" ."?\n";		#prints out the question, "Can you tell me more about your x?"
		}	
		
		
		
		elsif ($help=~m/(\b[Qq]uit\b)|(\b[Ee]xit\b)/) {			#regex that checks to see if the user types "exit" or "quit". These keywords were chosen so that when the user types in these words, it exits the program.
			print "Thanks for the chat! Have a nice day!\n";		#prints the statement
			last;							#breaks out the infinite loop
		}
		else {
			$question = "Sorry, I don't understand, can you please tell me in a different way?\n";  #$question stores the string stating for the user to ask in a different way because it is either too complex or it was gibberish.  $question was chosen because it is Eliza questioning the user if they could change their wording.
			print $question;									#prints out the statement.
		}
	}