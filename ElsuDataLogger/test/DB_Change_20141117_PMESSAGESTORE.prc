alter table ncs3.message add IS_ALARM VARCHAR2(1) DEFAULT 'N' NOT NULL;

ALTER TABLE NCS3.MESSAGE ADD (
  CHECK (IS_ALARM IN ('Y', 'N'))
  ENABLE VALIDATE);

alter table ncs3.message add IS_RECOVERY VARCHAR2(1) DEFAULT 'Y' NOT NULL;

ALTER TABLE NCS3.MESSAGE ADD (
  CHECK (IS_RECOVERY IN ('Y', 'N'))
  ENABLE VALIDATE);
/

CREATE OR REPLACE PROCEDURE NCS3.pMessageStore (
   isite_id          IN     NUMBER,
   iequipment_type   IN     NUMBER,
   idtg              IN     TIMESTAMP,
   imessage_text     IN     VARCHAR2,
   ioutbound         IN     VARCHAR2,
   iisalarm          IN     VARCHAR2,
   iisrecovery       IN     VARCHAR2,
   omessage_id          OUT NUMBER,
   ostatus              OUT VARCHAR2)
AS
   lequipmentid   NUMBER;
   lrsimnbr       NUMBER;
   lonline        VARCHAR2 (1) := 'Y';
   err_code       NUMBER;
   err_msg        VARCHAR2 (1024);
BEGIN
   omessage_id := 0;
   ostatus := ',';

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
                             is_alarm,
                             is_recovery,
                             MESSAGE_TEXT)
        VALUES (lequipmentid,
                idtg,
                ioutbound,
                lonline,
                lrsimnbr,
                iisalarm,
                iisrecovery,
                imessage_text)
     RETURNING message_id
          INTO omessage_id;
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ostatus := err_code || ',' || err_msg;
      ROLLBACK;
END;
/
