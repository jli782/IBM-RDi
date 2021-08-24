000100190313       //**************************************************************************
000200191105       //* THIS PROGRAM USES A CURSOR TO LOAD A TEMPORARY RESULT TABLE FROM 3
000300191105       //* SEPARATE TABLES, ONTARIO, QUEBEC AND MANITOBA. A NUMBER IS PASSED
000400191105       //* TO THE PROGRAM TO DETERMINE WHICH RECORDS ARE INLCUDED FROM THE 3 TABLES
000500190313       //**************************************************************************
000600190313           DCL-F PROVREPORT PRINTER OFLIND(*IN01) ;
000700190313           DCL-S ProvinceH    Char(10);
000800190313           DCL-S EndOfFile    IND;
000900190313           DCL-S TotalRecords PACKED(5:0) ;
001000190315             // LowLimit is passed to the program
001100210728           DCL-PI Main ExtPgm('PROVSQLH');
001101210728             LowLimitIn Packed(15:5);
001102210728           END-PI;
001200190315
001300190315
001400210728             // All Host Variables available under a single name CustomerRecord (DATA STRUCTURE)
001500210728        DCL-DS CustomerRecord;
001600210728         CustID   Char(6);
001601210728         FullName Char(31);
001602210728         City     Char(20);
001603210728         Purchase Packed(7:2);
001604210728         PDate    Date;
001605210728         Province Char(10);
002200190313        End-Ds CustomerRecord;
002300070123     C/EJECT
002400070123     C**************************************************************************
002500070123     C*                        ***   M A I N   R O U T I N E   ***
002600070123     C**************************************************************************
002700070118      /FREE
002800210728                //assign input param as sql condition to query for
002801210728                LowLimit = LowLimitIn;
002802210728
002803210728                EXSR PrepareFiles;
002900200709                Write ReportHdg;
003000200709                Write RColumns;
003100100309                EXSR GetRow;
003200190313                Write NewProv;
003300070209                ProvinceH = Province;
003400070202                DOW NOT EndOfFile;
003500190313                    IF *IN01 = *ON;
003600210401                        Write ReportHdg;
003700210401                        Write RColumns;
003800190313                       *IN01 = *OFF;
003900070209                    ENDIF;
004000190315                    // Province may change
004100210728                    If ProvinceH = Province;
004101210728                      Write Detail;
004102210728                    Else;
004103210728                      ProvinceH = Province;
004104210728                      Write Totals;
004105210728                      TotalPurch = 0;
004106210728                      Write NewProv;
004107210728                      Write Detail;
004108210728                    ENDIF;
004109210728
005200190313                    TotalPurch     = TotalPurch     + Purchase;
005300070202                    TotalRecords= TotalRecords + 1;
005400100309                    EXSR GetRow;
005500070119                ENDDO;
005600190313                Write Totals;
005700070202                EXSR   WRAPUP;
005800190313                Write UnderLimit;
005900070119                *INLR = *ON;
006000070119                RETURN;
006100100309        //**********************************************************************
006200100309        // O P E N F I L E S   S U B R O U T I N E
006300100309        //**********************************************************************
006400100309         BEGSR  PrepareFiles;
006500190315        // S E T   U P   T H E   T E M P O R A R Y   R E S U L T  STRUCTURE
006600210728        EXEC SQL
006601210728          Declare CustomerCursor Cursor
006602210728            For
006603210728            SELECT CustID, TRIM(FNAME) || ' ' || LNAME, City, Purchase, PDATE,
006604210728                   'Ontario' AS Province
006605210728            FROM BCI433LIB/ONTARIO
006606210728            WHERE PURCHASE > :LowLimit
006607210728            UNION ALL
006608210728            SELECT CustID, TRIM(FNAME) || ' ' || LNAME, City, Purchase, PDATE,
006609210728                   'Quebec' AS Province
006610210728            FROM BCI433LIB/QUEBEC
006611210728            WHERE PURCHASE > :LowLimit
006612210728            UNION ALL
006613210728            SELECT CustID, TRIM(FNAME) || ' ' || LNAME, City, Purchase, PDATE,
006614210728                   'Manitoba' AS Province
006615210728            FROM BCI433LIB/MANITOBA
006616210728            WHERE PURCHASE > :LowLimit
006617210728            For Read Only;
008700190315
008800100309        // A   T E M P O R A R Y   R E S U L T   T A B L E   I S   C R E A T E D
008900210728        EXEC SQL
008901210728          Open CustomerCursor;
008902210728
008903210728       If SQLCODE <> 0 OR SQLWN0 = 'W';
008904210728         EndOfFile = *ON;
008905210728       ENDIF;
008906210728
009600210728         ENDSR;
009700100309        //**********************************************************************
009800100309        //   G E T     R O W    S U B R O U T I N E
009900100309        //**********************************************************************
010000100309            BEGSR     GETROW;
010100210728            EXEC SQL
010101210728              Fetch Next
010102210728                FROM CustomerCursor
010103210728                INTO :CustomerRecord;  //into the data structure defined above
010200190315
010301210728       If SQLCODE <> 0 OR SQLWN0 = 'W';
010302210728         EndOfFile = *ON;
010303210728       ENDIF;
011000190315
011100100309             ENDSR;
011200100309        //**********************************************************************
011300100309        // W R A P U P     S U B R O U T I N E
011400100309        //**********************************************************************
011500100309           BEGSR WRAPUP;
011502210728           EXEC SQL
011503210728             Close CustomerCursor; //finished with temp table, close the cursor
011504210728       If SQLCODE <> 0 OR SQLWN0 = 'W';
011505210728         EndOfFile = *ON;
011506210728       ENDIF;
011507210728
011508210728           EXEC SQL
011509210728             SELECT COUNT(*) INTO :ONTTOTAL
011510210728             FROM BCI433LIB/ONTARIO
011511210728             WHERE Purchase <= :LowLimit;
011513210728       If SQLCODE <> 0 OR SQLWN0 = 'W';
011514210728         EndOfFile = *ON;
011515210728       ENDIF;
011700190315
011701210728           EXEC SQL
011702210728             SELECT COUNT(*) INTO :QUETOTAL
011703210728             FROM BCI433LIB/QUEBEC
011704210728             WHERE Purchase <= :LowLimit;
011705210728       If SQLCODE <> 0 OR SQLWN0 = 'W';
011706210728         EndOfFile = *ON;
011707210728       ENDIF;
011708210728
011709210728           EXEC SQL
011710210728             SELECT COUNT(*) INTO :MANTOTAL
011711210728             FROM BCI433LIB/MANITOBA
011712210728             WHERE Purchase <= :LowLimit;
011713210728       If SQLCODE <> 0 OR SQLWN0 = 'W';
011714210728         EndOfFile = *ON;
011715210728       ENDIF;
011716210728
011717210728           ENDSR;
011800210728
011900190315
012000190315
012100190315
012200190315
012300190315
012400190315
012500190315
012600190315
012700190315
012800190315
012900190315
013000190315
013100190315
