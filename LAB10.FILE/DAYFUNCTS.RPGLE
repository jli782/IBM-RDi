000100181112
000200181112
000300210804        Ctl-Opt NoMain  ;  //line 300 here means: *INLR=*on, IS NO longer needed for rpgle
000400200406
000500210804      /COPY LAB10,DAYPROTO   // COPY THE PROTOTYPE HERE, --DAYPROTO.rpgle  /Copy must begin @ col 7
000600200406
000700210804       Dcl-Proc DayNumName  EXPORT;   //usr defined function
000800210804         Dcl-Pi *N CHAR(9) ;          //what is returned from the function, dcl-pi
000900210804           Number  Packed(1);         //what is input to the function
001000200406         End-PI;
001100200406
001200210804          DCL-s DayName Char(9);      //local variable, standalone field
001300200406
001400210804                 SELECT;              //Solve the function
001500190327                     WHEN NUMBER = 1;
001600101103                     DAYNAME = 'Monday';
001700190327                     WHEN NUMBER = 2;
001800101103                     DAYNAME = 'Tuesday';
001900190327                     WHEN NUMBER = 3;
002000101103                     DAYNAME = 'Wednesday';
002100190327                     WHEN NUMBER = 4;
002200101103                     DAYNAME = 'Thursday';
002300190327                     WHEN NUMBER = 5;
002400101103                     DAYNAME = 'FRIDAY';
002500190327                     WHEN NUMBER = 6;
002600101103                     DAYNAME = 'Saturday';
002700190327                     WHEN NUMBER = 7;
002800101103                     DAYNAME = 'Sunday';
002900101103                     OTHER;
003000101103                     DAYNAME = 'Unknown';
003100101103                 ENDSL;
003200200406
003300210804                 Return Dayname;      //match Ctl-Opt NoMain
003400190327        End-Proc;
