000100210729       //TO DO:
000101210729       DCL-F WORKWEEK11 DISK(*EXT) KEYED USAGE(*INPUT: *DELETE);
000102210729       //      RENAME(WORKWEEK1:WORKWEEKR);
000105210729
000106210729       DCL-F EMPLOYEE DISK(*EXT) KEYED USAGE(*INPUT: *UPDATE)
000108210729             RENAME(EMPLOYEE:EMPLOYEER);
000109210729       //DCL-F WORKWEEK11 disk extdesc('LAB8JL/WORKWEEK11')
000110210729       //    keyed usage(*delete)
000111210729       //    rename(workweek1:workweekr);
000112210729       //DCL-F employee disk extdesc('LAB8JL/EMPLOYEE')
000113210729       //    keyed usage(*input:*update:*delete)
000114210729       //    rename(employee:employeer);
000117210729
000118210729       DCL-F EMPDSP8 WORKSTN;
000119210729
000120210729       DCL-S HOURSOVER PACKED(3);
000121210729       DCL-S AFTNOONRATE PACKED(5:2);
000122210729       DCL-S DAYRATE PACKED(5:2);
000123210729       DCL-S NIGHTRATE PACKED(5:2);
000124210729       DCL-S HOURLYRATE PACKED(5:2); //custom rate for each employee
000125210729
000126210729       DCL-DS FKey;
000127210729         AEmpnum zoned(9:0);
000128210729       END-DS;
000129210729
000130210729       DCL-DS employeeDS;
000131210729         empnum;
000132210729         paygrade;
000133210729         firstname;
000134210729         lastname;
000135210729         city;
000136210729         address;
000137210729       END-DS;
000138210729       DCL-DS employeeDDS;
000139210729         dempnum;
000140210729         nwpaygrade;
000141210729         dfirstname;
000142210729         dlastname;
000143210729         dcity;
000144210729         daddress;
000145210729       END-DS;
000146210729
000147210729
000148210729       AFTNOONRATE = 27.55;
000149210729       DAYRATE     = 25.75;
000150210729       NIGHTRATE   = 29.77;
000151210729
000152210729       exsr clear;
000153210729       exfmt record1;
000154210729
000155210729       dow not(*in03);
000156210729         AEmpnum = dempnum;
000157210729         chain %kds(FKey) EMPLOYEE;
000158210729         if %found(EMPLOYEE);  //if employee found in employee file, search employee on workweek1
000159210729           chain %kds(FKey) WORKWEEK11;
000160210729           if %found(WORKWEEK11); //if employee found in workweek1 file
000161210729             *in95 = *on;
000162210729             write record1;
000163210729             EXSR SHOWEMP;       //displays employee information onto the screen
000164210729             if (*in06 = *on);
000165210729               EXSR updemp;        //updates master file and deletes transFile (workweek1 record)
000166210729             endif;
000167210729             *in95 = *off;
000168210729           else;                 //if employee NOT found in workweek1 file
000169210729             errormsg = 'No matching record in Workweek file';
000170210729             *in90 = *on;
000171210729             exfmt record1;
000172210729             *in90 = *off;
000173210729             iter;
000174210729           ENDIF;
000175210729         else;                 //if employee NOT found in employee file
000176210729           errormsg = 'No matching record in Employee file';
000177210729           *in90 = *on;
000178210729           exfmt record1;
000179210729           *in90 = *off;
000180210729           iter;
000181210729         ENDIF;
000182210729
000183210729         if (*in03 = *off);
000184210729           exsr clear;
000185210729           exfmt record1;
000186210729         ENDIF;
000187210729       ENDDO;
000188210729
000189210729       *inlr = *on;
000190210729       return;
000191210729
000192210729       //SUBROUTINES
000193210729       begsr clear;
000194210729         clear dempnum;
000195210729       ENDSR;
000196210729
000197210729       begsr showemp;
000198210729         dfirstname = firstname;
000199210729         dlastname  = lastname;
000200210729         dcity      = city;
000201210729         dphone     = phone;
000202210729         daddress   = address;
000203210729         dshift     = workshift;  //update dshift to string
000204210729         nwpaygrade = paygrade;
000205210729         HRSWRKED   = hrsworked;
000206210729         dytdpay    = ytdpay;
000207210729         EXSR calcpay;
000208210729         exfmt record2;
000209210729
000210210729       ENDSR;
000211210729
000212210729       begsr calcpay;
000213210729         SELECT;
000214210729           WHEN WORKSHIFT = 'A';
000215210729             //AFTERNOON
000216210729             dshift     = 'AFTERNOONS';
000217210729             HOURLYRATE = AFTNOONRATE;
000218210729           WHEN WORKSHIFT = 'D';
000219210729             //DAY
000220210729             dshift     = 'DAYS';
000221210729             HOURLYRATE = DAYRATE;
000222210729           WHEN WORKSHIFT = 'N';
000223210729             //NIGHT
000224210729             dshift     = 'NIGHTS';
000225210729             HOURLYRATE = NIGHTRATE;
000226210729         ENDSL;
000227210729
000228210729         SELECT;
000229210729           WHEN paygrade = '1';
000230210729             EVAL(H) HOURLYRATE = HOURLYRATE * 1.094;
000231210729           WHEN paygrade = '2';
000232210729             EVAL(H) HOURLYRATE = HOURLYRATE * 1.062;
000233210729           WHEN paygrade = '3';
000234210729             EVAL(H) HOURLYRATE = HOURLYRATE * (1.000 - 0.043);
000235210729         ENDSL;
000236210729
000237210729         IF (HRSWORKED > 40);   //if overtime hours worked
000238210729           HOURSOVER = HRSWORKED - 40;
000239210729           EVAL(H) OVRPAY = HOURSOVER * (1.5 * HOURLYRATE);
000240210729           EVAL REGPAY = 40 * HOURLYRATE;
000241210729         ELSE;                 //if no overtime hours
000242210729           EVAL REGPAY = HRSWORKED * HOURLYRATE;
000243210729           EVAL  OVRPAY = 0;
000244210729       //    CLEAR OVERPAY;
000245210729         ENDIF;
000246210729
000247210729         EVAL SHFTPAY = REGPAY;
000248210729         if (*in06 = *on);
000249210729           ytdpay = regpay;
000250210729         ENDIF;
000251210729       ENDSR;
000252210729
000253210729       begsr updemp;
000254210729       //  if (*in06 = *on);
000255210729       //    paygrade = nwpaygrade;
000256210729           employeeds = employeedds;
000257210729           phone = dphone;
000258210729           exsr calcpay;
000259210729           update employeer;
000260210729           delete workweek1;
000261210729       //  ENDIF;
000262210729       ENDSR;
