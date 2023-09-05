main	:-	build_kb , play.
build_kb :-	write("Welcome to Pro-Wordle!"),nl,
			write("----------------------"),nl,
			wordle2.
wordle2	:-	write("Please enter a word and its category on separate lines:"),nl,
			read(Input1),
			(
				Input1 = done , write("Done building the words database..."),nl;
				read(Input2),nl,
				assert(word(Input1,Input2)),
				wordle2
			).
is_category(C):- word(_,C).
categories(L):-	setof(C,is_category(C),L).
available_length(L):-	word(W,_),
						string_length(W,L),!.
pick_word(W,L,C):-	word(W,C),
					string_length(W,L).
correct_letters(L1,L2,CL):-	intersection(L2,L1,CL).
correct_positions([],_,[]).
correct_positions(L1,[],[]) :- 	L1 = [|].
correct_positions([H1|T1],[H1|T2],[H1|T3])	:-	correct_positions(T1,T2,T3).
correct_positions([H1|T1],[H2|T2],L3)	:-	H1 \= H2,
											correct_positions(T1,T2,L3).
											
											
items_in_category_list(C,L,Length)	:-	setof(W , pick_word(W,Length,C),L).


play :-	write("The available categories are: "),
		categories(L),
		write(L),nl,
		playHelperCategory(L).
		
playHelperCategory(L)	:-	write("Choose a category:"),nl,
							read(CategoryOfWord),
							(
							\+ member(CategoryOfWord,L) , 
							write("This category does not exist."),nl,
							playHelperCategory(L);
							member(CategoryOfWord,L),
							playHelperLength(CategoryOfWord)
							).
							
playHelperLength(CategoryOfWord)	:-	write("Choose a length:"),nl,
										read(LengthOfWord),
										(
											\+ pick_word(_,LengthOfWord,CategoryOfWord),
											write("There are no words of this length."),nl,
											playHelperLength(CategoryOfWord);
											pick_word(_,LengthOfWord,CategoryOfWord),
											write("Game started. You have "),
											N is LengthOfWord + 1,
											write(N),
											write(" guesses."),nl,
											continuegame(LengthOfWord,CategoryOfWord)
										).
continuegame(LengthOfWord,CategoryOfWord)	:-	items_in_category_list(CategoryOfWord , L , LengthOfWord),
												random_member(X,L),
												NumberOfGuesses is LengthOfWord + 1,
												guessStage(X,NumberOfGuesses,LengthOfWord).
												
guessStage(WinningWord , 1 , LengthOfWord)	:-	write("Enter a word composed of "),
												write(LengthOfWord),
												write(" letters:"),nl,
												read(GuessedWord),
												(
													GuessedWord = WinningWord , write("You Won!");
													write("You lost!")
												).
												
guessStage(WinningWord , NumberOfGuessesLeft ,LengthOfWord)	:-				
												NumberOfGuessesLeft > 1,
												write("Enter a word composed of "),
												write(LengthOfWord),
												write(" letters:"),nl,
												read(GuessedWord),
												(
													GuessedWord = WinningWord,write("You Won!");
													\+ string_length(GuessedWord , LengthOfWord) ,
													write("Word is not composed of "),
													write(LengthOfWord),
													write(" letters. Try again."),nl,
													write("Remaining Guesses are "),
													write(NumberOfGuessesLeft),nl,
													guessStage(WinningWord , NumberOfGuessesLeft , LengthOfWord);
													string_chars(GuessedWord , GuessedWordList),
													string_chars(WinningWord , WinningWordList),
													correct_letters(GuessedWordList , WinningWordList , CorrectLettersList),
													correct_positions(GuessedWordList , WinningWordList , CorrectPositionList),
													write("Correct letters are: "),
													write(CorrectLettersList),nl,
													write("Correct letters in correct positions are: "),
													write(CorrectPositionList),nl,
													NewNumberOfGuesses is NumberOfGuessesLeft - 1,
													write("Remaining Guesses are "),
													write(NewNumberOfGuesses),nl,
													guessStage(WinningWord , NewNumberOfGuesses , LengthOfWord)
												).