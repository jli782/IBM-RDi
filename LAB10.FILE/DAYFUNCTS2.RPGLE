000100181112
000200210805        //DATFMT used to ensure that *USA is the default for all date field
000300210805        Ctl-Opt NoMain DATFMT(*USA);
000400200406
000500210804      /COPY LAB10,DAYPROTO   // COPY THE PROTOTYPE HERE, --DAYPROTO.rpgle  /Copy must begin @ col 7
000600200406
000700210804       Dcl-Proc DayNumName  EXPORT;   //usr defined function
000800210804         Dcl-Pi *N CHAR(9) ;          //what is returned from the function, dcl-pi
000900210805           Number  Packed(1:0);         //what is input to the function
001000200406         End-PI;
001100200406
001200210805          DCL-DS DAYDATA;      //data structure
001300210805             *n char(9) INZ('Monday');
003200210805             *n char(9) INZ('Tuesday');
003201210805             *n char(9) INZ('Wednesday');
003202210805             *n char(9) INZ('Thursday');
003203210805             *n char(9) INZ('Friday');
003204210805             *n char(9) INZ('Saturday');
003205210805             *n char(9) INZ('Sunday');
003206210805             DAYARRAY CHAR(9) DIM(7) POS(1);
003207210805          END-DS;
003300210805          RETURN DAYARRAY(NUMBER);
003400190327        End-Proc;
