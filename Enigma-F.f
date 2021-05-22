\ Enigma Prototype
\
\ 2020-03-22 -A \ First cut, works
\ 2021-03-27 -B \ Revised rotors, added turovers and initial settings.
\ 2021-03-27 -D \ Revised rotors to differential.  OK.
\ 2021-04-01 -D \ Added frequency table
\ 2021-05-11 -E \ Redesign 0 based array and rotor access.  OK.
\ 2021-05-17-F  \ Message processing. Working.

anew project  decimal  reset-stacks cls

26 CONSTANT #Letters

CREATE Keyboard Z," ABCDEFGHIJKLMNOPQRSTUVWXYZ"
\ This is a zero based string without a count.
((  0   1   2   3   4   5   6   7   8   9  10  11  123
    A   B   C   D   E   F   G   H   I   J   K   L   M
    13 14  15  16  17  18  19  20  21  22  23  24  25
    N   O   P   Q   R   S   T   U   V   W   X   Y   Z   ))

cr cr .( Dump Keyboard; runs 1A 41..5A )
cr   Keyboard  #letters 1+  dump

: Xload ( n0..n26 addr --- )
\  load #Letters values into an array, descending, offset 0..25.
  0  #Letters 1-  do swap over i + c! -1  +loop drop ;

: SignExtend ( byte --- cell ) \ sign extend 8 bits to 32
    dup 128 and if -256 or then ;

: Sc@ ( addr --- n1 ) \ Fetch a byte and sign extend
    c@  SignExtend ;

: bounded   #letters mod ;  \ keep in 0..25 range

cr cr .(   The Shecker is in alphabet order, no offsets.)

CREATE SteckerFwd #letters 1+ allot
\ The letter relative offset forward or backward.
\    A   B   C   D   E   F   G   H   I   J   K   L   M
     0   0   0   0   0   0   0   0   0   0   0   0   0
\    N   O   P   Q   R   S   T   U   V   W   X   Y   Z
     0   0   0   0   0   0   0   0   0   0   0   0   0   SteckerFwd Xload

cr cr SteckerFwd #letters 1+ dump

: RotorInverse ( add1 addr2  --- )
\ copy rotor1 output offsets to  rotor1 inverting the offsets.
 #letters 0 do   over i +   Sc@ dup negate swap
               2 pick i +  + c!   loop 2drop ;

CREATE SteckerRev #letters 1+ allot
SteckerFwd SteckerRev RotorInverse

cr cr SteckerRev #letters dump

CREATE RotorA-Fwd  #letters 1+ allot \ Rotor One Forward links
\   value in selects value out adjusted for rotor position
\    0   1   2   3   4   5   6   7   8   9  10  11  12  letter in
     1   1   1   1   1  -5   1   1   1   1   1  -5   1
\   13  14  15  16  17  18  19  20  21  22  23  24  25  letter in
     1   1   1   1  -5   1   1   1   1   1  -5   1  -1   RotorA-Fwd Xload

cr cr .( Look at RotorOneFwd and RotorOneRev )
cr RotorA-Fwd #letters 1+ dump

CREATE RotorA-Rev #letters 1+ allot
       RotorA-Fwd RotorA-Rev RotorInverse

cr cr RotorA-Rev #letters 1+ dump

CREATE  Reflector #letters 1+ allot ( --- ) \ only a single array
\   0   1   2   3   4   5   6   7   8   9  10  11  12
   13  13  13  13  13  13  13  13  13  13  13  13  13
\  13  14  15  16  17  18  19  20  21  22  23  24  25
  -13 -13 -13 -13 -13 -13 -13 -13 -13 -13 -13 -13 -13    Reflector Xload

cr cr .( Look at the Reflector. Runs  0D ... F3 )
cr Reflector #letters 1+ dump

\ Keyboard input
((  0   1   2   3   4   5   6   7   8   9  10  11  12
    A   B   C   D   E   F   G   H   I   J   K   L   M
   13  14  15  16  17  18  19  20  21  22  23  24  25
    N   O   P   Q   R   S   T   U   V   W   X   Y   Z    ))

cr cr .( Create the three slots to hold rotors)
: Define-Slot ( RotorxFwd, RotorxRev Its_Position Its_Turnover )
   CREATE 4 cells allot
   ( offset --- field within a Slot)
   DOES> + ;  \ Yield the field address within this array's data.

Define-Slot  SlotI
Define-Slot  SlotII
Define-Slot  SlotIII
Define-Slot  ReflectorI

( To access Slot parameters )
     0  CONSTANT  RotorForward
1 CELLS CONSTANT  RotorReverse
2 CELLS CONSTANT  RotorPosition
3 CELLS CONSTANT  RotorTurnover

cr cr .( Assign rotors A, B, C to the slots I, II and III)
: Start ( --- )  \ reset all rotors to their zero position
     RotorA-Fwd  RotorForward  SlotI    !
     RotorA-Rev  RotorReverse  SlotI    !
              0  RotorPosition SlotI    !
              0  RotorTurnover SlotI    !
     RotorA-Fwd  RotorForward  SlotII   !
     RotorA-Rev  RotorReverse  SlotII   !
              0  RotorPosition SlotII   !
              0  RotorTurnover SlotII   !
     RotorA-Fwd  RotorForward  SlotIII  !
     RotorA-Rev  RotorReverse  SlotIII  !
              0  RotorPosition SlotIII  !
              0  RotorTurnover SlotIII  !
      Reflector  RotorForward  ReflectorI  !
      Reflector  RotorReverse  ReflectorI  !
              0  RotorPosition ReflectorI  !
              0  RotorTurnover ReflectorI  !   ;
Start  ( Set default retor and settings.)

 cr cr .( Report the contents of Slots I, II and III )
: .slot ( address --- )  \ report contents of one slot
   cr  dup RotorForward + @ body> .name
       dup RotorReverse + @ body> .name
       RotorPosition + 2@ . .  ;

: .slots ( --- ) \ report contents of 3 slots
   0 SlotI .slot  0 SlotII .slot  0 SlotIII .slot 0 ReflectorI .slot ;

: >step ( n --- n+1_mod_26)  \ increment within 0..25
   1+ #letters mod ;

: EntryComplete ( --- ) \ increment SlotIII with turnovers
   RotorPosition SlotIII @ >step dup RotorPosition SlotIII !
   RotorTurnover SlotIII @ =
   if  RotorPosition SlotII @ >step dup RotorPosition SlotII !
       RotorTurnover SlotII @ =
       if  RotorPosition SlotI @ >step RotorPosition SlotI  !
    then then ;

: r?   \ Show the current rotor positions of Slots I, II and III
  cr RotorPosition SlotI   ? RotorPosition SlotII ?
     RotorPosition SlotIII ? ;

: CycleTest ( --- ) \ run through a cycle
    r? 8 0 do cr EntryComplete r? loop ;

cr cr .( Checks turnovers SlotIII to SlotII)
start 20 RotorPosition SlotIII ! 23 RotorTurnover SlotIII !
      25 RotorPosition SlotII  !  4 RotorTurnover SlotII  !
       3 RotorPosition SlotI   !  6 RotorTurnover SlotI   !
       CycleTest

cr cr  .( Checks SlotIII to SlotII to SlotI )
start 20 RotorPosition SlotIII ! 23 RotorTurnover SlotIII !
      25 RotorPosition SlotII  !  0 RotorTurnover SlotII  !
       3 RotorPosition SlotI   !  6 RotorTurnover SlotI   !
       CycleTest
cr .slots

: one-level  ( input, Rpomter, Poffsetaddr --- output ) \ through a rotor
         @   \  input, Rpointer,   position
    2 pick   \  input, Rpointer, position, input
 + bounded   \  input, Rpointer, position+input
    swap @   \  input, position+input, rotor_address
         +   \  input, rotoraddress+position+input
       Sc@   \  input, offset
 + bounded ; \  input+offset

: A-letterY  ( letter_in --- letter_out ) \ encrypt one letter
   RotorForward SlotIII    RotorPosition SlotIII    one-level  dup 4 .r
   RotorForward SlotII     RotorPosition SlotII     one-level  dup 4 .r
   RotorForward SlotI      RotorPosition SlotI      one-level  dup 4 .r
   RotorForward ReflectorI RotorPosition ReflectorI one-level  dup 4 .r
   RotorReverse SlotI      RotorPosition SlotI      one-level  dup 4 .r
   RotorReverse SlotII     RotorPosition SlotII     one-level  dup 4 .r
   RotorReverse SlotIII    RotorPOsition SlotIII    one-level dup 5 .r  ;


: Increments   \ Show the current rotor positions of Slots I, II and III
  RotorPosition SlotI   @ 3 .r   RotorPosition SlotII @ 3 .r
  RotorPosition SlotIII @ 3 .r ;

: scramble-test
 cr ."   I II III  In RIII RII RI  Re  RI RII Out RIII RII RI  Re  RI  RII Out  "
\ cr ."   I II III  In  Out Check  "
#letters 0 do
cr increments i 5 .r i a-letterY  ( a-lettery ) drop EntryComplete loop ;

cr cr .( Test 26 positions. Each value is an element output. )
cr start  5 RotorPosition  SlotIII !
         12 RotorTurnover  SlotIII !
          5 RotorPosition  SlotII  !
          6 RotorTurnover  SlotII  !
         20 RotorPosition  SlotI   !    scramble-test


: A-letterX  ( letter_in --- letter_out ) \ encrypt one letter
0  26 26 26 * * 0 do
   RotorForward SlotIII    RotorPosition SlotIII    one-level \ dup 4 .r
   RotorForward SlotII     RotorPosition SlotII     one-level \ dup 4 .r
   RotorForward SlotI      RotorPosition SlotI      one-level \ dup 4 .r
   RotorForward ReflectorI RotorPosition ReflectorI one-level \ dup 4 .r
   RotorReverse SlotI      RotorPosition SlotI      one-level \ dup 4 .r
   RotorReverse SlotII     RotorPosition SlotII     one-level \ dup 4 .r
   RotorReverse SlotIII    RotorPOsition SlotIII    one-level \ dup 5 .r
   key? abort" exit"
  loop  .  ;   ( 79 msec.!)

: ASCII>Integer   ASCII A - ;
: Integer>ASCII   ASCII A + ;

: TestAlpha  \ convert A through Z to integers
 cr ASCII Z 1+ ASCII A  do i ASCII>Integer .    loop
 cr               26 0  do i Integer>ASCII emit loop ;
 cr  .( Numbers to letters) cr TestAlpha

: A-letter  ( letter_in --- letter_out )
   ASCII>Integer
   RotorForward SlotIII    RotorPosition SlotIII    one-level
   RotorForward SlotII     RotorPosition SlotII     one-level
   RotorForward SlotI      RotorPosition SlotI      one-level
   RotorForward ReflectorI RotorPosition ReflectorI one-level
   RotorReverse SlotI      RotorPosition SlotI      one-level
   RotorReverse SlotII     RotorPosition SlotII     one-level
   RotorReverse SlotIII    RotorPOsition SlotIII    one-level
   EntryComplete
   Integer>ASCII   ;

( Message:  Mister Watson Come Here I Want To See You )

create Sample-In  ," MISTERXWATSONXCOMEXHEREXIXWANTXTOXSEEXYOUXXXX"

create Sample-Out  200 allot

create Sample-check 200 allot

: encode ( --- ) \ encrypt a message
  sample-out 200 erase  start
  sample-out   sample-in count
  0 do  dup    i +    c@   A-letter
        2 pick i + 1+ c!
        i 1+ 2 pick   c!  loop   2drop ;

: decode ( --- ) \ decode sample-out into sample-check
  sample-check 200 erase  start
  sample-check  sample-out count
  0  do  dup    i +   c@    A-letter
         2 pick i + 1+  c!
         i 1+ 2 pick  c!  loop   2drop ;

: show-formatted ( --- ) \ display as 5 letter groups
  sample-out count  0 do
  dup i + c@  emit i 5 mod 4 = if bl emit then loop drop ;

: show-message ( array --- ) \ display a message array
  count  0 do  dup i + c@  emit  loop drop ;

cr cr .( Message:  Mister Watson Come Here I Want To See You )
cr cr  sample-in  count type     encode
cr cr  sample-out count type
cr cr  show-formatted
       decode
cr cr sample-check show-message

\s



s


: Fbuild
  0  #Letters  do swap over i cells+ ! -1  +loop drop ;

cr cr .( This is the letter frequencies for English.)

CREATE FrequencyTable 27 cells allot \ counted 4 byte cells
\     A    B    C    D     E    F   G     H    I    J    K    L    M
26  834  154  273  414  1260  203  192  611  671   23   87  424  253
\     N    O    P    Q     R    S    T    U    V    W    X    Y    Z
    680  770  166    9   568  611  937  285  106  234   25  204    6
frequencytable fbuild

: array>  dup c@ ; ( addr --- addr count ) \ byte or cell array

: .frequency  \ show the frequencys table
cr cr frequencytable array> 1+ 1 do i 'A' 1- + cr emit
          dup i cells+ @ 5 .r loop drop ;

.frequency

: .total  \ total frequencys table, expect 10000
cr cr 0 27 1 do frequencytable I cells+ @ + loop cr cr . ;

cr cr .( The standardized total of letter frequency.)
cr cr .total


cr cr .( Create array to hold message letter frequencies.)

create F-Output 27 cells allot \ cells od target letter fequency

: size-adjust ( size count --- adjusted )  10000 rot */ ;

: Normalize-F-Output ( n --- ) \ apportion to n letters to 10,000
     27 1 do dup f-output i cells+ @  size-adjust
             f-output i cells+ !  loop drop ( size ) ;

f-output 27 cells erase
10 f-output 2 cells+ !
25 normalize-F-output
cr cr f-output 27 cells dump

: .F-Output  \ show the frequencys table
cr cr  f-output 27 1  do i 'A' 1- + cr emit
          dup i cells+ @ 5 .r loop drop ;

cr cr .f-output



\s
: analyze ( addr --- ) \ given counted byte string addr
   f-output 27 cells erase
   array> dup >r 1+ 1 do dup i + c@   \ input cypher text.
         '@' -   dup 10        \   letters postion
          F-output over cells+  @ ( pos count )
          1+
          F-output  rot cells+  !  loop  ;

 SampleText analyze

: .f-output  \ show the f-analysis, alha order.
  cr cr 0 27 1 do cr 'A' i + 1- emit
                  f-output i cells+ @ 4 .r loop ;

.f-output

\s

create enc-out ," 11111111111111111111111111111"

: encrypt \from message via enigma
  sampletext nip 1+ 1 DO
   sampletext i + c@
   one-letter
   enc-out    i + c! loop  ;

encrypt



\s
CREATE SampleText ," COMEHEREMISTERWATSONXIWANTYOU" \ place a counted string.

cr cr SampleText 30 dump
cr cr sampleText count type

: xxxx  'Z' 1+ 'A' do i OneLetter> emit loop ;
: yyyy 105000 0 do xxxx loop ;
: zzzz 105000 0 do yyyy loop ;

cr cr xxxx

\s
