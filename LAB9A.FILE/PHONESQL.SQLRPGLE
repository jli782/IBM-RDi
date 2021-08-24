000100190313         // **************************************************************************
000200200326        //  CUSTOMER20 READ BY NATIVE LANGUAGE (ILE RPG)
000300200709        //  CONTACTS20 ROW RETRIEVED WITH EMBEDDED SQL
000400200709        //  DETAIL REPORT LINE INCLUDES INFORMATION FROM CUSTOMER20 AND CONTACTS20
000500190313        //  SUMMARRY REPORT INFORMATION RETRIEVED WITH EMBEDDED SQL STATEMENTS
000600190314
000700190313           DCL-F PHNREPORT PRINTER OFLIND(*IN01) ;
000800200326           DCL-F CUSTOMER20 DISK(*EXT) KEYED USAGE(*INPUT)
000900200326                 RENAME(CUSTOMER20:CUSTR);
001000210721
001001210721        // data structure for host variables from CONTACTS20
001100210721           DCL-DS CONTACTS20 EXT END-DS;
001101210721
001200210721        // Standalone fields for indicator variables
001300210721           DCL-S INDLastCDate BINDEC(4:0); //BINDEC(Total num of digits: decimal posn)
001301210721           DCL-S INDNextCDate BINDEC(4:0);
001400190314
001600190314           DCL-S Dummy  Zoned(1);
001700190314
001800190314        //**************************************************************************
001900190314        //*                        ***   M A I N   R O U T I N E   ***
002000190314        //**************************************************************************
002100190314
002200070119                EXSR SummaryInfo;
002300200709                WRITE NEWPAGE;
002400200326                READ CUSTOMER20;
002500070119                DOW NOT %EOF;
002600070119                    EXSR SQLSelect;
002601210721                     //////////////
002602210721                    IF PHNLDC = OldestDate;
002603210721                      HIGHLIGHT = '<-------';
002604210721                    Else;
002605210721                      HIGHLIGHT = ' ';
002606210721                    ENDIF;
002607210721                     //////////////
002700190313                    IF *IN01 = *ON;
002800200709                       Write NEWPAGE;
002900190313                       *IN01 = *OFF;
003000070119                    ENDIF;
003100200709                    Write RPTLINE;
003200200326                   READ CUSTOMER20;
003300070119                ENDDO;
003400190313                Write SUMMARY;
003500070119                *INLR = *ON;
003600070119                RETURN;
003700080923        //**********************************************************************
003800080923        //   S Q L S E L E C T   S U B R O U T I N E
003900080923   //   //********************************************************************
004000080923   //                  BEGSR    SQLSelect ;
004100080923   //    // A row from the contacts table that has the same customer number as t
004200200326   //    // read from the CUSTOMER20 file is retrieved to find out the last date
004300080923   //    // phone number, comments and the salesperson number.
004400080923   //
004500080923   //    //  The call back interval is added to the last date called to determin
004600210721   //    //  next date to call.  Since null values may be stored in the last date
004700080923   //    // indicator variables are used.
004800210721
004801210721         EXEC SQL
004802210721           SELECT PHNLDC + PHNCIT DAYS, PHNLDC, CSTPHN, PHNCOM, CSTSLN
004803210721           INTO :NEXTCDATE :INDNEXTCDATE, :PHNLDC :INDLastCDate,
004804210721                :CSTPHN, :PHNCOM, :CSTSLN
004805210721           FROM BCI433LIB/CONTACTS20
004806210810           WHERE CSTNUM = :CSTNUM;        //cstnum (contacts20), cstnum (customer20)
004807210721
004808210721           SELECT;
004809210721             WHEN SQLSTATE = '00000';  //sql statement successful
004810210721               Dummy = 0;
004811210721             WHEN SQLSTATE = '02000';  //sql statement ran but row/record on contacts20 not found
004812210721               CstPhn = 'Not Found';
004813210721               NEXTCDATE = D'9999-09-09';           //input 9999-09-09
004814210721               PhnLDC = D'9999-09-09';
004815210721               PhnCom = *All'*';                    //input ***
004816210721             WHEN %Subst(SQLState :1 :2) = '01';    //WARNING
004817210721               NEXTCDATE = D'9999-09-09';
004818210721               PhnLDC = D'9999-09-09';
004819210721               PhnCom = *All'*';
004820210721               CstSln = *All'*';
004821210721               CstPhn = *All'*';
004822210721             OTHER;
004823210721               NEXTCDATE = D'9999-09-09';
004824210721               PhnLDC = D'9999-09-09';
004825210721               PhnCom = *All'*';
004826210721               CstSln = *All'*';
004827210721               CstPhn = *All'*';
004828210721           ENDSL;
004900190314
005000210721         IF INDLastCDate = -1;
005001210721           CstPhn = 'UNKNOWN DATE';
005002210721           NEXTCDATE = D'9999-09-09';
005003210721           PhnLDC = D'9999-09-09';
005004210721         ELSE;
005005210721           IF INDLastCDate <> 0;
005006210721             CstPhn = 'DATE PROBLEM';
005007210721             NEXTCDATE = D'9999-09-09';
005008210721             PhnLDC = D'9999-09-09';
005009210721           ENDIF;
005010210721         ENDIF;
005100210721
006900080923                         ENDSR ;
007000080923        //**********************************************************************
007100080923        // S U M M A R Y I N F O   S U B R O U T I N E
007200080923        //**********************************************************************
007300080923                         BEGSR  SummaryInfo;
007400200709        //  D E T E R M I N E   T O T A L S   F O R   CONTACTS20 & CUSTOMER20
007500210721        EXEC SQL
007501210721           SELECT COUNT(*)
007502210721           INTO :CONTACTT
007503210721           FROM BCI433LIB/CONTACTS20;
007504210721
007505210721           IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
007506210721             CONTACTT = -99999;
007507210721           ENDIF;
007600190314
007700210721        EXEC SQL
007701210721           SELECT COUNT(*)
007702210721           INTO :CUSTOMERT
007703210721           FROM BCI433LIB/CUSTOMER20;
007704210721
007705210721           IF (SQLCODE <> 0) OR (SQLWN0 = 'W');
007706210721             CONTACTT = -99999;
007707210721           ENDIF;
007800190314
009000210721        // D E T E R M I N E   N U M B E R   O F   U N K N O W N   LAST   DATE CALLED records
009100210721        EXEC SQL
009101210721           SELECT COUNT(*)
009102210721           INTO :UNKNOWNT
009103210721           FROM BCI433LIB/CONTACTS20
009104210721           WHERE CstLastCallDate IS NULL;
009105210721
009106210721           IF NOT(SQLCODE = 0) OR (SQLWN0 = 'W');
009107210721             UNKNOWNT = -99999;
009108210721           ENDIF;
009200190314
010100210721        //  D E T E R M I N E   O L D E S T   &  M O S T   R E C E N T  L A S T  callback dates
010200210721        EXEC SQL
010201210721          SELECT MIN(PHNLDC)
010202210721          INTO :OldestDate
010203210721          FROM BCI433LIB/CONTACTS20;
010204210721
010205210721          IF (SQLCODE <> 0) OR (SQLWN0 = 'W') AND (SQLWN2 <> 'W');
010206210721             OldestDate = D'9999-09-09';
010207210721          ENDIF;
010208210721
010209210721       EXEC SQL
010210210721         SELECT MAX(PHNLDC)
010211210721         INTO :MOSTRECENT
010212210721         FROM BCI433LIB/CONTACTS20;
010213210721
010214210721         SELECT;
010215210721           WHEN SQLWN2 = 'W';
010216210721             Dummy = 0;
010217210721           WHEN NOT(SQLCODE = 0) OR (SQLWN0 = 'W');
010218210721             MOSTRECENT = D'9999-09-09';
010220210721         ENDSL;
010221210721
012100080923       // D E T E R M I N E   T H E   U S E R   S E R V E R   &   T I M E S T A
012200210721       EXEC SQL
012201210721         SELECT USER, CURRENT TIMESTAMP, CURRENT SERVER
012202210721         INTO :USER, :TIMESTAMP, :SERVER
012203210721         FROM SYSIBM/SYSDUMMY1;
012300210721
012800080923                         ENDSR;
