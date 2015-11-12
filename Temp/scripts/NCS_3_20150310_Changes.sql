/* Formatted on 3/11/2015 4:18:34 PM (QP5 v5.256.13226.35538) */
TRUNCATE TABLE ncs3.MESSAGE;

DELETE ncs3.MESSAGE cascade;

COMMIT;

  SELECT *
    FROM vwmessage
ORDER BY date_created DESC;

truncate table debug_output;
select * from debug_output;

select * from message_stats order by date_max desc;

DROP TRIGGER ncs3.TRAI_MESSAGE;
/

CREATE OR REPLACE TRIGGER TRAI_MESSAGE
   AFTER INSERT
   ON "NCS3"."MESSAGE"
   REFERENCING FOR EACH ROW
DECLARE
   lcount    NUMBER := 0;
   lsiteid   NUMBER := 0;
   lmessage  varchar2(2048) := '';
BEGIN
   lcount := 0;

   IF :new.is_outbound = 'N'
   THEN
        <<RESTART_VALIDATION>>
      SELECT COUNT (*)
        INTO lcount
        FROM ncs3.message_stats
       WHERE equipment_id = :new.equipment_id;

      IF lcount = 0
      THEN
        BEGIN
         INSERT INTO ncs3.message_stats (equipment_id,
                                         Date_min,
                                         Date_max,
                                         total_records)
              VALUES (:new.equipment_id,
                      :new.dtg,
                      :new.dtg,
                      1);
        EXCEPTION
            WHEN OTHERS THEN
                GOTO RESTART_VALIDATION;
        END;
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
