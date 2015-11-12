/* Formatted on 11/18/2014 5:24:42 PM (QP5 v5.256.13226.35538) */
CREATE OR REPLACE PROCEDURE NCS3.pGetPendingNotifier (
   osite_id   IN OUT NUMBER,
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
       WHERE     site_id = osite_id
             AND ROWNUM = 1
             AND equipment_type_id = (SELECT equipment_type_id
                                        FROM NCS3.EQUIPMENT_TYPE
                                       WHERE equipment_type = '1001');
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      err_code := SQLCODE;
      err_msg := SUBSTR (SQLERRM, 1, 200);
      ROLLBACK;
END;
/