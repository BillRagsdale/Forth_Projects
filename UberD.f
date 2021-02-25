\   Create a time log for a Uber driver
\ Developed on Win32Forth Version: 6.15.05 Build: 2
\ A:  start
\ B: 2020-12-03 fully functional, improved parsing.
\ C: 2020-12-03 revised factoring, good, needs error checks

ANEW Blocking

cr cr .( Note: there is no error checking on operator input.) cr

31 CONSTANT days/month  7 CONSTANT days/week   6 CONSTANT weeks/calendar

CREATE DataArray  \ calendar day 1 to 31 in cells 0 to 30
     days/week weeks/calendar * cells allot
\ need only 31 days (cells) but we'll start with 42

: test1  \ quick display of DataArray
   weeks/calendar 0 do days/week cr  0 do
      j days/week * i + cells DataArray + @ 4 .r loop loop ;

0 VALUE Today  \ holding date number within a month, minus 1.

: TodaysDate ( n --- ) \ Accept input day number
   1- TO today ;

0 VALUE FirstMonday  \ zero if Monday is first day of the month

: IsFirstMonday ( Day of month of the first Monday )
  1- TO FirstMonday  ;

: NewMonth ( --- )
   DataArray days/week weeks/calendar * cells erase ;

: MinutesDriven ( n --- ) \ driver's report per trip
   Today Cells DataArray + +! ;

: FirstMonday>Adjustment ( j i --- offset )
  \ the offset between calendar cells and the DataArray cells
  swap days/week * +
  FirstMonday 0= if 0 else days/week FirstMonday - then  - ;

: .header ( --- ) \ days of the week
."    Monday   Tuesday  Wednesday Thursday   Friday   Saturday    Sunday" ;

: Test2 \ print a calendar prototype, no data yet.
       cr .header
   6 0 do cr  days/week 0 do
       j days/week * i + 1+ 4 .r  6 spaces   loop  loop ;

: Total  0    \ total minutes worked across the month
DataArray days/week weeks/calendar * cells + DataArray
   DO i @ + cell +loop ." Total minutes driven are: " .  ;

: Report \ Full calendar based time display
    cr .header
 weeks/calendar 0 do cr  days/week 0 do
     \ test if within days 1 to 31
      j  i  FirstMonday>Adjustment
      dup 0< over days/month >=  or
  if ( day out of month range) drop 10 spaces
     else 1+ ( adjust zero base to calendar day ) 4 .r
       j  i   firstMonday>adjustment
        \ fetch minutes worked on this day
       cells dataarray +  @ 5 .r  1 spaces
     then
   loop  loop cr Total ;

: Bare-report \ Full calendar based time display
    cr .header  days/month  1
    do cr   days/week  0
        do j i + 4 .r 6 spaces loop days/week +loop ;

NewMonth
 6 IsFirstMonday
 5 TodaysDate  40 minutesdriven
 5 TodaysDate  40 minutesdriven
 7 TodaysDate  75 minutesdriven
14 TodaysDate  240 minutesdriven
Report



\s

cr cr .( Here is the command sequence a user would input: )
newmonth
7 isfirstmonday
4  TodaysDate 40 minutesdriven 5 TodaysDate 100 minutesdriven
31 TodaysDate 123 minutesdriven 200 minutesdriven
report

\s
Report the total minutes worked by an Uber driver, per day over one month.
Have input commands for:
Begin a new month
Set the month layout to match this month's calendar.
Set today's date
Enter minutes driven, adding to today's running total.
Allow minutes to be subtracted from minutes driven (negative entry).










