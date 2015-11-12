/* Formatted on 1/8/2014 3:17:34 PM (QP5 v5.256.13226.35538) */
INSERT INTO NCS3.GEO_QUAD (GEO_QUAD_ID,
                           QUAD_NORTH_SOUTH,
                           QUAD_EAST_WEST,
                           DATE_CREATED,
                           DATE_UPDATED)
   SELECT 0,
          'N',
          'E',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'N',
          'W',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'S',
          'E',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'S',
          'W',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.SITE_SIDE
   SELECT 0,
          'A',
          'SITE SIDE A',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'B',
          'SITE SIDE B',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.SITE_TYPE
   SELECT 0,
          'PRIMARY',
          'PRIMARY SITE FOR BROADCAST COVERAGE',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'ALTERNATE',
          'ALTERNATE SITE FOR BROADCAST COVERAGE',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'STANDBY',
          'STANDBY SITE',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.SITE_TYPE
   SELECT 0,
          'MOCKUP',
          'MOCKUP SITE FOR ENGINEERING',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'DECOMMISSIONED',
          'SITE IS DECOMISSIONED',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.EQUIPMENT_TYPE
   SELECT 0,
          4033,
          'TRANSMITTER',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          4035,
          'INTEGRITY MONITOR (IM A)',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          4034,
          'REFERENCE STATION (RS A)',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          4037,
          'INTEGRITY MONITOR (IM B)',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          4036,
          'REFERENCE STATION (RS B)',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.RSIM_NUMBER (RSIM_NUMBER_ID,
                              DESCRIPTION,
                              RSIM_NUMBER,
                              IS_ACTIVE,
                              IS_INCOMMING,
                              IS_OUTGOING,
                              IS_REFERENCE_STATION,
                              IS_INTEGRITY_MONITOR,
                              IS_TRANSMITTER,
                              DATE_UPDATED,
                              DATE_CREATED)
   SELECT -1,
          'UNDEFINED',
          -1,
          'N',
          'N',
          'N',
          'N',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RSIM MESSAGE_DESTINATION QUERY/REPORTING INTERVAL',
          1,
          'Y',
          'Y',
          'Y',
          'Y',
          'Y',
          'Y',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RSIM UNRECONIZED MESSAGE_DESTINATION ALARM',
          2,
          'Y',
          'Y',
          'N',
          'Y',
          'Y',
          'Y',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RSIM CONTROL COMMANDS',
          3,
          'Y',
          'N',
          'Y',
          'Y',
          'Y',
          'Y',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RSIM DATA ARCHIVE CONTROL',
          4,
          'Y',
          'Y',
          'Y',
          'Y',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RSIM DIAGNOSTIC REPORT/ALARM',
          5,
          'Y',
          'Y',
          'N',
          'Y',
          'Y',
          'Y',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'GPS RECEIVER PARAMETERS',
          6,
          'Y',
          'Y',
          'Y',
          'Y',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'GPS RECEIVER SATELLITES STATUS',
          7,
          'Y',
          'Y',
          'N',
          'Y',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'SATELLITE HEALTH CONTROL',
          8,
          'Y',
          'N',
          'Y',
          'Y',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'SATELLITE HEALTH STATUS',
          9,
          'Y',
          'Y',
          'N',
          'Y',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'REFERENCE STATION DATA LINK PARAMETERS',
          10,
          'Y',
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'REFERENCE STATION ALARM THRESHOLDS',
          11,
          'Y',
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'REFERENCE STATION ALARMS',
          12,
          'Y',
          'Y',
          'N',
          'N',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'REFERENCE STATION CORRECTION DATA',
          13,
          'Y',
          'Y',
          'N',
          'N',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'INTEGRITY MONITOR DATA LINK PARAMETERS',
          14,
          'Y',
          'Y',
          'Y',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'INTEGRITY MONITOR DATA LINK STATUS',
          15,
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'INTEGRITY MONITOR ALARM THRESHOLDS',
          16,
          'Y',
          'Y',
          'Y',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'INTEGRITY MONITOR ALARMS',
          17,
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'INTEGRITY MONITOR DGPS STATUS',
          18,
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'INTEGRITY MONITOR CORRECTION DATA',
          19,
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'INTEGRITY MONITOR SYSTEM FEEDBACK',
          20,
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RTCM BROADCAST ALMANAC PARAMETERS',
          21,
          'Y',
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RTCM BROADCAST SCHEDULING',
          22,
          'Y',
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RTCM UNIVERSAL MESSAGE_DESTINATION',
          23,
          'Y',
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'TRANSMITTER CONTROL STATUS',
          24,
          'Y',
          'Y',
          'Y',
          'N',
          'N',
          'Y',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'BROADCAST CONTROL STATUS',
          25,
          'Y',
          'Y',
          'Y',
          'N',
          'N',
          'Y',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'GENERAL TEXT MESSAGE_DESTINATION',
          26,
          'Y',
          'Y',
          'N',
          'Y',
          'Y',
          'Y',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'EQUIPMENT LOGISTICAL PARAMETERS',
          27,
          'Y',
          'Y',
          'N',
          'Y',
          'Y',
          'Y',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RS PRR CORRECTIVE ACTION PARAMETERS',
          28,
          'Y',
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'PRN BROADCAST STATUS',
          29,
          'Y',
          'Y',
          'N',
          'Y',
          'Y',
          'Y',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'PRN BROADCAST SUSPENSION ALARM',
          30,
          'Y',
          'Y',
          'N',
          'N',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'PRE/POST BROADCAST INTEGRITY MODE PARAMETERS',
          31,
          'N',
          'Y',
          'Y',
          'Y',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'EXTENDED RADIO BEACON ALMANAC PARAMETERS',
          32,
          'N',
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'EXTENDED PRE-BROADCAST INTEGRITY PARAMETERS',
          33,
          'N',
          'Y',
          'N',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'EXTENDED POST-BROADCAST INTEGRITY FEEDBACK',
          34,
          'N',
          'Y',
          'N',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'EXTENDED RS PARAMETERS',
          35,
          'N',
          'Y',
          'Y',
          'N',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'OPERATOR PASSWORDS',
          36,
          'N',
          'Y',
          'Y',
          'Y',
          'Y',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'EXTENDED IM PARAMETERS',
          37,
          'N',
          'Y',
          'Y',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'PRE-BROADCAST INTEGRITY MONITOR ALARMS',
          38,
          'N',
          'Y',
          'N',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'PRE-BROADCAST INTEGRITY MONITOR DGPS STATUS',
          39,
          'N',
          'Y',
          'N',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'PRE-BROADCAST INTEGRITY MONITOR CORRECTION STATUS',
          40,
          'N',
          'Y',
          'N',
          'Y',
          'N',
          'N',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.REPORT_LEVEL (REPORT_LEVEL_ID,
                               REPORT_LEVEL,
                               DESCRIPTION,
                               COLOR,
                               PRIORITY,
                               DATE_UPDATED,
                               DATE_CREATED)
   SELECT DISTINCT 0,
                   'R',
                   'SITE IS DOWN',
                   'RED',
                   2,
                   NULL,
                   NULL
     FROM DUAL
   UNION
   SELECT DISTINCT 0,
                   'N',
                   'SITE IS NORMAL',
                   'GREEN',
                   9,
                   NULL,
                   NULL
     FROM DUAL
   UNION
   SELECT DISTINCT 0,
                   'Y',
                   'SITE IS PARTIAL DOWN',
                   'YELLOW',
                   3,
                   NULL,
                   NULL
     FROM DUAL
   UNION
   SELECT DISTINCT 0,
                   'G',
                   'SITE IS NORMAL',
                   'GREEN',
                   9,
                   NULL,
                   NULL
     FROM DUAL
   UNION
   SELECT DISTINCT 0,
                   'P',
                   'SITE HAS NO COMMS',
                   'PURPLE',
                   1,
                   NULL,
                   NULL
     FROM DUAL
   UNION
   SELECT DISTINCT 0,
                   'C',
                   'SITE IS NOT MONITORED',
                   'GRAY',
                   8,
                   NULL,
                   NULL
     FROM DUAL
   UNION
   SELECT DISTINCT 0,
                   'X',
                   'SITE IS NOT OPERATIONAL',
                   'GRAY',
                   10,
                   NULL,
                   NULL
     FROM DUAL
   UNION
   SELECT DISTINCT 0,
                   'B',
                   'SITE IS NORMAL',
                   'GREEN',
                   9,
                   NULL,
                   NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.CODE_TYPE (CODE_TYPE_ID,
                            CODE_TYPE,
                            DESCRIPTION,
                            DATE_UPDATED,
                            DATE_CREATED)
   SELECT 0,
          'DL',
          'DATA LOGGER CONTROL (IM/RS)',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'DRN',
          'DEVICE REVISION NUMBER',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'EXDATA',
          '',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'FIELD',
          'FIELD DATA INVALID',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'FLDNUM',
          'FIELD NUMBER',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'IM5',
          'INTEGRITY MONITOR RSIM #5',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'PCCERT',
          'PRE-COMMISSION CERTIFICATION',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RS21',
          'REFERENCE STATION RSIM #21',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'SITE',
          'GENERAL SITE NETWORK ISSUE',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'TRACS',
          '',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'DBCODE',
          'DATABASE CODE MISMATCH OR MISSING',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'DECOM',
          'DECOMMISSION',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'DSN',
          'DEVICE SERIAL NUMBER',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'ENV',
          'ENVIRONMENTAL ALARM',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'MMODE',
          'MAINTENANCE MODE',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'MSGCRT',
          '',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'MSGINV',
          'MESSAGE_DESTINATION INVALID (BM)',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'MSGTYP',
          'MESSAGE_DESTINATION TYPE INVALID (BT)',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'ONAMU',
          'ON-AIR MAINTENANCE UNSCHEDULED',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'TX',
          'TRANSMITTER',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'DBDATA',
          'DATABASE DATA COULD NOT BE RETRIEVED',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'OFFAMS',
          'OFF-AIR MAINTENANCE SCHEDULED',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'OPER',
          'OPERATIONAL',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'ARCMSG',
          'ARCHIVE MESSAGE_DESTINATION',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'NODATA',
          '',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'OOC',
          'OUT OF COMMISSION',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'PRN',
          'SATELLITE HEALTH',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'TRCS',
          'TRANSMITTER CONTROL STATION NOTIFICATION',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'IM',
          'INTEGRITY MONITOR',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'IMSF',
          'INTEGRITY MONITOR SYSTEM FEEDBACK',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RESET',
          'SITE RESET',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RIM5',
          'TRANSMITTER RSIM #5',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'DATA',
          'DATA PROVIDED IS INVALID',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'MSGCS',
          'MESSAGE_DESTINATION CHECKSUM INVALID (BC)',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'OFFAMU',
          'OFF-AIR MAINTEANNCE UNSCHEDULED',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'PCBLD',
          'PRE-COMMISSION BUILD',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RS30',
          'REFERENCE STATION RSIM #30',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RS5',
          'REFERENCE STATION RSIM #5',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'ABN',
          '',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'MSGNUM',
          'MESSAGE_DESTINATION NUMBER INVALID (BN)',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'MSGSND',
          'MESSAGE_DESTINATION SEND ERROR',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'RS',
          'REFERENCE STATION',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'SYS',
          'SYSTEM',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'CSC',
          '',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'DB',
          'DATABASE',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'MSG',
          'MESSAGE_DESTINATION',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'NOR',
          '',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'NSD',
          '',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'ONAMS',
          'ON-AIR MAINTENANCE SCHEDULED',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.SITE_STATUS (SITE_STATUS_ID,
                              SITE_STATUS,
                              DESCRIPTION,
                              DATE_UPDATED,
                              DATE_CREATED)
   SELECT DISTINCT 0,
                   'NORMAL',
                   'FULL MISSION CAPABLE',
                   NULL,
                   NULL
     FROM DUAL
   UNION
   SELECT DISTINCT 0,
                   'WARNING',
                   'PARTIAL MISSION CAPABLE',
                   NULL,
                   NULL
     FROM DUAL
   UNION
   SELECT DISTINCT 0,
                   'CRITICAL',
                   'NON MISSION CAPABLE',
                   NULL,
                   NULL
     FROM DUAL
   UNION
   SELECT DISTINCT 0,
                   'NOCOMMS',
                   'NO COMMUNICATION WITH SITE',
                   NULL,
                   NULL
     FROM DUAL
   UNION
   SELECT DISTINCT 0,
                   'CSC',
                   '',
                   NULL,
                   NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.SITE_STATUS (SITE_STATUS_ID,
                              SITE_STATUS,
                              DESCRIPTION,
                              DATE_UPDATED,
                              DATE_CREATED)
   SELECT DISTINCT 0,
                   'NON-OPERATIONAL',
                   'NON PRODUCTION SITE',
                   NULL,
                   NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.SITE_CORR_GEN_METHOD (SITE_CORR_GEN_METHOD_ID,
                                       SITE_CORR_GEN_METHOD,
                                       DESCRIPTION,
                                       DATE_CREATED,
                                       DATE_UPDATED)
   SELECT -1,
          -1,
          'UNDEFINED',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          1,
          'RTCM #1(S)',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          2,
          'RTCM #9 IN GROUPS OF 3 PRN(S)',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          3,
          'RTCM #9 FOR INDIVIDUAL PRN(S)',
          NULL,
          NULL
     FROM DUAL;

--SELECT DISTINCT CORR_GEN_METHOD FROM NCS.BCS_STATUS;

--SELECT DISTINCT SITE_STATE FROM NCS.BCS_STATUS;

COMMIT;

INSERT INTO NCS3.SITE_STATE (SITE_STATE_ID,
                             SITE_STATE,
                             DESCRIPTION,
                             DATE_CREATED,
                             DATE_UPDATED)
   SELECT 0,
          'OPERATIONAL',
          'OPERATIONAL',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'OOC',
          'UNMONITORED',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'ON-AIR MAINTENANCE',
          'UNDERGOING ON-AIR MAINTENANCE',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'OFF-AIR MAINTENANCE',
          'UNDERGOING OFF-AIR MAINTENANCE',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'PRE-COMMISSION BUILD',
          'PRE-COMMISSION BUILD',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'PRE-COMMISSION CERTIFICATION',
          'PRE-COMMISSION CERTIFICATION',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.SITE_STATE (SITE_STATE_ID,
                             SITE_STATE,
                             DESCRIPTION,
                             DATE_CREATED,
                             DATE_UPDATED)
   SELECT 0,
          'DECOMMISSIONED',
          'DECOMMISSIONED',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.CITYSTATE (CITYSTATE_ID,
                            CITY,
                            STATE,
                            ZIP,
                            DATE_CREATED,
                            DATE_UPDATED)
   SELECT -1,
          'UNDEFINED',
          'UNDEFINED',
          0,
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.CONTACT (CONTACT_ID,
                          CONTACT,
                          DATE_CREATED,
                          DATE_UPDATED)
   SELECT 0,
          'WATCHSTANDER',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'WATCH OOD',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.CONTACT (CONTACT_ID,
                          CONTACT,
                          DATE_CREATED,
                          DATE_UPDATED)
   SELECT -1,
          'UNDEFINED',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.VENDOR (VENDOR_ID,
                         DATE_CREATED,
                         DATE_UPDATED,
                         DESCRIPTION,
                         VENDOR)
   SELECT -1,
          NULL,
          NULL,
          'UNDEFINED',
          'UNDEFINED'
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.MESSAGE_DESTINATION (MESSAGE_DESTINATION_ID,
                                      DATE_CREATED,
                                      DATE_UPDATED,
                                      MESSAGE_DESTINATION,
                                      DESCRIPTION)
   SELECT 0,
          NULL,
          NULL,
          'IM',
          'INTEGRITY MONITOR'
     FROM DUAL
   UNION
   SELECT 0,
          NULL,
          NULL,
          'RS',
          'REFERENCE STATION'
     FROM DUAL
   UNION
   SELECT 0,
          NULL,
          NULL,
          'TX',
          'TRANSMITTER'
     FROM DUAL
   UNION
   SELECT 0,
          NULL,
          NULL,
          'CS',
          'CONTROL STATION'
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.MESSAGE_CODE (MESSAGE_CODE_ID,
                               DATE_CREATED,
                               DATE_UPDATED,
                               MESSAGE_CODE,
                               DESCRIPTION)
   SELECT 0,
          NULL,
          NULL,
          'GM',
          'GOOD MESSAGE'
     FROM DUAL
   UNION
   SELECT 0,
          NULL,
          NULL,
          'PM',
          'PROCESSING MESSAGE'
     FROM DUAL
   UNION
   SELECT 0,
          NULL,
          NULL,
          'NM',
          'NEW MESSAGE'
     FROM DUAL
   UNION
   SELECT 0,
          NULL,
          NULL,
          'OM',
          'OUTGOING MESSAGE'
     FROM DUAL
   UNION
   SELECT 0,
          NULL,
          NULL,
          'IM',
          'INVALID MESSAGE'
     FROM DUAL;

COMMIT;
/*

COMMIT;
INSERT INTO NCS3.DATA_TYPE (DATA_TYPE_ID,
                            DATA_TYPE,
                            DATE_CREATED,
                            DATE_UPDATED)
   SELECT 0,
          'NUMERIC',
          NULL,
          NULL
     FROM DUAL
   UNION
   SELECT 0,
          'CHARACTER',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

 NCS3.RSIM_VARIABLE (RSIM_VARIABLE_ID,
                                DATE_CREATED,
                                DATE_UPDATED,
                                RSIM_VARIABLE,
                                LOWER_BOUND,
                                UPPER_BOUND,
                                ACCEPTABLE_VALUE,
                                DATA_TYPE_ID,
                                RSIM_NUMBER)
   SELECT 0,
          NULL,
          NULL,
          a.VARIABLE_NAME,
          a.LOWER_BOUND,
          a.UPPER_BOUND,
          a.ACCEPTABLE_VAL,
          CASE WHEN a.ACCEPTABLE_VAL IS NULL THEN 1 ELSE 2 END,
          -1
     FROM NCS.RSIM_VARIABLES a;
COMMIT;
     
RSIM_INT
RTCM_INT
*/

-- DATA IMPORT --

INSERT INTO NCS3.CODE (CODE_ID,
                       CODE,
                       DESCRIPTION,
                       CODE_TYPE_ID,
                       RSIM_NUMBER_ID,
                       REPORT_LEVEL_ID,
                       IS_DISPLAY,
                       IS_OVERRIDE,
                       IS_COMMENT_REQUIRED,
                       IS_OFF_AIR_MAINTENANCE,
                       IS_ON_AIR_MAINTENANCE,
                       IS_OUT_OF_COMMISSION,
                       IS_AVAILABILITY,
                       IS_RELIABILITY,
                       IS_PRECOMM_BUILD,
                       IS_PRECOMM_CERTIFICATION,
                       DATE_UPDATED,
                       DATE_CREATED)
   SELECT DISTINCT 0,
                   a.CODE,
                   a.CODE_DESC,
                   b.CODE_TYPE_ID,
                   NVL (e.RSIM_NUMBER_ID, -1),
                   d.REPORT_LEVEL_ID,
                   a.Display,
                   a.override,
                   a.req_comments,
                   a.off_air_maint,
                   a.on_air_maint,
                   a.ooc,
                   a.availability,
                   a.reliability,
                   a.precom_build,
                   a.precom_cert,
                   NULL,
                   NULL
     FROM NCS.CODES@ORCL a
          INNER JOIN NCS3.CODE_TYPE b ON b.CODE_TYPE = UPPER (a.CODE_TYPE)
          INNER JOIN NCS3.REPORT_LEVEL d ON d.REPORT_LEVEL = a.RPT_LVL
          LEFT OUTER JOIN NCS3.RSIM_NUMBER e ON e.RSIM_NUMBER = a.RSIM_NBR;

--SELECT DISTINCT a.CODE, a.CODE_DESC, a.CODE_TYPE FROM NCS.CODES@ORCL a;
--SELECT * FROM NCS.CODES@ORCL a;

-- 771
--SELECT COUNT(*) FROM NCS.CODES@ORCL a;
-- 771
--SELECT COUNT(*) FROM NCS3.NCS_CODE a;

COMMIT;


INSERT INTO NCS3.SITE_CONFIG (SITE_CONFIG_ID,
                              SITE_CONFIG,
                              DESCRIPTION,
                              DATE_UPDATED,
                              DATE_CREATED)
   SELECT DISTINCT 0,
                   SITE_CONFIG,
                   '-',
                   NULL,
                   NULL
     FROM NCS.BC_SITE@ORCL
    WHERE SITE_CONFIG IS NOT NULL;

COMMIT;

INSERT INTO NCS3.SITE_CONFIG (SITE_CONFIG_ID,
                              SITE_CONFIG,
                              DESCRIPTION,
                              DATE_UPDATED,
                              DATE_CREATED)
   SELECT DISTINCT -1,
                   'UD',
                   'UNDEFINED',
                   NULL,
                   NULL
     FROM DUAL;

UPDATE NCS3.SITE_CONFIG
   SET DESCRIPTION = 'SAC TX WITH BATTERY BACKUP'
 WHERE SITE_CONFIG = 'V1';

UPDATE NCS3.SITE_CONFIG
   SET DESCRIPTION = 'SAC TX WITH GENERATOR BACKUP'
 WHERE SITE_CONFIG = 'V2';

UPDATE NCS3.SITE_CONFIG
   SET DESCRIPTION = 'RCA TX WITH GENERATOR BACKUP'
 WHERE SITE_CONFIG = 'V3';

UPDATE NCS3.SITE_CONFIG
   SET DESCRIPTION = 'NAUTEL TX WITH BATTERY BACKUP'
 WHERE SITE_CONFIG = 'V4';

UPDATE NCS3.SITE_CONFIG
   SET DESCRIPTION = 'NAUTEL TX WITH GENERATOR BACKUP'
 WHERE SITE_CONFIG = 'V5';

COMMIT;

INSERT INTO NCS3.SITE_ANTENNA (SITE_ANTENNA_ID,
                               SITE_ANTENNA,
                               DESCRIPTION,
                               DATE_CREATED,
                               DATE_UPDATED)
   SELECT DISTINCT 0,
                   SITE_ANTENNA_TYPE,
                   '',
                   NULL,
                   NULL
     FROM NCS.BC_SITE
    WHERE SITE_ANTENNA_TYPE IS NOT NULL;

COMMIT;

INSERT INTO NCS3.SITE_ANTENNA (SITE_ANTENNA_ID,
                               SITE_ANTENNA,
                               DESCRIPTION,
                               DATE_CREATED,
                               DATE_UPDATED)
   SELECT -1,
          'UNDEFINED',
          '',
          NULL,
          NULL
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.UNIT (UNIT_ID,
                       UNIT,
                       PHONE_NUMBER,
                       STREET_ADDRESS,
                       DATE_CREATED,
                       DATE_UPDATED,
                       CITYSTATE_ID,
                       CONTACT_ID)
     SELECT DISTINCT 0,
                     UPPER (SITE_POC),
                     UPPER (SITE_PH_NBR),
                     NULL,
                     NULL,
                     NULL,
                     -1,
                     -1
       FROM NCS.BC_SITE
      WHERE     SITE_POC IS NOT NULL
            AND UPPER (SITE_PH_NBR) != '509-365-3044'
            AND UPPER (SITE_PH_NBR) != '907-886-7991'
            AND UPPER (SITE_PH_NBR) != '207-921-2531'
            AND UPPER (SITE_PH_NBR) != '808-335-4928'
   ORDER BY UPPER (SITE_POC);

COMMIT;

INSERT INTO NCS3.UNIT (UNIT_ID,
                       UNIT,
                       PHONE_NUMBER,
                       STREET_ADDRESS,
                       DATE_CREATED,
                       DATE_UPDATED,
                       CITYSTATE_ID,
                       CONTACT_ID)
   SELECT -1,
          'UNDEFINED',
          '(000) 000-0000',
          NULL,
          NULL,
          NULL,
          -1,
          -1
     FROM DUAL;

COMMIT;

INSERT INTO NCS3.SITE (SITE_ID,
                       SITE_ANTENNA_ID,
                       ANTENNA_HEIGHT,
                       SITE,
                       ICON_NAME,
                       DATE_CREATED,
                       DATE_UPDATED,
                       SITE_CONFIG_ID,
                       SITE_TYPE_ID,
                       UNIT_ID)
   SELECT a.SITE_ID,
          NVL (b.SITE_ANTENNA_ID, -1),
          SITE_ANTENNA_HEIGHT,
          UPPER (a.SITE_NAME),
          NVL (A.SITE_ICON_NAME, 'U-D'),
          NULL,
          NULL,
          NVL (d.SITE_CONFIG_ID, -1),
          NVL (c.SITE_TYPE_ID, 4),
          NVL (e.UNIT_ID, -1)
     FROM NCS.BC_SITE a
          LEFT OUTER JOIN NCS3.SITE_ANTENNA b
             ON b.SITE_ANTENNA = a.SITE_ANTENNA_TYPE
          LEFT OUTER JOIN NCS3.SITE_TYPE c
             ON c.SITE_TYPE =
                   CASE
                      WHEN a.REGION = 'E' THEN 'PRIMARY'
                      WHEN a.REGION = 'W' THEN 'ALTERNATE'
                      WHEN a.REGION = 'C' THEN 'DECOMMISSIONED'
                      WHEN a.REGION = 'M' THEN 'MOCKUP'
                      ELSE 'STANDBY'
                   END
          LEFT OUTER JOIN NCS3.SITE_CONFIG d ON d.SITE_CONFIG = a.SITE_CONFIG
          LEFT OUTER JOIN NCS3.UNIT e ON e.UNIT = UPPER (A.SITE_POC)
    WHERE a.SITE_NAME != 'Default';

COMMIT;

INSERT INTO NCS3.SITE (SITE_ID,
                       SITE_ANTENNA_ID,
                       ANTENNA_HEIGHT,
                       SITE,
                       ICON_NAME,
                       DATE_CREATED,
                       DATE_UPDATED,
                       SITE_CONFIG_ID,
                       SITE_TYPE_ID,
                       UNIT_ID)
   SELECT -1,
          -1,
          0,
          'DEFAULT',
          'ZZZ',
          NULL,
          NULL,
          -1,
          4,
          -1
     FROM DUAL;

UPDATE NCS3.SITE
   SET SITE_ID = 0
 WHERE SITE_ID = -1;

--SELECT * FROM NCS.BC_SITE a WHERE SITE_NAME = 'Default';
--SELECT * FROM NCS3.SITE a WHERE SITE = 'DEFAULT';

COMMIT;

INSERT INTO SITE_CONTROL_STATUS (SITE_CONTROL_STATUS_ID,
                                 SITE_ID,
                                 DATE_CREATED,
                                 DATE_UPDATED,
                                 SITE_SIDE_ID,
                                 SITE_STATE_ID,
                                 SITE_STATUS_ID,
                                 SITE_CORR_GEN_METHOD_ID)
   SELECT 0,
          a.SITE_ID,
          NULL,
          NULL,
          b.SITE_SIDE_ID,
          c.SITE_STATE_ID,
          d.SITE_STATUS_ID,
          NVL (e.SITE_CORR_GEN_METHOD_ID, -1)
     FROM NCS.BCS_STATUS a
          INNER JOIN NCS3.SITE_SIDE b ON b.SITE_SIDE = a.SITE_SIDE
          INNER JOIN NCS3.SITE_STATE c
             ON c.SITE_STATE =
                   CASE
                      WHEN a.SITE_STATE = 'PRECOM-BUILD'
                      THEN
                         'PRE-COMMISSION BUILD'
                      WHEN a.SITE_STATE = 'PRECOM-CERT'
                      THEN
                         'PRE-COMMISSION CERTIFICATION'
                      WHEN a.SITE_STATE = 'DECOM'
                      THEN
                         'DECOMMISSIONED'
                      ELSE
                         'OPERATIONAL'
                   END
          INNER JOIN NCS3.SITE_STATUS d ON d.SITE_STATUS = a.SITE_STATUS
          LEFT OUTER JOIN NCS3.SITE_CORR_GEN_METHOD e
             ON E.SITE_CORR_GEN_METHOD = A.CORR_GEN_METHOD;

--SELECT DISTINCT SITE_STATE FROM NCS.BCS_STATUS a;

COMMIT;

INSERT INTO NCS3.EQUIPMENT (EQUIPMENT_ID,
                            SITE_ID,
                            DATE_CREATED,
                            DATE_UPDATED,
                            DEVICE_SERIAL_NUMBER,
                            IS_ENABLED,
                            IP_ADDRESS,
                            VENDOR_ID,
                            EQUIPMENT_TYPE_ID)
   SELECT 0,
          a.site_id,
          NULL,
          NULL,
          a.DEV_SN,
          'Y',
          a.IP_ADDRESS,
          -1,
          b.EQUIPMENT_TYPE_ID
     FROM NCS.SITE_EQUIP a
          INNER JOIN NCS3.EQUIPMENT_TYPE b ON b.EQUIPMENT_TYPE = a.EQUIP_TYPE;

--SELECT * FROM NCS.SITE_EQUIP a;

COMMIT;

INSERT INTO NCS3.IM_PARAMETER (IM_PARAMETER_ID,
                               EQUIPMENT_ID,
                               IS_DEFAULT,
                               RS_ID,
                               FREQUENCY_SOURCE,
                               REFERENCE_POSITION_LATITUDE,
                               REFERENCE_POSITION_LONGITUDE,
                               EXTERNAL_FREQUENCY_SOURCE,
                               ALTITUDE_ELLIPSOIDAL,
                               RTCM_CORR_AGE_MAX,
                               BDCST_MASK_ANGLE,
                               BDCST_BIT_RATE,
                               MODULATION_MODE,
                               SYNCRONIZATION_TYPE,
                               BDCST_CODE,
                               MONITORED_RBN_BDCST_FREQUENCY,
                               CORR_AGE_THRESHOLD,
                               CORR_AGE_OBSERVATION_INT,
                               MSG_ERR_RATIO_THRESHOLD,
                               MSG_ERR_RATIO_OBSERVATION_INT,
                               RBN_SNR_THRESHOLD,
                               RBN_SNR_OBSERVATION_INT,
                               RBN_SS_THRESHOLD,
                               RBN_SS_OBSERVATION_INT,
                               NBR_SATS_THRESHOLD,
                               NBR_SATS_OBSERVATION_INT,
                               HDOP_THRESHOLD,
                               HDOP_OBSERVATION_INT,
                               HOR_POSITION_ERROR_THRESHOLD,
                               HOR_POSITION_ERROR_INT,
                               PR_RESIDUAL_THRESHOLD,
                               PR_RESIDUAL_OBSERVATION_INT,
                               RR_RESIDUAL_THRESHOLD,
                               RR_RESIDUAL_OBSERVATION_INT,
                               LOW_UDRE_THRESHOLD,
                               LOW_UDRE_OBSERVATION_INT,
                               LOGGING_INT,
                               POSITION_FLAG,
                               PR_RESIDUAL_FLAG,
                               GEO_QUAD_ID,
                               DATE_CREATED,
                               DATE_UPDATED)
   SELECT 0,
          b.equipment_id,
          CASE WHEN a.DEFAULT_VAL = 1 THEN 'Y' ELSE 'N' END,
          a.RS_ID,
          a.FREQ_SRC,
          a.REF_POSIT_LAT,
          a.REF_POSIT_LONG,
          a.EXT_SRC_FREQ,
          a.ALT_ELLIPSOIDAL,
          a.RTCM_CORR_AGE_MAX,
          a.BDCST_MASK_ANGLE,
          a.BDCST_BIT_RATE,
          a.MOD_MODE,
          a.SYNC_TYPE,
          a.BDCST_CODE,
          a.MON_RBN_BDCST_FREQ,
          a.CORR_AGE_THRESH,
          a.CORR_AGE_OBS_INT,
          a.MSG_ERROR_RATIO_THRESH,
          a.MSG_ERROR_RATIO_OBS_INT,
          a.RBN_SNR_THRESH,
          a.RBN_SNR_OBS_INT,
          a.RBN_SS_THRESH,
          a.RBN_SS_OBS_INT,
          a.NBR_SATS_THRESH,
          a.NBR_SATS_OBS_INT,
          a.HDOP_THRESH,
          a.HDOP_OBS_INT,
          a.HOR_POSIT_ERR_THRESH,
          a.HOR_POSIT_ERR_OBS_INT,
          a.PR_RESIDUAL_THRESH,
          a.PR_RESIDUAL_OBS_INT,
          a.RR_RESIDUAL_THRESH,
          a.RR_RESIDUAL_OBS_INT,
          a.LOW_UDRE_THRESH,
          a.LOW_UDRE_OBS_INT,
          a.LOGGING_INT,
          a.POSIT_FLAG,
          a.PR_RESIDUAL_FLAG,
          d.GEO_QUAD_ID,
          NULL,
          NULL
     FROM NCS.IM_PARAMETERS a
          INNER JOIN NCS3.EQUIPMENT b ON b.SITE_ID = a.SITE_ID
          INNER JOIN NCS3.EQUIPMENT_TYPE c
             ON     c.EQUIPMENT_TYPE_ID = b.EQUIPMENT_TYPE_ID
                AND c.EQUIPMENT_TYPE = a.EQUIP_TYPE
          INNER JOIN NCS3.GEO_QUAD d
             ON     d.QUAD_NORTH_SOUTH = a.REF_POSIT_N_S
                AND d.QUAD_EAST_WEST = a.REF_POSIT_E_W;

COMMIT;

INSERT INTO NCS3.RS_PARAMETER (RS_PARAMETER_ID,
                               EQUIPMENT_ID,
                               IS_DEFAULT,
                               MINIMUM_NUMBER_SATS_TRACKED,
                               PRC_THRESHOLD,
                               RRC_THRESHOLD,
                               IM_SYSTEM_FDBK_TIME_THRESHOLD,
                               CHANNEL,
                               FREQUENCY,
                               OPERATING_MODE,
                               BDCST_BIT_RATE,
                               MODULATION_MODE,
                               SYNCHRONIZATION_TYPE,
                               BDCST_CODE,
                               RBN_ID,
                               RS_ID,
                               FREQUENCY_SOURCE,
                               REF_POSITION_LATITUDE,
                               REF_POSITION_LONGITUDE,
                               EXTERNAL_FREQUENCY_SOURCE,
                               ALTITUDE_ELLIPSOIDAL,
                               BDCST_MASK_ANGLE,
                               RTCM_CORR_AGE_MAXIMUM,
                               LOGGING_INTERVAL,
                               GEO_QUAD_ID,
                               RESET_ITERATIONS,
                               CORR_SUSPENSION_DURATION,
                               RESET_DURATION,
                               RESET_MONITORING_INTERVAL,
                               DATE_UPDATED,
                               DATE_CREATED)
   SELECT 0,
          b.EQUIPMENT_ID,
          CASE WHEN a.DEFAULT_VAL = 1 THEN 'Y' ELSE 'N' END,
          a.MIN_NBR_TRACKED_SATS,
          a.PRC_THRESH,
          a.RRC_THRESH,
          a.IM_SYS_FDBK_TIME_THRESH,
          a.CHANNEL,
          a.FREQ,
          a.OP_MODE,
          a.BDCST_BIT_RATE,
          a.MOD_MODE,
          a.SYNC_TYPE,
          a.BDCST_CODE,
          a.RBN_ID,
          a.RS_ID,
          a.FREQ_SRC,
          a.REF_POSIT_LAT,
          a.REF_POSIT_LONG,
          a.EXT_SRC_FREQ,
          a.ALT_ELLIPSOIDAL,
          a.BDCST_MASK_ANGLE,
          a.RTCM_CORR_AGE_MAX,
          a.LOGGING_INT,
          d.GEO_QUAD_ID,
          a.REST_ITR,
          a.CORR_SUSP_DURATION,
          a.RESET_DURATION,
          a.RESET_MON,
          NULL,
          NULL
     FROM NCS.RS_PARAMETERS a
          INNER JOIN NCS3.EQUIPMENT b ON b.SITE_ID = a.SITE_ID
          INNER JOIN NCS3.EQUIPMENT_TYPE c
             ON     c.EQUIPMENT_TYPE_ID = b.EQUIPMENT_TYPE_ID
                AND c.EQUIPMENT_TYPE = a.EQUIP_TYPE
          INNER JOIN NCS3.GEO_QUAD d
             ON     d.QUAD_NORTH_SOUTH = a.REF_POSIT_N_S
                AND d.QUAD_EAST_WEST = a.REF_POSIT_E_W;

COMMIT;

INSERT INTO NCS3.TX_PARAMETER (TX_PARAMETER_ID,
                               EQUIPMENT_ID,
                               IS_DEFAULT,
                               DATE_UPDATED,
                               DATE_CREATED,
                               OPERATING_SIDE,
                               TX_PROCESSOR_RESET,
                               AUTO_SIDE_SWITCH_ENABLE,
                               TX_OUTPUT_POWER,
                               SUPPLY_POWER_SOURCE,
                               TIME_STAMP_ENABLE,
                               AUTO_RESET_ENABLE,
                               AUTO_RESET_INTERVAL,
                               SUPPLY_SOURCE_CONTROL,
                               DCAD_DIS_VOLT_LVL,
                               DCAD_RES_VOLT_LVL)
   SELECT 0,
          b.EQUIPMENT_ID,
          CASE WHEN a.DEFAULT_VAL = 1 THEN 'Y' ELSE 'N' END,
          NULL,
          NULL,
          OP_SIDE,
          TX_PROC_RESET,
          AUTO_SIDE_SWITCH_ENABLE,
          TX_OUT_POWER,
          SUPPLY_POWER_SRC,
          TIME_STAMP_ENABLE,
          AUTO_RESET_ENABLE,
          AUTO_RESET_INT,
          SUPPLY_SRC_CONT,
          DCAD_DIS_VOLT_LVL,
          DCAD_RES_VOLT_LVL
     FROM NCS.TX_PARAMETERS a
          INNER JOIN NCS3.EQUIPMENT b ON b.SITE_ID = a.SITE_ID
          INNER JOIN NCS3.EQUIPMENT_TYPE c
             ON     c.EQUIPMENT_TYPE_ID = b.EQUIPMENT_TYPE_ID
                AND c.EQUIPMENT_TYPE = a.EQUIP_TYPE;

COMMIT;

INSERT INTO NCS3.SV_PARAMETER (SV_PARAMETER_ID,
                               EQUIPMENT_ID,
                               IS_DEFAULT,
                               PRN_NUMBER,
                               HEALTH_CONTROL_CODE,
                               LOSS_SAT_WARNING_TIME,
                               DATE_CREATED,
                               DATE_UPDATED)
   SELECT 0,
          b.EQUIPMENT_ID,
          CASE WHEN a.DEFAULT_VAL = 1 THEN 'Y' ELSE 'N' END,
          PRN_NBR,
          HEALTH_CONTROL_CODE,
          LOSS_SAT_WARNING_TIME,
          NULL,
          NULL
     FROM NCS.SV_PARAMETERS a
          INNER JOIN NCS3.EQUIPMENT b ON b.SITE_ID = a.SITE_ID
          INNER JOIN NCS3.EQUIPMENT_TYPE c
             ON     c.EQUIPMENT_TYPE_ID = b.EQUIPMENT_TYPE_ID
                AND c.EQUIPMENT_TYPE = a.EQUIP_TYPE;


COMMIT;

INSERT INTO NCS3.ADJACENT_SITE (ADJACENT_SITE_ID,
                                HOST_SITE_ID,
                                DATE_CREATED,
                                DATE_UPDATED)
   SELECT ADJ_SITE_ID,
          HOST_SITE_ID,
          NULL,
          NULL
     FROM NCS.ADJACENT_SITES;

COMMIT;

INSERT INTO NCS3.ALMANAC_PARAMETER (ALMANAC_PARAMETER_ID,
                                    BDCST_CODING,
                                    SYNCHRONIZATION_TYPE,
                                    MODULATION_MODE,
                                    RBN_BDCST_BIT_RATE,
                                    RBN_BDCST_ID,
                                    HEALTH,
                                    FREQUENCY,
                                    RBN_RANGE,
                                    LONGITUDE,
                                    LATITUDE,
                                    DATE_CREATED,
                                    DATE_UPDATED,
                                    GEO_QUAD_ID,
                                    EQUIPMENT_ID)
   SELECT a.RTCM_BDCST_ID,
          a.BDCST_CODING,
          a.SYNC_TYPE,
          a.MOD_MODE,
          a.RBN_BDCST_BIT_RATE,
          a.RBN_BDCST_ID,
          a.HEALTH,
          a.FREQ,
          a.RBN_RANGE,
          a.LONGITUDE,
          a.LAT,
          NULL,
          NULL,
          d.GEO_QUAD_ID,
          b.equipment_id
     FROM NCS.ALMANAC_PARAMETERS a
          INNER JOIN NCS3.EQUIPMENT b ON b.SITE_ID = a.SITE_ID
          INNER JOIN NCS3.EQUIPMENT_TYPE c
             ON     c.EQUIPMENT_TYPE_ID = b.EQUIPMENT_TYPE_ID
                AND c.EQUIPMENT_TYPE = a.EQUIP_TYPE
          INNER JOIN NCS3.GEO_QUAD d
             ON d.QUAD_NORTH_SOUTH = a.N_S AND d.QUAD_EAST_WEST = a.E_W;

COMMIT;
