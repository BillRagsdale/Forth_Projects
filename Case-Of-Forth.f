\ Exploring the CASE statement
\
\ case-a.f  2021-04-19
\

anew project

cr cr .( discriminate 3 ways for Imperial units)


: units ( n --- ) \ select label for a unit input
   1  over = if drop ." inches"   else
   12 over = if drop ." feet"     else
   36 over = if drop ." yards"    else
                drop ." no unit"  then then then ;

cr cr 1 units cr 12 units cr 36 units


: unitsC ( n --- )  \ case selects imperial units
  case
      1 of ." inches"   endof
     12 of ." feet"     endof
     36 of ." yards"    endof
           ." no match" endcase ;

cr cr 1 unitsc cr 12 unitsc cr 36 unitsc

cr cr .( ASCII comparisons )

: asciiC ( n --- )  \ case selects asccii word
  case
   ASCII  A  of ." alpha"    endof
   ASCII  D  of ." delta"    endof
   ASCII  G  of ." golf"     endof
                ." no match" endcase ;

cr cr 65 asciiC cr  68 asciiC cr 71 asciiC cr 90 asciiC

cr cr .( string case statement )

: s== ( addr1 addr2 --- ) \  counted string comparison
  over count rot count  compare 0=  true ;

cr c" test"  c" test" s== .s 3drop

: planetsC ( n --- )  \ case selects asccii word
                case
   c" Mercury"  s==   of  ."  57.900.000 km"   endof   drop
   c" Earth"    s==   of  ." 149.600.000 km"   endof   drop
   c" Mars"     s==   of  ." 227.900.000 km"   endof   drop
                          ." no match"       1 endcase drop ;

cr cr
.( Mercury is at )   c" Mercury" planetsC  cr
.( Earth is at   )     c" Earth"   planetsC  cr
.( Mars  is at   )     c" Mars"    planetsC



\s


((
Therefore
          case = setup counter
            of =  over = if drop
and      endof =  else
and       case =  then(count)
))
