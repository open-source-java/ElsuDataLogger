/* Formatted on 5/3/2014 8:08:29 PM (QP5 v5.256.13226.35510) */
/* debug support for sp */
/* Formatted on 5/4/2014 12:27:25 PM (QP5 v5.256.13226.35510) */
CREATE TABLE ncs3.debug_output
(
   debug_output_id   NUMBER,
   debug_message     VARCHAR2 (4000),
   debug_dtg         TIMESTAMP DEFAULT SYSDATE NOT NULL
);

ALTER TABLE NCS3.debug_output ADD CONSTRAINT PK_debug_output PRIMARY KEY (debug_output_id) USING INDEX TABLESPACE  NCS3_MESSAGES;
/


DROP SEQUENCE NCS3.debug_output_seq
/

CREATE SEQUENCE NCS3.debug_output_seq MINVALUE 1
                                      MAXVALUE 999999999999999999999999999
                                      START WITH 1
                                      INCREMENT BY 1
                                      CYCLE
                                      NOCACHE
/

CREATE OR REPLACE TRIGGER TRBI_debug_output
   BEFORE INSERT
   ON NCS3.debug_output
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
BEGIN
   IF :NEW.debug_output_ID IS NULL OR :NEW.debug_output_ID = 0
   THEN
      :NEW.debug_output_ID := NCS3.debug_output_seq.NEXTVAL;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/

/* Table Equipment_Type
	- add field for shortname
	- add Control Station as equipment
*/

ALTER TABLE ncs3.equipment_type
   ADD shortname VARCHAR2 (5) NOT NULL;
/

CREATE UNIQUE INDEX NCS3.UQ_EQUIPMENT_TYPE_SHORTNAME
   ON NCS3.EQUIPMENT_TYPE (SHORTNAME)
   TABLESPACE NCS3_LOOKUP_INDEX
/

UPDATE ncs3.equipment_type
   SET shortname = 'TD'
 WHERE equipment_type = 4033;                                                                                                                                                                                                 -- description = 'Transmitter'

UPDATE ncs3.equipment_type
   SET shortname = 'RSA'
 WHERE equipment_type = 4034;                                                                                                                                                                                                  -- description =	REFERENCE STATION (RS A)

UPDATE ncs3.equipment_type
   SET shortname = 'IMA'
 WHERE equipment_type = 4035;                                                                                                                                                                                                  -- description =	INTEGRITY MONITOR (IM A)

UPDATE ncs3.equipment_type
   SET shortname = 'RSB'
 WHERE equipment_type = 4036;                                                                                                                                                                                                  -- description =	REFERENCE STATION (RS B)

UPDATE ncs3.equipment_type
   SET shortname = 'IMB'
 WHERE equipment_type = 4037;                                                                                                                                                                                                  -- description =	INTEGRITY MONITOR (IM B)

INSERT INTO ncs3.equipment_type (equipment_type, description, shortname)
     VALUES (0, 'CONTROL STATION', 'CS');

COMMIT;
/

/* TABLE Message_Destination
 - DELETE
*/

ALTER TABLE ncs3.MESSAGE
   DROP CONSTRAINT FK_MESSAGE_MESSAGEDESTINATION;

DROP TABLE message_destination;
/

/* TABLE MESSAGE
 - DELETE Message_Destination_Id
 - UPDATE TRIGGER TO specify MESSAGE_CODE ON BEFORE INSERT
*/

ALTER TABLE ncs3.MESSAGE DROP COLUMN message_destination_id;
/

/* update original table to be varchar2(1) */

UPDATE ncs3.MESSAGE_CODE
   SET MESSAGE_CODE = SUBSTR (MESSAGE_CODE, 1, 1);

COMMIT;
/

CREATE OR REPLACE TRIGGER NCS3.TRBI_MESSAGE
   BEFORE INSERT
   ON NCS3.MESSAGE
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
BEGIN
   IF :NEW.MESSAGE_ID IS NULL OR :NEW.MESSAGE_ID = 0
   THEN
      :NEW.MESSAGE_ID := NCS3.MESSAGE_seq.NEXTVAL;
   END IF;

   IF :NEW.IS_OUTBOUND = 'Y'
   THEN
      SELECT MESSAGE_CODE_ID
        INTO :NEW.MESSAGE_CODE_ID
        FROM MESSAGE_CODE
       WHERE MESSAGE_CODE = 'N';
   ELSE
      SELECT MESSAGE_CODE_ID
        INTO :NEW.MESSAGE_CODE_ID
        FROM MESSAGE_CODE
       WHERE MESSAGE_CODE = 'P';
   END IF;

   :NEW.DATE_CREATED := SYSDATE;
   :NEW.DATE_UPDATED := :NEW.DATE_CREATED;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/


/* TABLE MESSAGE_CODE
 - DELETE WHERE MESSAGE_CODE = 'OM'
 - UPDATE processing
*/

DELETE ncs3.MESSAGE_CODE
 WHERE MESSAGE_CODE = 'O';

UPDATE MESSAGE_CODE
   SET description = 'PENDING MESSAGE'
 WHERE MESSAGE_CODE = 'P';

UPDATE MESSAGE_CODE
   SET description = 'ERROR MESSAGE'
 WHERE MESSAGE_CODE = 'I';

UPDATE MESSAGE_CODE
   SET MESSAGE_CODE = 'E'
 WHERE MESSAGE_CODE = 'I';

INSERT INTO ncs3.MESSAGE_CODE (MESSAGE_CODE, description)
     VALUES ('I', 'IN PROCESSING');

COMMIT;


/* TABLE Message_Notifier
 - ADD TABLE
 - COLUMNS (message_notifier_id, message_id, MESSAGE_CODE)
*/

DROP SEQUENCE NCS3.MESSAGE_NOTIFIER_seq
/

CREATE SEQUENCE NCS3.MESSAGE_NOTIFIER_seq MINVALUE 1
                                          MAXVALUE 999999999999999999999999999
                                          START WITH 1
                                          INCREMENT BY 1
                                          CYCLE
                                          NOCACHE
/

DROP TABLE ncs3.message_notifier;
/

CREATE TABLE ncs3.message_notifier
(
   message_notifier_id   NUMBER,
   site_id               NUMBER,
   message_code_id       NUMBER,
   date_created          TIMESTAMP,
   date_updated          TIMESTAMP
)
TABLESPACE NCS3_MESSAGES;
/

CREATE UNIQUE INDEX ncs3.uq_message_notifier
   ON ncs3.message_notifier (message_notifier_id)
   TABLESPACE NCS3_MESSAGES_INDEX;
/

CREATE INDEX ncs3.ix_message_notifier_site
   ON ncs3.message_notifier (site_id)
   TABLESPACE NCS3_MESSAGES_INDEX;
/

CREATE OR REPLACE TRIGGER NCS3.TRBU_MESSAGE_NOTIFIER
   BEFORE UPDATE
   ON NCS3.MESSAGE_NOTIFIER
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
BEGIN
   :NEW.DATE_UPDATED := SYSDATE;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/

/* TABLE Message_Stats
 - CREATE THE stats TABLE
*/

DROP TABLE ncs3.message_stats;
/

CREATE TABLE ncs3.message_stats
(
   message_stats_id   NUMBER,
   equipment_id       NUMBER,
   date_min           TIMESTAMP,
   date_max           TIMESTAMP,
   total_records      NUMBER,
   date_created       TIMESTAMP,
   date_updated       TIMESTAMP
)
TABLESPACE NCS3_MESSAGES;
/

ALTER TABLE NCS3.message_stats ADD CONSTRAINT PK_MESSAGE_STATS PRIMARY KEY (message_stats_id) USING INDEX TABLESPACE  NCS3_MESSAGES_INDEX;
/

CREATE UNIQUE INDEX ncs3.uq_message_stats_equipment
   ON ncs3.message_stats (equipment_id)
   TABLESPACE NCS3_MESSAGES_INDEX;
/

DROP SEQUENCE NCS3.MESSAGE_STATS_seq
/

CREATE SEQUENCE NCS3.MESSAGE_STATS_seq MINVALUE 1
                                          MAXVALUE 999999999999999999999999999
                                          START WITH 1
                                          INCREMENT BY 1
                                          CYCLE
                                          NOCACHE
/

CREATE OR REPLACE TRIGGER TRBI_MESSAGE_STATS
   BEFORE INSERT
   ON NCS3.MESSAGE_STATS
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
BEGIN
   IF :NEW.MESSAGE_STATS_ID IS NULL OR :NEW.MESSAGE_STATS_ID = 0
   THEN
      :NEW.MESSAGE_STATS_ID := NCS3.MESSAGE_STATS_seq.NEXTVAL;
   END IF;

   :NEW.DATE_CREATED := SYSDATE;
   :NEW.DATE_UPDATED := :NEW.DATE_CREATED;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/

CREATE OR REPLACE TRIGGER TRBU_MESSAGE_STATS
   BEFORE UPDATE
   ON NCS3.MESSAGE_STATS
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
BEGIN
   :NEW.DATE_UPDATED := SYSDATE;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/

CREATE OR REPLACE TRIGGER ncs3.TRAI_message
   AFTER INSERT
   ON ncs3.MESSAGE
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
   lcount    NUMBER := 0;
   lsiteid   NUMBER := 0;
BEGIN
   lcount := 0;

   IF :new.is_outbound = 'N'
   THEN
      SELECT COUNT (*)
        INTO lcount
        FROM ncs3.message_stats
       WHERE equipment_id = :new.equipment_id;

      IF lcount = 0
      THEN
         INSERT INTO ncs3.message_stats (equipment_id,
                                         Date_min,
                                         Date_max,
                                         total_records)
              VALUES (:new.equipment_id,
                      :new.dtg,
                      :new.dtg,
                      1);
      ELSE
         UPDATE ncs3.message_stats
            SET Date_max =
                   CASE
                      WHEN Date_max < :new.dtg THEN :new.dtg
                      ELSE Date_max
                   END,
                total_records = total_records + 1
          WHERE equipment_id = :new.equipment_id;
      END IF;
   ELSE
      SELECT site_id
        INTO lsiteid
        FROM ncs3.equipment
       WHERE equipment_id = :new.equipment_id;

      SELECT COUNT (*)
        INTO lcount
        FROM ncs3.message_notifier
       WHERE site_id = lsiteid;

      IF lcount = 0
      THEN
         INSERT INTO ncs3.message_notifier (site_id)
              VALUES (lsiteid);
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/

CREATE OR REPLACE TRIGGER ncs3.trbi_message_notifier
   BEFORE INSERT
   ON ncs3.message_notifier
   FOR EACH ROW
DECLARE
   lrowseq          INT;
   lmessagecodeid   NUMBER;
BEGIN
   SELECT message_notifier_seq.NEXTVAL INTO lrowseq FROM DUAL;

   :new.message_notifier_id := lrowseq;

   SELECT message_code_id
     INTO :new.message_code_id
     FROM ncs3.MESSAGE_CODE
    WHERE MESSAGE_CODE = 'P';

   :NEW.DATE_CREATED := SYSDATE;
   :NEW.DATE_UPDATED := :NEW.DATE_CREATED;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/


CREATE OR REPLACE PROCEDURE NCS3.pMessageStore (
   isite_id          IN     NUMBER,
   iequipment_type   IN     NUMBER,
   idtg              IN     TIMESTAMP,
   imessage_text     IN     VARCHAR2,
   ioutbound         IN     VARCHAR2,
   omessage_id          OUT NUMBER)
AS
   lequipmentid   NUMBER;
   lrsimnbr       NUMBER;
   lonline        VARCHAR2 (1) := 'Y';
   err_code       NUMBER;
   err_msg        VARCHAR2 (1024);
BEGIN
   omessage_id := 0;

   -- should be a view --
   SELECT a.equipment_id
     INTO lequipmentid
     FROM ncs3.equipment a
          INNER JOIN ncs3.equipment_type b
             ON b.equipment_type_id = a.equipment_type_id
    WHERE site_id = isite_id AND b.equipment_type = iequipment_type;

   SELECT rsim_number_id
     INTO lrsimnbr
     FROM ncs3.rsim_number
    WHERE rsim_number =
             TO_NUMBER (REPLACE (SUBSTR (imessage_text, 7, 2), ',', ''));

   -- default message_code_id is set in trigger
   INSERT INTO ncs3.MESSAGE (equipment_id,
                             dtg,
                             is_outbound,
                             is_online,
                             rsim_number_id,
                             MESSAGE_TEXT)
        VALUES (lequipmentid,
                idtg,
                ioutbound,
                lonline,
                lrsimnbr,
                imessage_text)
     RETURNING message_id
          INTO omessage_id;
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/


/* test scripts for message store
DECLARE
   lrecid   NUMBER := 0;
BEGIN
   NCS3.pMessageStore (
      792,
      4033,
      TO_TIMESTAMP ('2014/05/04 11:58:16.326', 'YYYY/MM/DD HH24:MI:SS.FF'),
      '$PRCM,28,RSIM User Name    : Hewlett-Packard Company',
      'N',
      lrecid);
   DBMS_OUTPUT.PUT_LINE (lrecid);
   COMMIT;
END;
/

SELECT * FROM ncs3.MESSAGE;

SELECT * FROM ncs3.message_stats;

SELECT * FROM ncs3.debug_output;
DELETE ncs3.debug_output;
commit;

SELECT TO_TIMESTAMP ('2014/05/04 11:58:16.326', 'YYYY/MM/DD HH24:MI:SS.FF')
  FROM DUAL;

SELECT SUBSTR ('$PRCM,1,RSIM User Name    : Hewlett-Packard Company', 7, 2)
  FROM DUAL
/
*/

CREATE OR REPLACE PROCEDURE ncs3.pGetPendingNotifierCount (
   isite_id   IN     NUMBER,
   ocount        OUT NUMBER)
AS
   err_code   NUMBER;
   err_msg    VARCHAR2 (1024);
BEGIN
   ocount := 0;

   SELECT COUNT (*)
     INTO ocount
     FROM ncs3.message_notifier a
          INNER JOIN ncs3.MESSAGE_CODE b
             ON b.message_code_id = a.message_code_id
    WHERE    (b.MESSAGE_CODE = 'P' AND isite_id = 0)
          OR (b.MESSAGE_CODE IN ('I', 'P') AND a.site_id = isite_id);
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE ncs3.pGetPendingNotifier (
   osite_id   OUT NUMBER,
   osite_ip   OUT VARCHAR2)
AS
   err_code   NUMBER;
   err_msg    VARCHAR2 (1024);
BEGIN
   osite_id := 0;
   osite_ip := '0.0.0.0';

      UPDATE ncs3.message_notifier
         SET message_code_id =
                (SELECT message_code_id
                   FROM ncs3.MESSAGE_CODE
                  WHERE MESSAGE_CODE = 'I')
       WHERE     message_code_id = (SELECT message_code_id
                                      FROM ncs3.MESSAGE_CODE
                                     WHERE MESSAGE_CODE = 'P')
             AND ROWNUM = 1
   RETURNING site_id
        INTO osite_id;

   IF osite_id != 0
   THEN
      SELECT IP_ADDRESS
        INTO osite_ip
        FROM ncs3.equipment
       WHERE site_id = osite_id AND ROWNUM = 1;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE ncs3.pClearPendingNotifier (isite_id IN NUMBER)
AS
   err_code   NUMBER;
   err_msg    VARCHAR2 (1024);
BEGIN
   IF isite_id = 0
   THEN
      UPDATE ncs3.MESSAGE a
         SET a.MESSAGE_CODE_ID =
                (SELECT message_code_id
                   FROM ncs3.MESSAGE_CODE
                  WHERE MESSAGE_CODE = 'E')
       WHERE     a.equipment_id IN (SELECT DISTINCT b.equipment_id
                                      FROM ncs3.equipment b
                                     WHERE b.site_id IN (SELECT DISTINCT
                                                                site_id
                                                           FROM ncs3.message_notifier))
             AND is_outbound = 'Y';

      DELETE ncs3.message_notifier;
   ELSE
      UPDATE ncs3.MESSAGE a
         SET a.MESSAGE_CODE_ID =
                (SELECT message_code_id
                   FROM ncs3.MESSAGE_CODE
                  WHERE MESSAGE_CODE = 'E')
       WHERE     a.equipment_id IN (SELECT DISTINCT b.equipment_id
                                      FROM ncs3.equipment b
                                     WHERE b.site_id = isite_id)
             AND is_outbound = 'Y'
             AND message_code_id = (SELECT message_code_id
                                      FROM ncs3.MESSAGE_CODE
                                     WHERE MESSAGE_CODE = 'N');

      DELETE ncs3.message_notifier
       WHERE site_id = isite_id;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE ncs3.pUpdatePendingNotifier (
   isite_id      IN NUMBER,
   imessage_id   IN NUMBER)
AS
   err_code   NUMBER;
   err_msg    VARCHAR2 (1024);
BEGIN
   IF imessage_id > 0
   THEN
      UPDATE ncs3.MESSAGE
         SET message_code_id =
                (SELECT message_code_id
                   FROM ncs3.MESSAGE_CODE
                  WHERE MESSAGE_CODE = 'G')
       WHERE message_id = imessage_id;
   END IF;

   IF imessage_id = 0
   THEN
      pClearPendingNotifier (isite_id);
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/


CREATE OR REPLACE PROCEDURE ncs3.pRetrievePendingNotifier (
   isite_id        IN     NUMBER,
   omessage_id        OUT NUMBER,
   oequipment_id      OUT NUMBER,
   omessage           OUT VARCHAR2)
AS
   err_code   NUMBER;
   err_msg    VARCHAR2 (1024);
BEGIN
     SELECT a.message_id, b1.equipment_type, a.MESSAGE_TEXT
       INTO omessage_id, oequipment_id, omessage
       FROM ncs3.MESSAGE a
            INNER JOIN ncs3.equipment b ON b.equipment_ID = a.equipment_id
            INNER JOIN ncs3.equipment_type b1 ON b1.equipment_type_id = b.equipment_type_id
            INNER JOIN ncs3.site c ON c.site_id = b.site_id
      WHERE     c.site_id = isite_id
            AND a.is_outbound = 'Y'
            AND a.message_code_id = (SELECT message_code_id
                                       FROM ncs3.MESSAGE_CODE
                                      WHERE MESSAGE_CODE = 'N')
            AND ROWNUM = 1
   ORDER BY a.message_ID;
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/

/* test scripts for message notifier

UPDATE ncs3.equipment
   SET ip_address = 'localhost'
 WHERE site_id = 792;

COMMIT;
/

DECLARE
   lrecid   NUMBER := 0;
   lcount   NUMBER := 20;
BEGIN
   WHILE (lcount > 0)
   LOOP
      lcount := lcount - 1;
      NCS3.pMessageStore (
         792,
         4033,
         TO_TIMESTAMP (SYSDATE, 'YYYY/MM/DD HH24:MI:SS.FF'),
         '$PRCM,28,User Seraj Dhaliwal / Test outbound (' || lcount || ')',
         'Y',
         lrecid);
      DBMS_OUTPUT.PUT_LINE (lrecid);
      COMMIT;
   END LOOP;
END;
/

SELECT * FROM dba_change_notification_regs;

SELECT COUNT (*) FROM ncs3.MESSAGE;

  SELECT a.*, b.MESSAGE_CODE
    FROM ncs3.MESSAGE a
         INNER JOIN ncs3.MESSAGE_CODE b
            ON b.message_code_id = a.message_code_id
   WHERE is_outbound = 'Y'
ORDER BY message_id DESC;

SELECT a.*, b.MESSAGE_CODE
  FROM ncs3.message_notifier a
       INNER JOIN ncs3.MESSAGE_CODE b
          ON b.message_code_id = a.message_code_id;

*/

/* Table EVENT
-- event and supporting tables
-- update data_type to add DB_TYPE
*/

ALTER TABLE DATA_TYPE DROP COLUMN DATA_MEASUREMENT_TYPE;
/

DROP TABLE ncs3.MEASUREMENT_TYPE;
/

CREATE TABLE ncs3.MEASUREMENT_TYPE
(
   MEASUREMENT_TYPE_ID   NUMBER NOT NULL,
   MEASUREMENT_TYPE      VARCHAR2 (25) NOT NULL,
   DATE_CREATED          TIMESTAMP NOT NULL,
   DATE_UPDATED          TIMESTAMP NOT NULL
)
TABLESPACE NCS3_LOOKUP;

CREATE UNIQUE INDEX NCS3.UQ_MEASUREMENT_TYPE
   ON NCS3.MEASUREMENT_TYPE (MEASUREMENT_TYPE)
   TABLESPACE NCS3_LOOKUP_INDEX;
/

ALTER TABLE NCS3.MEASUREMENT_TYPE ADD CONSTRAINT PK_MEASUREMENT_TYPE PRIMARY KEY (MEASUREMENT_TYPE_ID) USING INDEX TABLESPACE  NCS3_LOOKUP_INDEX
/

DROP SEQUENCE NCS3.MEASUREMENT_TYPE_seq
/

CREATE SEQUENCE NCS3.MEASUREMENT_TYPE_seq MINVALUE 1
                                          MAXVALUE 999999999999999999999999999
                                          START WITH 1
                                          INCREMENT BY 1
                                          CYCLE
                                          NOCACHE
/

CREATE OR REPLACE TRIGGER NCS3.TRBU_MEASUREMENT_TYPE
   BEFORE UPDATE
   ON NCS3.MEASUREMENT_TYPE
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
BEGIN
   :NEW.DATE_UPDATED := SYSDATE;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/

CREATE OR REPLACE TRIGGER NCS3.TRBI_MEASUREMENT_TYPE
   BEFORE INSERT
   ON NCS3.MEASUREMENT_TYPE
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
BEGIN
   IF :NEW.MEASUREMENT_TYPE_ID IS NULL OR :NEW.MEASUREMENT_TYPE_ID = 0
   THEN
      :NEW.MEASUREMENT_TYPE_ID := NCS3.MEASUREMENT_TYPE_seq.NEXTVAL;
   END IF;

   :NEW.DATE_CREATED := SYSDATE;
   :NEW.DATE_UPDATED := :NEW.DATE_CREATED;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/

DROP TABLE ncs3.data_type_dbtype_ref;
/

CREATE TABLE ncs3.data_type_dbtype_ref
(
   data_type_dbtype_ref_ID   NUMBER NOT NULL,
   data_type_dbtype_ref      VARCHAR2 (25) NOT NULL,
   DATE_CREATED              TIMESTAMP NOT NULL,
   DATE_UPDATED              TIMESTAMP NOT NULL
)
TABLESPACE NCS3_LOOKUP;

CREATE UNIQUE INDEX NCS3.UQ_data_type_dbtype_ref
   ON NCS3.data_type_dbtype_ref (data_type_dbtype_ref)
   TABLESPACE NCS3_LOOKUP_INDEX;
/

ALTER TABLE NCS3.data_type_dbtype_ref ADD CONSTRAINT PK_data_type_dbtype_ref PRIMARY KEY (data_type_dbtype_ref_ID) USING INDEX TABLESPACE  NCS3_LOOKUP_INDEX
/

DROP SEQUENCE NCS3.data_type_dbtype_ref_seq
/

CREATE SEQUENCE NCS3.data_type_dbtype_ref_seq MINVALUE 1
                                              MAXVALUE 999999999999999999999999999
                                              START WITH 1
                                              INCREMENT BY 1
                                              CYCLE
                                              NOCACHE
/

CREATE OR REPLACE TRIGGER NCS3.TRBU_data_type_dbtype_ref
   BEFORE UPDATE
   ON NCS3.data_type_dbtype_ref
   REFERENCING NEW AS NEW OLD AS OLD
   FOR EACH ROW
DECLARE
BEGIN
   :NEW.DATE_UPDATED := SYSDATE;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/

CREATE OR REPLACE TRIGGER NCS3.TRBI_data_type_dbtype_ref
   BEFORE INSERT
   ON NCS3.data_type_dbtype_ref
   REFERENCING NEW AS New OLD AS Old
   FOR EACH ROW
DECLARE
BEGIN
   IF    :NEW.data_type_dbtype_ref_ID IS NULL
      OR :NEW.data_type_dbtype_ref_ID = 0
   THEN
      :NEW.data_type_dbtype_ref_ID := NCS3.data_type_dbtype_ref_seq.NEXTVAL;
   END IF;

   :NEW.DATE_CREATED := SYSDATE;
   :NEW.DATE_UPDATED := :NEW.DATE_CREATED;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE;
END;
/

DELETE ncs3.data_type;

COMMIT;
/

ALTER TABLE ncs3.data_type
   ADD data_type_dbtype_ref_id NUMBER NOT NULL;
/

INSERT INTO ncs3.data_type_dbtype_ref (data_type_dbtype_ref)
     VALUES ('VARCHAR2');

INSERT INTO ncs3.data_type_dbtype_ref (data_type_dbtype_ref)
     VALUES ('INTEGER');

INSERT INTO ncs3.data_type_dbtype_ref (data_type_dbtype_ref)
     VALUES ('TIMESTAMP');

INSERT INTO ncs3.data_type_dbtype_ref (data_type_dbtype_ref)
     VALUES ('DATE');

INSERT INTO ncs3.data_type_dbtype_ref (data_type_dbtype_ref)
     VALUES ('TIME');

INSERT INTO ncs3.data_type_dbtype_ref (data_type_dbtype_ref)
     VALUES ('NUMBER');

COMMIT;
/

DELETE ncs3.MEASUREMENT_TYPE;

INSERT INTO ncs3.MEASUREMENT_TYPE (MEASUREMENT_TYPE)
     VALUES ('COMPARE');

INSERT INTO ncs3.MEASUREMENT_TYPE (MEASUREMENT_TYPE)
     VALUES ('RANGE');

COMMIT;
/

ALTER TABLE NCS3.DATA_TYPE ADD CONSTRAINT FK_DATA_TYPE FOREIGN KEY (data_type_dbtype_ref_id) REFERENCES NCS3.data_type_dbtype_ref (data_type_dbtype_ref_id)
/


INSERT INTO data_type (data_type, data_type_dbtype_ref_id)
   SELECT 'ALPHA' data_type,
          (SELECT data_type_dbtype_ref_id
             FROM data_type_dbtype_ref
            WHERE data_type_dbtype_ref = 'VARCHAR2')
     FROM DUAL;

INSERT INTO data_type (data_type, data_type_dbtype_ref_id)
   SELECT 'INTEGER' data_type,
          (SELECT data_type_dbtype_ref_id
             FROM data_type_dbtype_ref
            WHERE data_type_dbtype_ref = 'INTEGER')
     FROM DUAL;

INSERT INTO data_type (data_type, data_type_dbtype_ref_id)
   SELECT 'ASCII HEX' data_type,
          (SELECT data_type_dbtype_ref_id
             FROM data_type_dbtype_ref
            WHERE data_type_dbtype_ref = 'VARCHAR2')
     FROM DUAL;

INSERT INTO data_type (data_type, data_type_dbtype_ref_id)
   SELECT 'TIME' data_type,
          (SELECT data_type_dbtype_ref_id
             FROM data_type_dbtype_ref
            WHERE data_type_dbtype_ref = 'TIMESTAMP')
     FROM DUAL;

INSERT INTO data_type (data_type, data_type_dbtype_ref_id)
   SELECT 'NUMERIC' data_type,
          (SELECT data_type_dbtype_ref_id
             FROM data_type_dbtype_ref
            WHERE data_type_dbtype_ref = 'NUMBER')
     FROM DUAL;

INSERT INTO data_type (data_type, data_type_dbtype_ref_id)
   SELECT 'FLOAT' data_type,
          (SELECT data_type_dbtype_ref_id
             FROM data_type_dbtype_ref
            WHERE data_type_dbtype_ref = 'NUMBER')
     FROM DUAL;

INSERT INTO data_type (data_type, data_type_dbtype_ref_id)
   SELECT 'DOUBLE' data_type,
          (SELECT data_type_dbtype_ref_id
             FROM data_type_dbtype_ref
            WHERE data_type_dbtype_ref = 'NUMBER')
     FROM DUAL;

INSERT INTO data_type (data_type, data_type_dbtype_ref_id)
   SELECT 'TEXT' data_type,
          (SELECT data_type_dbtype_ref_id
             FROM data_type_dbtype_ref
            WHERE data_type_dbtype_ref = 'VARCHAR2')
     FROM DUAL;

COMMIT;
/

DELETE data_unit;

INSERT INTO data_unit (data_unit_id, data_unit, data_unit_format)
     VALUES (-1, 'UNDEFINED', 'UNDEFINED');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Amperes', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Bits per second', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Decibel Microvolt/Meter', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Decibel/Hertz', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Decibels', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Degrees', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Degrees, Minutes', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Degress, Minutes', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('GPS Seconds', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Hours', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Hours, Minutes, Seconds', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('ID Number', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Kilo-Hertz', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Kilometers', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Mega-Hertz', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Meters', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Meters/Seconds', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('RSIM Number', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Seconds', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('UTC Seconds into Hour', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Volts', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Watts', '-');

INSERT INTO data_unit (data_unit, data_unit_format)
     VALUES ('Words', '-');

COMMIT;
/

DELETE ncs3.variable_destination;

INSERT INTO ncs3.variable_destination (variable_destination)
     VALUES ('EVENT');

INSERT INTO ncs3.variable_destination (variable_destination)
     VALUES ('SV_STATS');

INSERT INTO ncs3.variable_destination (variable_destination)
     VALUES ('DATALINK_STATS');

INSERT INTO ncs3.variable_destination (variable_destination)
     VALUES ('DGPS_STATS');

INSERT INTO ncs3.variable_destination (variable_destination)
     VALUES ('TX_STATS');

COMMIT;
/

INSERT INTO ncs3.variable_event_type (variable_event_type)
     VALUES ('ALARM');

INSERT INTO ncs3.variable_event_type (variable_event_type)
     VALUES ('INFO');

INSERT INTO ncs3.variable_event_type (variable_event_type)
     VALUES ('STATUS');

INSERT INTO ncs3.variable_event_type (variable_event_type)
     VALUES ('STATUS ALARM');

COMMIT;
/

-- insert data into rsim_variable
-- fix unique index on RSIM_VARIABLE (make is not-unique)
-- remove index for data_type_id
-- add unique index for rsim_number, sequence
-- add foreign constraints for all ids

ALTER TABLE ncs3.rsim_variable
   ADD MEASUREMENT_TYPE_ID NUMBER;

ALTER TABLE ncs3.rsim_variable
   ADD is_multiple VARCHAR2 (1) NOT NULL CHECK (is_multiple IN ('Y', 'N'));

ALTER TABLE ncs3.rsim_variable
   ADD occurance NUMBER DEFAULT 0 NOT NULL;

ALTER TABLE NCS3.rsim_variable ADD CONSTRAINT FK_MEASUREMENT_TYPE FOREIGN KEY (MEASUREMENT_TYPE_ID) REFERENCES NCS3.MEASUREMENT_TYPE (MEASUREMENT_TYPE_ID)
/

/*
="INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value, rsim_number_id, sequence, is_active, rsim_reference, description)  SELECT '"&A2&"','"&C2&"','"&D2&"','"&E2&"',(select rsim_number_id from ncs3.rsim_number where rsim_number='"&H2&"'),'"&I2&"','Y','"&J2&"','"&K2&"' FROM DUAL;"
*/

DROP INDEX UQ_RSIM_VARIABLE;

CREATE UNIQUE INDEX NCS3.UQ_RSIM_VARIABLE
   ON NCS3.RSIM_VARIABLE (rsim_number_id, RSIM_VARIABLE)
TABLESPACE  NCS3_LOOKUP_INDEX
/

INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Battery Charger Supply Current','0.0','99.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Amperes'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='24'),'9','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'TX_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'DC Supply Current','0.0','99.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Amperes'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='24'),'8','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'TX_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Broadcast Bit Rate','25','300','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Bits per second'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='10'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Broadcast Bit Rate','25','300','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Bits per second'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='14'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Broadcast Bit Rate','25','300','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Bits per second'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'11','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Broadcast Bit Rate','25','300','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Bits per second'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'12','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Signal Strength','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Decibel Microvolts/Meter'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='15'),'2','Y','N','0','8.3.1.1',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DATALINK_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Beacon SS Threshold','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Decibel Microvolts/Meter'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'5','Y','N','0','8.3.1.1',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'C No','','','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Decibel/Hertz'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='7'),'7','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Signal to Noise Ratio','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Decibels'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='15'),'3','Y','N','0','8.3.1.1',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DATALINK_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Beacon SNR Threshold','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Decibels'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'4','Y','N','0','8.3.1.1',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Azimuth','0.0','360.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Degrees'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='7'),'5','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Elevation','0.0','90.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Degrees'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='7'),'6','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Mask Angle For Broadcast','0.0','90.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Degrees'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='6'),'9','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Latitude','00000.0','9000.0','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Degrees, Minutes'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Longitude','00000.0','18000.0','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Degrees, Minutes'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Latitude','00000.0','9000.0','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Degrees, Minutes'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Longitude','00000.0','18000.0','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Degrees, Minutes'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'6','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Reference Position Latitude','0000.0','9000.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Degrees, Minutes'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='6'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Reference Position Longitude','00000.0','18000.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Degrees, Minutes'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='6'),'6','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Modified Z-Count','0.0','3599.4','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'GPS Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='13'),'9','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Modified Z-Count','0.0','3599.4','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'GPS Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='23'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Modified Z-Count','0.0','3599.4','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'GPS Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='33'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Modified Z-Count','0.0','3599.4','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'GPS Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='34'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Correction Suspension Duration','0','9','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='28'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Reset Monitoring Interval','0','9','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='28'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time Observed','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='7'),'3','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Correction Resumption Countdown','000000','090000','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='29'),'6','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time of Alarm','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='2'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time of Alarm','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='5'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Loss of Satellite Warning Time (UTC)','000000.0','235959.9','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='8'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='9'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='12'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time of Message','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='13'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='15'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DATALINK_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time of Alarm','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='17'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time of Observation','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='18'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DGPS_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='19'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='23'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='26'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time Observed','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='29'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time Observed','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='30'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='33'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='34'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time of Alarm','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='38'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time of Observation','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='39'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UTC Time','000000.00','235959.99','',(select data_type_id from ncs3.data_type where data_type = 'TIME'),(select data_unit_id from ncs3.data_unit where data_unit = 'Hours, Minutes, Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='40'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RS ID','0','1023','9999',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'ID Number'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='34'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RS ID','0','1023','9999',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'ID Number'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='6'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RS ID','0','1023','9999',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'ID Number'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='17'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RS ID','0','1023','9999',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'ID Number'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='20'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RBN Broadcast ID','0','1023','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'ID Number'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'10','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RS ID','0','1023','9999',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'ID Number'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='23'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RS ID #1','0','1023','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'ID Number'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'8','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RS ID #2','0','1023','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'ID Number'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'11','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RS ID','0','1023','9999',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'ID Number'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='33'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RS ID','0','1023','9999',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'ID Number'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='38'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Frequency','283.5','325.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Kilo-Hertz'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='10'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Monitored Beacon Broadcast Frequency','283.5','325.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Kilo-Hertz'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='14'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Frequency','283.5','325.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Kilo-Hertz'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'8','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Frequency','283.5','325.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Kilo-Hertz'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'9','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Radiobeacon Range','0','500','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Kilometers'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'7','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'External Frequency Source','1.00','21.00','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Mega-Hertz'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='6'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PRC','0.0','10486.44','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='13'),'5','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'UDRE','0.0','9.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='13'),'8','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Correction Quality Indicator','0.0','99.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='19'),'7','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PR Residual','0.0','99.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='19'),'5','Y','Y','3','8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PR Variance Estimate','0.0','99.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='19'),'8','Y','Y','3','2.1.22',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Correction Quality Indicator','0.0','99.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='40'),'7','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PR Residual','0.0','99.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='40'),'5','Y','Y','3','8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PR Variance Estimate','0.0','99.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='40'),'8','Y','Y','3','2.1.22',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'URA','','','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='7'),'8','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PRC Alarm Threshold','0.0','10486.5','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='11'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Horizontal Position Error Threshold','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'12','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PR Residual Threshold','0.0','99.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'14','Y','N','0','8.3.2.1',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Altitude Error','0.0','9999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='18'),'4','Y','N','0','8.3.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DGPS_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Latitude Error','0.0','9999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='18'),'2','Y','N','0','8.3.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DGPS_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Longitude Error','0.0','9999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='18'),'3','Y','N','0','8.3.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DGPS_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PR Residual Non-Differential Threshold','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='35'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PR Residual Non-Differential Threshold','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='37'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Altitude Error','0.0','9999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='39'),'4','Y','N','0','8.3.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Latitude Error','0.0','9999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='39'),'2','Y','N','0','8.3.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Longitude Error','0.0','9999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='39'),'3','Y','N','0','8.3.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Altitude-Ellipsoidal','','','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='6'),'8','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RRC','0.0','4.064','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters/Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='13'),'6','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RR Residual','0.0','9.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters/Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='19'),'6','Y','Y','3','1.2 8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RR Residual','0.0','9.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters/Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='40'),'6','Y','Y','3','1.2 8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PR Acceleration','','','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters/Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='13'),'7','Y','Y','3','1.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RRC Alarm Threshold','0.0','4.1','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters/Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='11'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RR Residual Threshold','0.0','9.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters/Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'16','Y','N','0','1.2 8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RRC Mask Threshold','0','9.999','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters/Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='35'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'High RR Non-Differential Threshold','0.0','9.999','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Meters/Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='37'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Incoming Unrecognized Message RSIM Number','1','30','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'RSIM Number'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='2'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Correction Age','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='19'),'9','Y','Y','3','8.3.1.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Correction Age','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='40'),'9','Y','Y','3','8.3.1.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Output Interval','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='1'),'4','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Interval','0.0','86400.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='22'),'3','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Reset Duration','0','999','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='28'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Logging Interval','0','99999','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='4'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'IM System Feedback Time Threshold','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='11'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Correction Age Average','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='15'),'5','Y','N','0','8.3.1.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DATALINK_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Beacon SNR Observation Interval','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'5','Y','N','0','8.3.1.1',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Beacon SS Observation Interval','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'6','Y','N','0','8.3.1.1',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Correction Age Observation Interval','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'20','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'HDOP Observation Interval','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'11','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Horizontal Position Error Observation Interval','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'13','Y','N','0','8.3.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Low UDRE Observation Interval','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'29','Y','N','0','8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Message Error Ratio Observation Interval','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'3','Y','N','0','8.3.1.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Number of Satellites Observation Interval','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'8','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PR Residual Observation Interval','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'15','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RR Residual Observation Interval','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'17','Y','N','0','1.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Correction Age Threshold','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'1','Y','N','0','8.3.1.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Newly Tracked SV Hold-off','0.0','3600.0','-1.0',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='35'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'High RR Non-Differential Observation Interval','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='37'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Newly Tracked SV Hold-off','0.0','3600.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='37'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Correction Age Average','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='39'),'9','Y','N','0','8.3.1.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Maximum Age Of RTCM Correction','','','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Seconds'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='6'),'10','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Synchronization Start Time','0','3599','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'UTC Seconds into Hour'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='1'),'5','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Synchronization Start Time','0','3599','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'UTC Seconds into Hour'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='22'),'4','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'DC Supply Voltage','0.0','999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Volts'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='24'),'6','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'TX_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Transmitter Output Power','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Watts'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='24'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'TX_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Transmitter Reflected Power','0.0','99999.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = 'Watts'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='24'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'TX_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Frame Length','2','33','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = 'Words'),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='23'),'6','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Correction Broadcast Status','','','B;S;R;O',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='29'),'5','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Reset Iteration Countdown','0','5','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='29'),'7','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PRN Number','1','32','99',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='7'),'4','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'SV Health','0','63','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='7'),'9','Y','Y','3','6.3.1',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'IOD','0','255','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='13'),'10','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PRN Number','1','32','99',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='13'),'4','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PRN Number','1','32','99',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='19'),'4','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PRN Number of SV Being Tracked','1','32','99',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='29'),'4','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PRN Number','1','32','99',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='40'),'4','Y','Y','3','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Control State','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='25'),'1','Y','Y','24','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Status of PRN','0','9','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='9'),'2','Y','Y','32','6.3.1',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Monitored State','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='25'),'25','Y','Y','40','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Text Message','1','255','',(select data_type_id from ncs3.data_type where data_type = 'TEXT'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='26'),'2','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Version of Firmware Module #X','1','40','',(select data_type_id from ncs3.data_type where data_type = 'TEXT'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='27'),'5','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'SV Integrity Flags','00','255','',(select data_type_id from ncs3.data_type where data_type = 'ASCII HEX'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='33'),'8','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'SV Integrity Flags','00','255','',(select data_type_id from ncs3.data_type where data_type = 'ASCII HEX'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='34'),'8','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Destination Port','1','4','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='1'),'2','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Enable','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='1'),'3','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Correction Generation Method','1','3','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='22'),'1','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RSIM Message Type Desired','1','30','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='1'),'1','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Message Type Number','1','64','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='22'),'2','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Word','0','16777215','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='23'),'8','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PRN Number','1','32','99',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='33'),'7','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PRN Number','1','32','99',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='34'),'7','Y','Y','99','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Reset Command','','','D;P;F',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='3'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'North South','','','N;S',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='6'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'East West','','','W;E',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='6'),'7','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Frequency Source','','','I;E',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='6'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'High PRC Alarm','','','H;N',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='12'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'High RRC Alarm','','','H;N',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='12'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Insufficient Satellites Alarm','','','I;S',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='12'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Unmonitored Alarm','','','F;W;U;M',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='12'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Beacon SNR Alarm','','','L;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='17'),'','Y','N','0','8.3.1.1',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Beacon SS Alarm','','','Z;L;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='17'),'','Y','N','0','8.3.1.1',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'HDOP Alarm','','','H;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='17'),'8','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'High Message Error Ration Alarm','','','H;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='17'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Horizontal Position Error Alarm','','','H;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='17'),'9','Y','N','0','8.3.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Low UDRE Alarm','','','L;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='17'),'12','Y','N','0','8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Number of Satellites Used Alarm','','','Z;L;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='17'),'7','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PR Residual Alarm','','','H;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='17'),'10','Y','N','0','8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RR Residual Alarm','','','H;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='17'),'11','Y','N','0','1.2 8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Correction Age Alarm','','','H;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='17'),'3','Y','N','0','8.3.1.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'North South','','','N;S',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'East West','','','W;E',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'6','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Operational Side','','','A;B',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='24'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'TX_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Supply Power Source','','','AC;DC',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='24'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'TX_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'North South','','','N;S',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'East West','','','W;E',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'7','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Force RS Unhealthy Override','','','Y;N',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='35'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RS Parameters Default Save','','','Y;NULL',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='35'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Configuration Change Password Enable-Disable Flag','','','E;D',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='36'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RS IM Software Exit Password Enable-Disable Flag','','','E;D',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='36'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'IM Parameter Default Save','','','Y;NULL',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='37'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'HDOP Alarm','','','H;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='38'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Horizontal Position Error Alarm','','','H;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='38'),'6','Y','N','0','8.3.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Low UDRE Alarm','','','L;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='38'),'9','Y','N','0','8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Number of Satellites Used Alarm','','','Z;L;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='38'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PR Residual Alarm','','','H;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='38'),'7','Y','N','0','8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RR Residual Alarm','','','H;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='38'),'8','Y','N','0','1.2 8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Correction Age Alarm','','','H;A',(select data_type_id from ncs3.data_type where data_type = 'ALPHA'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='38'),'3','Y','N','0','8.3.1.3',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Automatic Side Switchover Enable','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='24'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'TX_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'ASCII Diagnostic Text','1','255','',(select data_type_id from ncs3.data_type where data_type = 'TEXT'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='5'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Beacon Identifier','1','3','',(select data_type_id from ncs3.data_type where data_type = 'TEXT'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='10'),'8','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Device Serial Number','1','25','',(select data_type_id from ncs3.data_type where data_type = 'TEXT'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='27'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Version of Firmware Module #1','1','40','',(select data_type_id from ncs3.data_type where data_type = 'TEXT'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='27'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Version of Firmware Module #2','1','40','',(select data_type_id from ncs3.data_type where data_type = 'TEXT'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='27'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Version of Firmware Module #3','1','40','',(select data_type_id from ncs3.data_type where data_type = 'TEXT'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='27'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Configuration Change Password','3','12','',(select data_type_id from ncs3.data_type where data_type = 'TEXT'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='36'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RS IM Software Exit Password','3','12','',(select data_type_id from ncs3.data_type where data_type = 'TEXT'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='36'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Extended Integrity Status','00','255','',(select data_type_id from ncs3.data_type where data_type = 'ASCII HEX'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='33'),'6','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Extended Integrity Status','00','255','',(select data_type_id from ncs3.data_type where data_type = 'ASCII HEX'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='34'),'6','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Health Control Code','0','2','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='8'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Broadcast Coding','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='10'),'7','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Channel','1','2','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='10'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Modulation Mode','0','3','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='10'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Operating Mode','0','3','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='10'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Synchronization Type','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='10'),'6','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Quantity Satellites Alarm Minimum','0','9','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='11'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Broadcast Coding','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='14'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Modulation Mode','0','3','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='14'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Synchronization Type','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='14'),'4','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Number of Satellites Used Threshold','0','9','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'7','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Position Flag','0','2','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='20'),'2','Y','N','0','8.2.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Broadcast Coding','','0','1',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'14','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Health','0','3','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'9','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Modulation Mode','0','3','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'12','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Synchronization Type','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'13','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Sequence Number','0','7','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='23'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Station Health','0','7','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='23'),'7','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'TR Processor Reset','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='24'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'TX_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS ALARM'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Reset Iterations','0','5','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='28'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Integrity Mode','0','3','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='31'),'','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Broadcast Coding','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'15','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Datum','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'13','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Integrity Mode','0','2','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'16','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'MAX Number RBN (N)','0','5','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Operational Status','0','3','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'10','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Station Name','0','9','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'17','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Synchronization Type','0','1','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'14','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Position Flag','0','2','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='33'),'5','Y','N','0','8.2.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Position Flag','0','2','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='34'),'5','Y','N','0','8.2.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Message Error Ratio','0.00','1.00','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='15'),'4','Y','N','0','8.3.1.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DATALINK_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'HDOP Threshold','0.0','99.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'10','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Low UDRE Alarm Threshold','0.0','9.99','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'18','Y','N','0','8.3.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Message Error Ratio Threshold','0.00','1.00','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='16'),'2','Y','N','0','8.3.1.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'HDOP','0.0','99.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='18'),'7','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DGPS_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PDOP','0.0','99.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='18'),'6','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DGPS_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'VDOP','0.0','99.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='18'),'8','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DGPS_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'HDOP','0.0','99.0','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='39'),'7','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PDOP','0.0','99.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='39'),'6','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'VDOP','0.0','99.9','',(select data_type_id from ncs3.data_type where data_type = 'NUMERIC'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='39'),'8','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Message Number','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='7'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Total Number of Messages','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='7'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PRN Number','1','32','99',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='8'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Message Number','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='13'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Total Number of Messages','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='13'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Quantity of PRNs Used For Position Solution','0','15','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='18'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'DGPS_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Message Number','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='19'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Total Number of Messages','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='19'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PR Residual Flag','0','32','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='20'),'3','Y','N','0','8.2.2',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'COMPARE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Message Number','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Total Number of Messages','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='21'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Number to be Transmitted','1','64','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='23'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PRN Number','1','32','99',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='28'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Message Number','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='29'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Total Number of Messages','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='29'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'SV_STATS'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'STATUS'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'PRN Number','1','32','99',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='30'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = 'EVENT'),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = 'INFO'),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Message Number','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Total Number of Messages','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='32'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Message Type Number','1','64','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='33'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'RTCM Message Type Number','1','64','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='34'),'3','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Quantity of PRNs Used For Position Solution','0','15','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='39'),'5','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Message Number','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='40'),'2','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
INSERT INTO RSIM_VARIABLE(RSIM_VARIABLE, range_lower, range_upper, acceptable_value,data_type_id,data_unit_id,code_id,rsim_number_id, sequence, is_active,is_multiple,occurance, rsim_reference, variable_destination_id,variable_event_type_id,measurement_type_id) SELECT 'Total Number of Messages','1','20','',(select data_type_id from ncs3.data_type where data_type = 'INTEGER'),(select data_unit_id from ncs3.data_unit where data_unit = ''),'',(select rsim_number_id from ncs3.rsim_number where rsim_number='40'),'1','Y','N','0','',(select variable_destination_id from ncs3.variable_destination where variable_destination = ''),(select variable_event_type_id from ncs3.variable_event_type where variable_event_type = ''),(select measurement_type_id from ncs3.measurement_type where measurement_type = 'RANGE') FROM DUAL;
/

ALTER TABLE NCS3.VARIABLE_DESCRIPTION
    DROP COLUMN RSIM_VARIABLE_VALUE;

ALTER TABLE NCS3.VARIABLE_DESCRIPTION
    ADD RSIM_VARIABLE_VALUE VARCHAR2(25) NOT NULL;
    
create unique index uq_VARIABLE_DESCRIPTION
   ON NCS3.VARIABLE_DESCRIPTION (RSIM_VARIABLE_ID, RSIM_VARIABLE_VALUE)
   TABLESPACE NCS3_LOOKUP_INDEX
/ 
    
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('PR Residual Flag') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='20')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=All Inside Threshold;1..32=PRN# Outside Threshold', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Synchronization Type') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='32')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Asynchronous;1=Synchronous', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Control State') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='25')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Low;1=High', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Monitored State') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='25')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Low;1=High', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Modulation Mode') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='21')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=MSK;1=FSK', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Modulation Mode') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='10')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=MSK;1=FSK;2=ID Morse Keying;3=No Modulation', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Modulation Mode') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='14')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=MSK;1=FSK;2=UnKnown;3=UnKnown', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Broadcast Coding') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='10')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=No Added Coding;1=Forward Error Correction Added', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Broadcast Coding') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='14')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=No Added Coding;1=Forward Error Correction Added', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Broadcast Coding') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='21')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=No Added Coding;1=Forward Error Correction Added', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Broadcast Coding') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='32')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=No Added Coding;1=Forward Error Correction Added', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Operating Mode') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='10')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Normal DGPS Data Link Operation;1=Alternating 1 and 0;2=Carrier Only;3=No Signal', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Status of PRN') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='9')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Not Tracked;1=Healthy-Tracked;2=Unhealthy Tracked;3=Forced Healthy-GPS Emphemeris Unhealthy;4=Forced Healthy-GPS Emphemeris Healthy;5=Forced Healthy-Not Tracked;6=Forced Unhealthy-GPS Broadcast Healthy;7=Forced Unhealthy-GPS Broadcast Unhealthy;8=Forced Unhealthy-Not Tracked;9=Health Undetermined-Tracked', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Enable') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='1')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Off;1=On', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Position Flag') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='20')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Position Inside Threshold;1=Position Outside Threshold;2=Unable to Check DGPS Integrity: Indicate UnMonitored', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Position Flag') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='33')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Position Inside Threshold;1=Position Outside Threshold;2=Unable to Check DGPS Integrity:Indicate UnMonitored', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Integrity Mode') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='31')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Pre-Broadcast Integrity Mode;1=Post-Broadcast Integrity Mode;2=Pre Post-Broadcast Integrity Mode;3=Reserved', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Integrity Mode') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='32')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Pre-Broadcast Integrity Mode;1=Post-Broadcast Integrity Mode;2=Pre Post-Broadcast Integrity Mode;3=Reserved', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Operational Status') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='32')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Radiobeacon Fully Operational;1=Test Mode;2=No Information Available;3=Not In Operation (or Planned Station)', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Health') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='21')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Radiobeacon Operational Normal;1=Unmonitored;2=No Information Available;3=Don’t use this Radiobeacon', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Automatic Side Switchover Enable') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='24')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Side A;1=Side B', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Synchronization Type') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='10')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Synchronous;1=Asynchronous', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Synchronization Type') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='14')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Synchronous;1=Asynchronous', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Synchronization Type') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='21')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Synchronous;1=Asynchronous', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Health Control Code') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='8')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=Use GPS Broadcast Health;1=Force Healthy;2=Force Unhealthy', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Datum') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='32')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0=WGS84;1=Local', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Extended Integrity Status') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='33')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('01=IM Solution Data Flag [0=Normal,1=No Solution]', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Extended Integrity Status') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='34')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('01=IM Solution Data Flag [0=Normal,1=No Solution];02=Message Error Ration Flag [0=Inside Threshold,1=Exceeds Threshold]', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('SV Integrity Flags') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='33')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('01=SV Integrity Check Flag [0=PRCs for SV NOT Integrity Checked,1=PRCs for SV Integrity Checked];02=Instantaneous PR Residual Flag [0=Inside Threshold,1=Outside Threshold];04=Interval PR Residual Flag [0=Inside Threshold,1=Outside Threshold];08=High RR Non-differential [0=Inside Threshold,1=Outside Threshold];10=PR Residual Non-differential [0=Inside Threshold,1=Outside Threshold]', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('SV Integrity Flags') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='34')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('01=SV Integrity Check Flag [0=PRCs for SV NOT Integrity Checked,1=PRCs for SV Integrity Checked];04=Interval PR Residual Flag [0=Inside Threshold,1=Outside Threshold];08=High RR Non-differential [0=Inside Threshold,1=Outside Threshold];10=PR Residual Non-differential [0=Inside Threshold,1=Outside Threshold]', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('RTCM Station Health') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='23')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('0-5=Defined by Service Provide;6=UnMonitored;7=UnHealthy', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Destination Port') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='1')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('1=Control Station;2=Data Recorder;3=Integrity Monitor;4=Auxillary Data', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Correction Generation Method') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='22')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('1=RTCM #1;2=RTCM #9 in Groups of 3 PRN;3=RTCM #9 for Individual PRN', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Operational Side') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='24')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('A=Side A;B=Side B', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Supply Power Source') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='24')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('AC=Alternating Current;DC=Direct Current', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Correction Broadcast Status') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='29')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('B=Broadcast Corrections;S=Suspended;R=Reset in Progress;O=Other', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Reset Command') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='3')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('D=DGPS Computational Reset;P=Partial Reset;F=Full Reset', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Configuration Change Password Enable-Disable Flag') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='36')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('E=Enable Configuration Change Password;D=Disable Configuration Change Password', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('RS IM Software Exit Password Enable-Disable Flag') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='36')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('E=Enable Software Exit Password;D=Disable Software Exit Password', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Unmonitored Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='12')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('F=Unmonitored-No IM System Feedback Message;W=Unmonitored-Wrong RS ID;U=Unmonitored-Other;M=Monitored-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('HDOP Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='17')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High HDOP;A=Acceptable HDOP-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('HDOP Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='38')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High HDOP;A=Acceptable HDOP-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Horizontal Position Error Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='17')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High Horizontal Position Error;A=Acceptable Horizontal Position Error-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Horizontal Position Error Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='38')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High Horizontal Position Error;A=Acceptable Horizontal Position Error-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('High Message Error Ration Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='17')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High Message Error Ratio;A=Acceptable Message Error Ratio-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('PR Residual Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='17')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High PR Residual;A=Acceptable PR Residual-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('PR Residual Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='38')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High PR Residual;A=Acceptable PR Residual-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('High PRC Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='12')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High PRC;N=Normal PRC-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('RR Residual Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='17')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High RR Residual;A=Acceptable RR Residual-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('RR Residual Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='38')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High RR Residual;A=Acceptable RR Residual-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('High RRC Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='12')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High RRC;N=Normal RRC-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('RTCM Correction Age Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='17')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High RTCM Correction Age;A=Acceptable RTCM Correction Age-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('RTCM Correction Age Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='38')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('H=High RTCM Correction Age;A=Acceptable RTCM Correction Age-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Insufficient Satellites Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='12')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('I=Insufficient Satellites;S=Sufficient Satellites-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Frequency Source') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='6')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('I=Internal;E=External', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Beacon SNR Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='17')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('L=Low SNR;A=Acceptable Beacon SNR-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Low UDRE Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='17')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('L=Low UDRE;A=Acceptable UDRE-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Low UDRE Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='38')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('L=Low UDRE;A=Acceptable UDRE-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('North South') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='6')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('N=North;S=South', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('North South') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='21')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('N=North;S=South', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('North South') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='32')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('N=North;S=South', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('ASCII Diagnostic Text') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='5')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('NORMAL=No System Malfunctions Detected', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('East West') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='6')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('W=West;E=East', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('East West') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='21')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('W=West;E=East', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('East West') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='32')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('W=West;E=East', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Force RS Unhealthy Override') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='35')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('Y=Force Override Enabled (RS to set RTCM Station Health to Unhealthy);N=No Override (Normal RS and IM Health Determination)', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('IM Parameter Default Save') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='37')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('Y=IM is to save current parameter set as boot defaults', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('RS Parameters Default Save') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='35')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('Y=RS is to save current parameter set as boot defaults', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Beacon SS Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='17')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('Z=Zero Becon Signal;L=Low Beacon Signal;A=Acceptable Beacon Signal-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Number of Satellites Used Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='17')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('Z=Zero Satellites Used;L=Low Number of Satellites Used;A=Acceptable Number of Satellites Used-Clear Alarm', ';'));
INSERT INTO ncs3.variable_description (variable_description,rsim_variable_id,rsim_variable_value) SELECT UPPER(substr(column_value, instr(column_value, '=')+1)),(SELECT RSIM_VARIABLE_ID FROM NCS3.RSIM_VARIABLE WHERE RSIM_VARIABLE = UPPER('Number of Satellites Used Alarm') AND RSIM_NUMBER_ID = (select rsim_number_id from ncs3.rsim_number where rsim_number='38')),UPPER(substr(column_value, 1, instr(column_value, '=')-1)) FROM TABLE(fn_csv2table('Z=Zero Satellites Used;L=Low Number of Satellites Used;A=Acceptable Number of Satellites Used-Clear Alarm', ';'));
COMMIT;
/

/* all lookups should have ID=-1, VALUE=UNDEFINED */


/* convert all table / lookup values to uppercase */
update ncs3.data_unit set data_unit = upper(data_unit);
update ncs3.rsim_variable set rsim_variable = upper(rsim_variable);
update ncs3.site_antenna set site_antenna = upper(site_antenna);
COMMIT;
/
