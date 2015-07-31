/* Formatted on 5/10/2014 3:16:02 PM (QP5 v5.256.13226.35510) */
/*
-- CHANGE notification document :
--      http://docs.oracle.com/cd/B19306_01/appdev.102/b14251/adfns_dcn.htm
--      http://docs.oracle.com/cd/B19306_01/appdev.102/b14258/d_chngnt.htm
--      http://www.oracle-base.com/articles/10g/dbms_change_notification_10gR2.php
--      http://www.oracle-developer.net/display.php?id=411

GRANT CHANGE NOTIFICATION TO "ORCL";
GRANT EXECUTE ON DBMS_CHANGE_NOTIFICATION TO "ORCL";
GRANT SELECT ANY TABLE TO "ORCL";

SELECT *
  FROM dba_change_notification_regs
 WHERE username = 'ORCL';

SELECT * FROM user_change_notification_regs;

EXEC DBMS_CHANGE_NOTIFICATION.deregister (regid => 26);

SELECT * FROM orcl.messages;

UPDATE orcl.messages
   SET equipid = 0001
 WHERE id BETWEEN 10 AND 30;

UPDATE orcl.messages
   SET equipid = 0002
 WHERE id BETWEEN 20 AND 30;

UPDATE orcl.messages
   SET equipid = 0003
 WHERE id BETWEEN 30 AND 40;

UPDATE orcl.messages
   SET equipid = 0004
 WHERE id BETWEEN 60 AND 70;

COMMIT;
*/

-- truncate table orcl.messages;

DESCRIBE orcl.messages;

CREATE TABLE orcl.site
(
   siteid     NUMBER,
   sitename   VARCHAR2 (50),
   ip         VARCHAR2 (25)
);

-- TABLESPACE orcl.users;
/

CREATE UNIQUE INDEX orcl.uq_orcl_site
   ON orcl.site (siteid);

-- TABLESPACE orcl.users;
/

-- insert into orcl.site(siteid, sitename, ip) values (792, 'Dummy Load', 'localhost');
-- commit;

-- drop sequence message_seq;

CREATE SEQUENCE message_seq START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
/

-- drop table orcl.messages;

CREATE TABLE orcl.messages
(
   id        NUMBER,
   siteid    NUMBER,
   dtg       TIMESTAMP,
   equipid   NUMBER,
   msgtext   VARCHAR2 (1024),
   inout     INT DEFAULT 0,
   pending   VARCHAR2 (1) DEFAULT 'N'
);

--TABLESPACE orcl_users;
/

CREATE UNIQUE INDEX orcl.uq_orcl_messages
   ON orcl.messages (id);

--TABLESPACE orcl_users;
/

CREATE INDEX orcl.ix_orcl_messages_siteequip
   ON orcl.messages (siteid, equipid);

--TABLESPACE orcl_users;
/

-- drop sequence message_notifier_seq;

CREATE SEQUENCE message_notifier_seq START WITH 1
                                     INCREMENT BY 1
                                     NOCACHE
                                     NOCYCLE;
/

-- drop table orcl.message_notifier;

CREATE TABLE orcl.message_notifier
(
   id          NUMBER,
   siteid      NUMBER,
   messageid   NUMBER,
   pending     VARCHAR2 (1) DEFAULT 'P'
);

--TABLESPACE orcl_users;
/

CREATE UNIQUE INDEX orcl.uq_orcl_message_notifier
   ON orcl.message_notifier (id);

--TABLESPACE orcl_users;
/

CREATE INDEX orcl.ix_orcl_message_notifier_site
   ON orcl.message_notifier (siteid);

--TABLESPACE orcl_users;
/

-- drop table orcl.message_stats;

CREATE TABLE orcl.message_stats
(
   siteid       NUMBER,
   equipid      NUMBER,
   mindt        TIMESTAMP,
   maxdt        TIMESTAMP,
   totalCount   NUMBER
);

--TABLESPACE orcl_users;
/

CREATE UNIQUE INDEX orcl.uq_orcl_message_stats
   ON orcl.message_stats (siteid, equipid);

--TABLESPACE orcl_users;
/

CREATE OR REPLACE TRIGGER orcl.trbi_orcl_messages
   BEFORE INSERT
   ON orcl.messages
   FOR EACH ROW
DECLARE
   lrowseq   INT;
BEGIN
   SELECT message_seq.NEXTVAL INTO lrowseq FROM DUAL;

   :new.id := lrowseq;

   IF :new.inout = 1
   THEN
      :new.pending := 'P';
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/

CREATE OR REPLACE TRIGGER orcl.TRAI_orcl_messages
   AFTER INSERT
   ON orcl.messages
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
   lcount   NUMBER := 0;
BEGIN
   lcount := 0;

   SELECT COUNT (*)
     INTO lcount
     FROM orcl.message_stats
    WHERE siteid = :new.siteid AND equipid = :new.equipid;

   IF lcount = 0
   THEN
      INSERT INTO orcl.message_stats (siteid,
                                      equipid,
                                      mindt,
                                      maxdt,
                                      totalcount)
           VALUES (:new.siteid,
                   :new.equipid,
                   :new.dtg,
                   :new.dtg,
                   1);
   ELSE
      UPDATE orcl.message_stats
         SET maxdt = CASE WHEN maxdt < :new.dtg THEN :new.dtg ELSE maxdt END,
             totalcount = totalcount + 1
       WHERE siteid = :new.siteid AND equipid = :new.equipid;
   END IF;

   IF :new.inout = 1
   THEN
      lcount := 0;

      SELECT COUNT (*)
        INTO lcount
        FROM orcl.message_notifier
       WHERE siteid = :new.siteid;

      IF lcount = 0
      THEN
         INSERT INTO orcl.message_notifier (siteid, messageid)
              VALUES (:new.siteid, :new.id);
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/


CREATE OR REPLACE TRIGGER orcl.trbi_message_notifier
   BEFORE INSERT
   ON orcl.message_notifier
   FOR EACH ROW
DECLARE
   lrowseq   INT;
BEGIN
   SELECT message_notifier_seq.NEXTVAL INTO lrowseq FROM DUAL;

   :new.id := lrowseq;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/


CREATE OR REPLACE PROCEDURE pMessageStore (isiteid    IN     NUMBER,
                                           iequipid   IN     NUMBER,
                                           idtg       IN     TIMESTAMP,
                                           imsg       IN     VARCHAR2,
                                           omsgid        OUT NUMBER)
AS
   err_code   NUMBER;
   err_msg    VARCHAR2 (1024);
BEGIN
   omsgid := 0;

   INSERT INTO orcl.messages (siteid,
                              equipid,
                              dtg,
                              msgtext)
        VALUES (isiteid,
                iequipid,
                idtg,
                imsg)
     RETURNING id
          INTO omsgid;
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE pGetPendingNotifierCount (
   isiteid   IN     NUMBER,
   ocount       OUT NUMBER)
AS
   err_code   NUMBER;
   err_msg    VARCHAR2 (1024);
BEGIN
   ocount := 0;

   SELECT COUNT (*)
     INTO ocount
     FROM orcl.message_notifier
    WHERE    (pending = 'P' AND isiteid = 0)
          OR (pending IN ('W', 'P') AND siteid = isiteid);
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE pGetPendingNotifier (ositeid   OUT NUMBER,
                                                 ositeip   OUT VARCHAR2)
AS
   err_code   NUMBER;
   err_msg    VARCHAR2 (1024);
BEGIN
   ositeid := 0;
   ositeip := '0.0.0.0';

      UPDATE orcl.message_notifier
         SET pending = 'W'
       WHERE pending = 'P' AND ROWNUM = 1
   RETURNING siteid
        INTO ositeid;

   IF ositeid > 0
   THEN
      SELECT ip
        INTO ositeip
        FROM orcl.site
       WHERE siteid = ositeid;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE pClearPendingNotifier (isiteid IN NUMBER)
AS
   err_code   NUMBER;
   err_msg    VARCHAR2 (1024);
BEGIN
   IF isiteid = 0
   THEN
      UPDATE orcl.messages
         SET PENDING = 'I'
       WHERE     siteid IN (SELECT DISTINCT siteid FROM orcl.message_notifier)
             AND inout = 1;

      DELETE orcl.message_notifier;
   ELSE
      UPDATE orcl.messages
         SET PENDING = 'E'
       WHERE siteid = isiteid AND inout = 1 AND pending = 'P';

      DELETE orcl.message_notifier
       WHERE siteid = isiteid;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE pUpdatePendingNotifier (isiteid      IN NUMBER,
                                                    imessageid   IN NUMBER)
AS
   err_code   NUMBER;
   err_msg    VARCHAR2 (1024);
BEGIN
   IF imessageid > 0
   THEN
      UPDATE orcl.messages
         SET PENDING = 'C'
       WHERE id = imessageid;
   END IF;

   IF imessageid = 0
   THEN
      pClearPendingNotifier (isiteId);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE pRetrievePendingNotifier (
   isiteid        IN     NUMBER,
   omessageid        OUT NUMBER,
   oequipmentid      OUT NUMBER,
   omessage          OUT VARCHAR2)
AS
   err_code   NUMBER;
   err_msg    VARCHAR2 (1024);
BEGIN
     SELECT id, equipid, msgtext
       INTO omessageid, oequipmentid, omessage
       FROM orcl.messages
      WHERE siteid = isiteid AND inout = 1 AND pending = 'P' AND ROWNUM = 1
   ORDER BY ID;
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE pMessageForwarder (isiteid   IN     NUMBER,
                                               istatus      OUT NUMBER)
AS
   TYPE messageIdTyp IS TABLE OF orcl.messages.messageid%TYPE;

   message_tab     orcl.messages%ROWTYPE;
   messageid_tab   messageidtyp;

   CONN            UTL_TCP.connection;
   siteip          VARCHAR2 (25);
   equipid         NUMBER;
   siteport        NUMBER;

   rvalue          PLS_INTEGER;
   odata           VARCHAR2 (250);
   odatalen        PLS_INTEGER;
   idata           VARCHAR2 (25);
   err_code        NUMBER;
   err_msg         VARCHAR2 (1024);
BEGIN
      -- get all outgoing pending messages for the site id
      --SELECT * BULK COLLECT INTO message_tab FROM orcl.messages where siteid = isiteid ORDER by messageid;
      UPDATE orcl.messages
         SET pending = 'W'
       WHERE siteid = isiteid AND pending = 'P' AND inout = 'O'
   RETURNING messageid
        BULK COLLECT INTO messageid_tab;

   COMMIT;

   IF (messageid_tab.COUNT > 0)
   THEN
      FOR xndx IN 1 .. messageid_tab.COUNT
      LOOP
         SELECT *
           INTO message_tab
           FROM orcl.messages a
          WHERE a.messageid = messageid_tab (xndx).messageid;

         FOR indx IN 1 .. message_tab.COUNT
         LOOP
            conn :=
               UTL_TCP.open_connection (remote_host   => ipaddr,
                                        remote_port   => port,
                                        charset       => 'US7ASCII');

            odatalen := UTL_TCP.write_line (conn, message_tab (indx).MESSAGE);
            idata := UTL_TCP.get_line (conn);

            UTL_TCP.close_connection (conn);
         END LOOP;
      END LOOP;

      -- clear the indicators (all rows processed)
      UPDATE orcl.messages
         SET pending = 'C'
       WHERE messageid IN (SELECT * FROM TABLE (messageid_tab));

      COMMIT;
   END IF;

   message_tab.clear ();
   messageid_tab.clear ();
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END pMessageForwarder;
/

-- java -jar NCSMessageProcessorTest01.jar 127.0.0.1 3200
-- total expected messages: (@7500 msg per site per day) 637500 total per hour 26562.5 total per site 312.5
-- MINDATE,MAXDATE,TCOUNT,AVGSITE,AVGDAYS,SITES,DT

-- BASE TEST

-- 7500     MSG TEST    (1 DAY)
-- 20131112131947    20131112133516    1275000    7500    1    170    +00 00:15:29.000000 <C# CODE>
-- 20140218193111    20140218195646    3000000    7500    1    400    +00 00:25:35.000000 <Java Code>

-- LEN<=25    337500
-- LEN>100<=125    405000
-- LEN>125<=150    345000
-- LEN>150<=175    405000
-- LEN>175<=200    352500
-- LEN>200<=225    0
-- LEN>225<=250    0
-- LEN>250    0
-- LEN>25<=50    420000
-- LEN>50<=75    472500
-- LEN>75<=100    420000

-- 7500   MSG TEST    (15 DAY)
-- 20131112135705    20131112181803    19125000    112500    15    170    +00 04:20:58.000000 <C# CODE>
-- 20140219150051    20140219215223    45000000    112500    15    400    +00 06:51:32.000000 <Java Code>
-- 20140220150125    20140220225243    45000000    112500    15    400    +00 07:51:18.000000 <Java Code>
-- 20140305231231    20140306070218    45000000    112500    15    400    +00 07:49:47.000000 <Java Code>

-- LEN<=25    4837500
-- LEN>100<=125    5850000
-- LEN>125<=150    5962500
-- LEN>150<=175    5850000
-- LEN>175<=200    6412500
-- LEN>200<=225    0
-- LEN>225<=250    0
-- LEN>250    0
-- LEN>25<=50    5400000
-- LEN>50<=75    6187500
-- LEN>75<=100    5625000

-- LEN<=25    4275000
-- LEN>100<=125    6300000
-- LEN>125<=150    4950000
-- LEN>150<=175    5737500
-- LEN>175<=200    5175000
-- LEN>200<=225    0
-- LEN>225<=250    0
-- LEN>250    0
-- LEN>25<=50    7425000
-- LEN>50<=75    6412500
-- LEN>75<=100    6637500

-- 7500   MSG TEST    (30 DAY)
-- 20131113075623    20131113164932    38250000    225000    30    170    +00 08:53:09.000000 <C# CODE>

-- 7500   MSG TEST    (90 DAY)
-- 20131114082009    20131115104138    114750000    675000    90    170    +01 02:21:29.000000 <C# CODE>

-- connection pool management

SELECT *
  FROM v$session
 WHERE program LIKE 'JDBC%';

-- truncate table orcl.messages;
-- truncate table orcl.MESSAGE_STATS;

SELECT mindt,
       maxdt,
       tcount,
       (avgSite / sites),
       ROUND ( (avgSite / sites) / 7500, 2) avgDays,
       sites,
       maxdt - mindt dt
  FROM (SELECT MIN (DTG) mindt,
               MAX (dtg) maxdt,
               COUNT (*) tcount,
               COUNT (DISTINCT site_id) sites,
               ROUND (COUNT (*) / COUNT (DISTINCT site_id), 2) avgSite
          FROM ncs3.vwmessage);

  SELECT site_id,
         MIN (dtg) mindt,
         MAX (dtg) maxdt,
         COUNT (*) tcount,
         ROUND (COUNT (*) / 15, 2) avgSite
    FROM ncs3.vwmessage
GROUP BY site_id;

SELECT MIN (dtg) mindt,
       MAX (dtg) maxdt,
       COUNT (*) tcount,
       COUNT (DISTINCT site_id) sites,
       ROUND (COUNT (*) / COUNT (DISTINCT site_id), 2) avgSite
  FROM ncs3.vwmessage;

SELECT mindt,
       maxdt,
       tcount,
       (avgSite / sites),
       ROUND ( (avgSite / sites) / 7500, 2) avgDays,
       sites,
       maxdt - mindt dt
  FROM (SELECT MIN (DT_MIN) mindt,
               MAX (DT_MAX) maxdt,
               SUM (total_recs) tcount,
               COUNT (DISTINCT site_id) sites,
               ROUND (SUM (total_recs) / COUNT (DISTINCT site_id), 2) avgSite
          FROM ncs3.vwMESSAGE_STATS);

SELECT * FROM NCS3.vwMESSAGE_STATS;

SELECT TO_CHAR (dtg, 'yyyy/MM/dd hh24:mm:ss') FROM ncs3.vwmessage;

SELECT TO_CHAR (SYSDATE, 'yyyy/MM/dd hh24:mm:ss') FROM DUAL;

SELECT COUNT (*) FROM ncs3.vwmessage;

  SELECT *
    FROM ncs3.vwmessage
ORDER BY message_id;

  SELECT *
    FROM ncs3.vwmessage
ORDER BY dtg DESC;

  SELECT *
    FROM ncs3.vwmessage
ORDER BY msgtext DESC;

  SELECT site_id, COUNT (*)
    FROM ncs3.vwmessage
GROUP BY site_id;

  SELECT site_id, COUNT (*)
    FROM ncs3.vwmessage
GROUP BY site_id
  HAVING COUNT (*) < ROUND (COUNT (*) / COUNT (DISTINCT site_id), 2);
  
SELECT 'LEN<=25' lenstep, COUNT (*) lencount
  FROM ncs3.vwmessage
 WHERE LENGTH (msgtext) BETWEEN 1 AND 25
UNION
SELECT 'LEN>25<=50' lenstep, COUNT (*) lencount
  FROM orcl.messages
 WHERE LENGTH (msgtext) BETWEEN 25 AND 50
UNION
SELECT 'LEN>50<=75' lenstep, COUNT (*) lencount
  FROM orcl.messages
 WHERE LENGTH (msgtext) BETWEEN 50 AND 75
UNION
SELECT 'LEN>75<=100' lenstep, COUNT (*) lencount
  FROM orcl.messages
 WHERE LENGTH (msgtext) BETWEEN 75 AND 100
UNION
SELECT 'LEN>100<=125' lenstep, COUNT (*) lencount
  FROM orcl.messages
 WHERE LENGTH (msgtext) BETWEEN 100 AND 125
UNION
SELECT 'LEN>125<=150' lenstep, COUNT (*) lencount
  FROM orcl.messages
 WHERE LENGTH (msgtext) BETWEEN 125 AND 150
UNION
SELECT 'LEN>150<=175' lenstep, COUNT (*) lencount
  FROM orcl.messages
 WHERE LENGTH (msgtext) BETWEEN 150 AND 175
UNION
SELECT 'LEN>175<=200' lenstep, COUNT (*) lencount
  FROM orcl.messages
 WHERE LENGTH (msgtext) BETWEEN 175 AND 200
UNION
SELECT 'LEN>200<=225' lenstep, COUNT (*) lencount
  FROM orcl.messages
 WHERE LENGTH (msgtext) BETWEEN 200 AND 225
UNION
SELECT 'LEN>225<=250' lenstep, COUNT (*) lencount
  FROM orcl.messages
 WHERE LENGTH (msgtext) BETWEEN 225 AND 250
UNION
SELECT 'LEN>250' lenstep, COUNT (*) lencount
  FROM orcl.messages
 WHERE LENGTH (msgtext) > 250;

-- Otherwise, multiply the value •by 24 for hours
-- •by 1440 for minutes
-- •by 86400 for seconds

SELECT TO_TIMESTAMP (
             SUBSTR (dtg, 1, 4)
          || '/'
          || SUBSTR (dtg, 5, 2)
          || '/'
          || SUBSTR (dtg, 7, 2)
          || ' '
          || SUBSTR (dtg, 9, 2)
          || ':'
          || SUBSTR (dtg, 11, 2)
          || ':'
          || SUBSTR (dtg, 13, 2),
          'yyyy/mm/dd hh24:mi:ss')
          dt
  FROM orcl.messages
 WHERE ROWNUM < 10;



/* scripts to validate notifier */

  SELECT *
    FROM orcl.messages
ORDER BY dtg DESC;

SELECT *
  FROM orcl.messages
 WHERE inout = 1 AND pending = 'N';

SELECT *
  FROM orcl.messages
 WHERE inout = 1 AND pending = 'C';

SELECT *
  FROM orcl.messages
 WHERE inout = 1 AND pending = 'P';

SELECT *
  FROM orcl.messages
 WHERE inout = 1 AND pending = 'E';

SELECT *
  FROM orcl.messages
 WHERE pending != 'N';

SELECT * FROM orcl.message_notifier;

INSERT INTO orcl.messages (siteid,
                           dtg,
                           equipid,
                           msgtext,
                           inout)
     VALUES (792,
             SYSDATE,
             4033,
             '$PRCM,1,RSIM     -> Begin burning process (sending back)',
             1);

COMMIT;



SELECT COUNT (*)
  FROM orcl.message_notifier
 WHERE pending = 'P' AND ( (792 = 0) OR (siteid = 792));
/

--delete ncs3.message;
--commit;
--truncate table ncs3.message_stats;

SELECT COUNT (*) / 5,
       SUM (total_records),
       (SUM (total_records) / (COUNT (*) / 5)) / 7500
  FROM ncs3.message_stats;

SELECT * FROM ncs3.message_stats;

SELECT COUNT (*) FROM ncs3.MESSAGE;

  SELECT max(dtg)
    FROM ncs3.MESSAGE a
         INNER JOIN ncs3.equipment b ON b.equipment_id = a.equipment_id
         INNER JOIN ncs3.equipment_type c
            ON c.equipment_type_id = b.equipment_type_id
   WHERE site_id = 820 AND c.equipment_type = 4036
ORDER BY site_id;

  SELECT DISTINCT SITE_ID
    FROM ncs3.MESSAGE a
         INNER JOIN ncs3.equipment b ON b.equipment_id = a.equipment_id
ORDER BY site_id;

SELECT *
  FROM ncs3.message_stats
 WHERE total_records > 40;


SELECT *
  FROM equipment
 WHERE ip_address = 'localhost';

-- 832    9    90    STURGEON BAY    SRB

SELECT *
  FROM site
 WHERE site_id = 832;

  SELECT *
    FROM equipment
   WHERE site_id = 832
ORDER BY site_id;
/

DECLARE
   lcount   NUMBER := 5000;
BEGIN
   FOR dsite IN (SELECT site_id, REPLACE (site, ' ') site, icon_name
                   FROM ncs3.site
                  WHERE icon_name != 'U-D')
   LOOP
      lcount := lcount + 1;
      DBMS_OUTPUT.put_line (
            'add bcsMessageService '
         || dsite.icon_name
         || 'MessageService '
         || lcount
         || ' service.site.name='
         || dsite.site
         || ' service.site.id='
         || dsite.site_id);
   END LOOP;
END;
/

DECLARE
   lcount   NUMBER := 5000;
BEGIN
   FOR dsite IN (SELECT site_id, REPLACE (site, ' ') site, icon_name
                   FROM ncs3.site
                  WHERE icon_name != 'U-D')
   LOOP
      lcount := lcount + 1;
      DBMS_OUTPUT.put_line ('start ' || lcount);
   END LOOP;
END;
/