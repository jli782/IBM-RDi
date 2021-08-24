000100210811       DCL-F STUDENTREP PRINTER OFLIND(*IN01);
000101210811       DCL-F STUDENTS21 DISK(*EXT) KEYED USAGE(*INPUT)
000102210811                 RENAME(STUDENTS21:STUDENTR);
000103210811       DCL-S EndOfFile    IND;
000104210811       DCL-S TotalRecords PACKED(5:0) ;
000105210811       DCL-S PROGNAMEH CHAR(20);
000106210811
000107210811       DCL-DS STUDENTR;
000108210811         Student# zoned(9:0);
000109210811         Fname    char(20);
000110210811         Mname    char(20);
000111210811         Lname    char(20);
000112210811         Age    zoedn(2:);
000113210811       END-DS;
000114210811
000115210811       exsr preparefiles;
000116210811       write reportname;
000117210811       write colhdr;
000118210811       exsr nextrow;
000119210811       write progname;
000120210811       PROGNAMEH = prdescrp;
000121210811       DOW NOT EndOfFile;
000122210811         if **in01 = *on;
000123210811           write reportname;
000124210811           write colhdr;
000125210811           *in01 = *off;
000127210811         ENDIF;
000128210811         if prognameh = prdescrp;
000129210811           write details;
000130210811         else;
000131210811           prognameh = prdescrp;
000132210811           write totals;
000133210811           TotalRecords = 0;
000134210811           write progname;
000135210811           write details;
000136210811         ENDIF;
000137210811       ENDDO;
000138210811
000139210811
000140210811       *inlr = *on;
000141210811       return;
000142210811
000143210811       begsr    preparefiles;
000144210811         exec sql
000145210811           declare studentr cursor
000146210811             for
000147210811             select student#, trim(fname) || ' ' || trim(mname) || ' ' || lname AS fullname,
000148210811                    %diff(%date():birthdate:*y) as Age
000149210811
000150210811
000151210811
000152210811
000153210811       ENDSR;
000154210811
