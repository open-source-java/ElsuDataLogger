/*
4033
$PRCM,1,5,1,,,,25,1,,,*23
$PRCM,1,1,1,,,,24,1,,,,26,1,,,,27,1,,,*27

4034
$PRCM,1,1,1,,,,4,1,,,,6,1,,,,10,1,,,,11,1,,,,27,1,,,,28,1,,,*31
$PRCM,1,5,1,,,,12,1,,,*27
$PRCM,1,21,1,,,,22,1,,,*12

4035
$PRCM,1,1,1,,,,4,1,,,,6,1,,,,14,1,,,,16,1,,,,27,1,,,*25
$PRCM,1,5,1,,,,17,1,,,*22
$PRCM,1,15,1,,,,18,1,,,*1C

4036
$PRCM,1,21,1,,,,22,1,,,*12
$PRCM,1,4,1,,,*38
$PRCM,1,6,1,,,*3A
$PRCM,1,10,1,,,*0D
$PRCM,1,11,1,,,*0C
$PRCM,1,28,1,,,*06
$PRCM,1,1,1,,,*3D

4037
$PRCM,1,15,1,,,,18,1,,,*1C
$PRCM,1,5,1,,,,17,1,,,*22
$PRCM,1,6,1,,,*3A
$PRCM,1,14,1,,,*09
$PRCM,1,16,1,,,*0B
$PRCM,1,1,1,,,*3D

*/

DECLARE
    l_recid  NUMBER := 0;
    l_status VARCHAR2(4000) := null;
BEGIN
    NCS3.pMessageStore (307, 4033, SYSDATE, '$PRCM,1,5,1,,,,25,1,,,*23',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4033, SYSDATE, '$PRCM,1,1,1,,,,24,1,,,,26,1,,,,27,1,,,*27',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
 
    NCS3.pMessageStore (307, 4034, SYSDATE, '$PRCM,1,1,1,,,,4,1,,,,6,1,,,,10,1,,,,11,1,,,,27,1,,,,28,1,,,*31',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4034, SYSDATE, '$PRCM,1,5,1,,,,12,1,,,*27',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4034, SYSDATE, '$PRCM,1,21,1,,,,22,1,,,*12',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
           
    NCS3.pMessageStore (307, 4035, SYSDATE, '$PRCM,1,1,1,,,,4,1,,,,6,1,,,,14,1,,,,16,1,,,,27,1,,,*25',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4035, SYSDATE, '$PRCM,1,5,1,,,,17,1,,,*22',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4035, SYSDATE, '$PRCM,1,15,1,,,,18,1,,,*1C',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);

    NCS3.pMessageStore (307, 4036, SYSDATE, '$PRCM,1,21,1,,,,22,1,,,*12',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4036, SYSDATE, '$PRCM,1,4,1,,,*38',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4036, SYSDATE, '$PRCM,1,6,1,,,*3A5',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4036, SYSDATE, '$PRCM,1,10,1,,,*0D',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4036, SYSDATE, '$PRCM,1,11,1,,,*0C',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4036, SYSDATE, '$PRCM,1,28,1,,,*06',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4036, SYSDATE, '$PRCM,1,1,1,,,*3D',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);

    NCS3.pMessageStore (307, 4037, SYSDATE, '$PRCM,1,15,1,,,,18,1,,,*1C',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4037, SYSDATE, '$PRCM,1,5,1,,,,17,1,,,*22',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4037, SYSDATE, '$PRCM,1,6,1,,,*3A',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4037, SYSDATE, '$PRCM,1,14,1,,,*09',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4037, SYSDATE, '$PRCM,1,16,1,,,*0B',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);
    NCS3.pMessageStore (307, 4037, SYSDATE, '$PRCM,1,1,1,,,*3D',
        'Y', 'N', 'N', l_recid, l_status);
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(l_recid || '/' || l_status);

    --DBMS_LOCK.sleep (300); 
END; 
/