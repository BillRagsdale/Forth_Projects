\ Learn Forth by Programming A Game
\ WFR
\ 2021-01-16 -F Split into parts. This is Part One.
\ 2021-03-02 =G Rebuild for presentation. Part One done.
\ 2021-03-02 -H Working on Part Two. Changed square>, >square, X>, O>.
\
anew beginning   decimal  warning off

cr cr cr cr .( Lesson One ) cr cr
.( I assume you can use: : ; constant variable value dup drop swap) cr
.(  @ ! c@ + - * / if then else do loop begin while until again. etc.) cr
.( If not, refer to any basic text such as Leo Brodie's Starting Forth.)

cr cr .( We will learn how to apply them today.)
cr .( As we learn we'll use the process: )
cr .( 1-discovery, 2-design, 3-code, 4-test. )

cr cr .( Our goal is to program tic-tac-toe or naughts and crosses to some.) cr
cr .( We will introduce: CREATE, ALLOT, DUMP, CONSTANT, DO-LOOP, )
CR .( testing tools, formatting with CR, ABORT", IF-ELSE-THEN, CASE, )
CR .( and interactive user imput. )

cr cr .( We need a playing board and a way to record its content.)
cr cr .( The board has 9 squares so make: 9 CONSTANT #squares. )

9 CONSTANT #squares

cr cr .( Let's create storage named 'action' followed by nine empty cells.)
cr cr .( Design: 1. Create named storage ares, 2-Allocate memory, 3-Fill the memory)
cr cr .( We will create 'action'  and allot 9 cells storage.

\ *****  Using cells *** \

cr cr .( We will start using allot for the data storage space. )
CREATE action #squares cells allot

action #squares cells dump

cr cr .( If we preload values, testing is quicker. )

create action 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 ,

cr cr .( See the initial values 1 through 9. )
action #squares cells dump  cr cr

cr cr .( We need words to read and write into the action array. )
cr .( Note: all read/write use square! & square@ for clear control )
cr .( Note, game squares are numbered 1..9 while action bytes are 0..8. )
cr .( square! places a symbol in a square and square@ reads the symobol. )

: square! ( square symbol --- ) \ adjust offset & write symbol
    action rot 1- cells+ ! ;

: square@ ( square --- contents ) \ adjust offset & read a symbol
    action swap 1- cells+ @ ;

cr cr .( Test these words, writing 77, 88 99. into action )
cr .( See 77 88 99     )
 4 77 square! 5 88 square! 6 99 square!
4 square@ . 5 square@ . 6 square@ .

cr cr .( We need a word to display the contents of action. Create .game. )

: .gamex ( --- ) \ display numeric contents of action
  cr cr  #squares 1+ 1 do i square@ . loop ;
cr .( See 1 2 3 77 88 99 7 8 9 )
.gamex

cr cr .( This  doesn't look the usual board layout. Let's format it with 3-cr.)
cr .( It adds a cr <return> for each row.)

: 3-cr ( n --- ) \ insert CR every third line
   3 mod 0= if cr then ;

: .game ( --- ) \ display numeric contents of action
  cr cr  #squares 1+ 1 do  i square@ .  i 3-cr loop ;

.game

cr cr .( Let's clear the game. We'll use ClearSquares then .game to test.)

: ClearGame #squares 1+ 1 do i 0 square! loop ;

.game ClearGame .game

cr cr .( Lets prepare to place Xs and Os on the board. )
cr .(  1=X , 2=O and zero is empty/unplayed )

1 CONSTANT X   2 CONSTANT O   \  our game symbols

: X!  ( n --- )  X square!  ; \ place an X in square n
: O!  ( n --- )  O square!  ; \ place an O in square n

cr cr .( We'll clear the game and place some test values. )
cr .( See a row of 1's and a row of 2's.)
ClearGame  1 X!   2 X!  3 X!  7 O!  8 O! 9 O!  .game

cr cr .( We wamt to see X and O on the game display.)
cr  .( For an expty, zero we will show the square number)
cr .( CASE will select the action for 0, 1 and 2. )

: .square  ( n --- n+1 ) \ welects the symbol/number for each square l
   dup square@
   case  0 of  dup .    endof
         1 of  ." X "   endof
         2 of  ." O "   endof  endcase drop ;

cr cr .(  Show squares 1, 3, 7 and see X 4 O: )
1 .square  4 .square 7 .square

\ *** graphic board *** \

cr cr .( A more realistic display design. Here is a prototype.)

: 3numbers cr ."  1 | 2 | 3 " ;
: dashes   cr ."  -----------" ;
: .game  ( --- ) \ display the board
 cr 3numbers dashes 3numbers dashes 3numbers ;

.game

cr cr .( Now we place the actual game value in each square. )
cr .( .square will do that. )

: .square  ( n --- n+1 )  \ show square number and increment
         dup square@ . 1+ ;

: 3numbers ( n --- n+1 ) \ enter with cell number
  cr ."   "  .square  ." | "
             .square  ." | " .square  ;

: .game  ( --- ) \ display the board
 cr 1 3numbers dashes 3numbers dashes 3numbers drop ;

.game

cr cr .( We'll redefine .squaes to show the X & O sumbols in action.)
cr .( CASE will select the action for 0, 1 and 2. )

: .square  ( n --- n+1 ) \ welects the symbol/number for each square l
   dup square@
   case  0 of  dup .    endof
         1 of  ." X "   endof
         2 of  ." O "   endof  endcase 1+ ;

: 3numbers ( n --- n+1 ) \ enter with cell number
   cr ."   "  .square  ." | " .square  ." | " .square  ;

\  : dashes   cr ."  -----------" ;

cr .( Display the game with a symbol or square number. )

: .game  ( --- ) \ display the board with Xs, Os and numbers.
 cr 1 3numbers dashes 3numbers dashes 3numbers drop ;

ClearGame   1 X!  2 X!  3 X!  7 O!  8 O!  9 O! .game

\ *** Active board play *** \

cr cr .( The next sequence sets the order of play starting with X,)
cr .( and accepts moves specified by the target square number. )

\ *** Accepting plays in order *** \

cr cr .( We will now accept the plays in order.)
cr .( X goes first. Odd plays are for X. Even plays are for O. )

0 VALUE unplayed  \ number of unplayed squares

: start ClearGame   #squares to unplayed ;

: current-player ( --- flag ) \ true for X player, false for O player.
    unplayed 1 and  ; \ now to be played

cr cr .( Input from playes can be rather complex and uncertain. )
cr .( We'll add range checking, input errors, and early exit. )
cr .( For clarity and ease of testing, break these functions into words. )

cr cr .( Player X begins.)
cr .( Clear parameters. )
cr .( Instruct the player  [X or O] to input a square number.)
cr .( BEGIN )
cr .( Accept a keystroke. )
cr .( If it is esc, notify and exit true. )
cr .( Convert to a number. )
cr .( If in range and if the square is empty then )
cr .(      place the corresponding marker on the board
cr .(      and decrement unplayed value, exit false. )
cr .( Otherwise: Remind the player to input a square number. )
cr .(  AGAIN )

cr cr ( Convert the key value to its decimal equivalent. )
: ASCII># ( n1 --- m2 ) \  ASCII n1 to decimal n2
     ascii 0 -  ;

cr .( from key 5, see 5 displayed:     )
( key ) 53 ASCII># .


cr .( Check the above number is within 1..9. )

: range? ( n --- bool ) \ true if in range, else false
   dup 1 <  swap 9 > or 0= ;

cr cr .( 1 in gives -1:    )   1 range? .
cr .( t in gives 0 :    ) ascii t range? .

cr cr .( Check a cell is empty )

: empty? ( n --- bool ) \ true if empty, else false
    square@  0=  ;
cr .( Clear square see true:   ) ClearGame 1 empty? .
cr .( Set X in 1 see false:   )          1 X! 1 empty? .

: place-symbol ( square --- ) \ Place symbol in square
   current-player if X! else O! then   -1 +TO unplayed  ;

: ps place-symbol ;

cr cr .( See a row of  X's and a row of O's. )
start 1 ps 3 ps 4 ps 6 ps 7 ps 9 ps  .game


: player-input ( --- boolean ) \ false if a play, true is excape to end.
   \ Interactively accept players' square selection
 BEGIN
   \ .board  \ clear and display board
   cr  cr ." Square number for " current-player
      if ." X:  " else ." O:  " then
    key dup emit
    dup  27 ( esc ) =
        if drop ."   Exiting" 1 exit then  \ x to quit
    ASCII># dup  range?
            over empty? and
   if  place-symbol  .game  0  exit then
   ( otherwise )  drop  ."    Pick another square.  "
 AGAIN  ;

cr cr .( Test of inputting one play )
cr .( When prompted, select square 1 to 9 for 3 plays.)
\ start .game player-input player-input player-input

\ For full-game. Clear action and set uplayed squares to 9.
\ Remind the user how to exit early.
\ BEGIN Display the board and accept the player's input
\    If it is 'excape' exit. Otherwise repeat for next play
\ UNTIL all nine plays have been made.
\ In Lession Two will add scoring.

cr cr .( We are ready to begin a game without scoring.)
: full-game ( --- ) \ user game without scoring.
  start  cr ." Enter 'esc' to exit. "
 .game
  BEGIN ( .game ) player-input if exit then \ exit on true
        unplayed 0= UNTIL ;

: fg full-game ;

cr cr .( *** end of Lesson One, using cells *** )


