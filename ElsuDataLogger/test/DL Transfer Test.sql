/* Formatted on 11/17/2014 1:49:03 PM (QP5 v5.256.13226.35538) */
SELECT * FROM SITE WHERE SITE_ID = 307;

SELECT * FROM vwsite;

SELECT * FROM EQUIPMENT;

SELECT * FROM equipment_type;

SELECT * FROM vwequipment;

SELECT * FROM vwMESSAGE where rsim_number = 2;
SELECT * FROM vwMESSAGE where equipment_type = 4036 order by message_id desc;
SELECT * FROM vwMESSAGE where equipment_type = 4033 order by message_id desc;

SELECT a.equipment_id,
       a.site_id,
       a.device_serial_number,
       a.equipment_type,
       a.site,
       A.IP_ADDRESS,
       b.site_config,
       b.site_type,
       b.icon_name,
       b.site_type
  FROM vwequipment a INNER JOIN vwsite b ON b.site_id = a.site_id
  WHERE a.SITE_ID = 307;
  
-- DELETE message;
  
SELECT COUNT(*) FROM MESSAGE;
SELECT * FROM MESSAGE;
/

DECLARE
    l_recid  NUMBER := 0;
    l_status VARCHAR2(4000) := null;
BEGIN
    NCS3.pMessageStore (307, 4033, SYSDATE, '$PRCM,1,5,1,,,,25,1,,,*23',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
            
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
END; 
/

SELECT * FROM vwEQUIPMENT WHERE SITE_ID = 307;
UPDATE EQUIPMENT SET IP_ADDRESS = '172.16.29.33' WHERE EQUIPMENT_ID = 476;
UPDATE EQUIPMENT SET IP_ADDRESS = '172.16.29.34' WHERE EQUIPMENT_ID = 477;
UPDATE EQUIPMENT SET IP_ADDRESS = '172.16.29.35' WHERE EQUIPMENT_ID = 478;
UPDATE EQUIPMENT SET IP_ADDRESS = '172.16.29.36' WHERE EQUIPMENT_ID = 479;
UPDATE EQUIPMENT SET IP_ADDRESS = '172.16.29.37' WHERE EQUIPMENT_ID = 480;

SELECT * FROM EQUIPMENT_TYPE;
INSERT INTO EQUIPMENT_TYPE(equipment_type, description, shortname) values (1001, 'DATA LOGGER', 'DL');
INSERT INTO EQUIPMENT (Device_serial_number, equipment_type_id, IP_Address, IS_ENABLED, SITE_ID, Vendor_id) VALUES
    ('DL01', 7, '192.168.7.10', 'Y', 307, -1);

SELECT * FROM MESSAGE WHERE IS_OUTBOUND = 'Y' ORDER BY DATE_CREATED DESC;
SELECT * FROM MESSAGE_CODE;
SELECT * FROM MESSAGE_NOTIFIER;

DELETE MESSAGE where rsim_number_id = 34;

/* Formatted on 11/18/2014 5:09:06 PM (QP5 v5.256.13226.35538) */
DECLARE
   l_siteid   NUMBER := 0;
   l_ip       VARCHAR2 (1000) := NULL;
BEGIN
      NCS3.pGetPendingNotifier(l_siteid, l_ip);
        
   DBMS_OUTPUT.PUT_LINE(l_siteid || '/' || l_ip);
END;
/

SELECT IP_ADDRESS
        FROM ncs3.equipment
       WHERE site_id = 307 AND ROWNUM = 1;
/
          
DECLARE
   l_siteid   NUMBER := 0;
   l_ocount   NUMBER := 0;
BEGIN
      NCS3.pGetPendingNotifierCount(l_siteid, l_ocount);
        
   DBMS_OUTPUT.PUT_LINE(l_siteid || '/' || l_ocount);
END;
/
