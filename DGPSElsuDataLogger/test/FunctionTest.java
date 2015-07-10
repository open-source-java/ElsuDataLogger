
import elsu.network.services.client.bcs.BcsMessage;

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author ss.dhaliwal_admin
 */
public class FunctionTest {
    public void BcsMessageTest() {
                    
            BcsMessage bmsg = new BcsMessage();
            bmsg.setSiteId(201);
            bmsg.setEquipmentId(4036);
            bmsg.setPayload("$PRCM,1,RSIM c:\\Program Files (x86)\\CyberLink\\Power2Go\\Power2Go.exe : Version 6.1.0.5391");
            System.out.println(bmsg.getBcsMessage());
            
            bmsg = new BcsMessage(201,4036,"$PRCM,1,RSIM c:\\Program Files (x86)\\CyberLink\\Power2Go\\Power2Go.exe : Version 6.1.0.5391");
            System.out.println(bmsg.getBcsMessage());
            
            bmsg = new BcsMessage(201,4036,"$PRCM,1,RSIM c:\\Program Files (x86)\\CyberLink\\Power2Go\\Power2Go.exe : Version 6.1.0.5391",
                    "yyyyMMdd", "|", "^");
            System.out.println(bmsg.getBcsMessage());
            
            bmsg.setDatetimeFormat("yyyyMMddHHmmssS");
            bmsg.setBcsMessage("201|20140524212349848|4033|26|$PRCM,1,RSIM CBS.dll : Version 7.7.6531");
            System.out.println(bmsg.getBcsMessage());
            
            bmsg.setBcsMessage("201~20140524212259886~4033~26~$PRCM,1,RSIM CBS.dll : Version 7.7.6531",
                    "yyyyMMddHHmmssS", "~", "^");
            System.out.println(bmsg.getBcsMessage());
            
            bmsg = BcsMessage.getBcsMessage("543|20140526093902873|4035|33|$PRCM,1,RSIM c:\\Program Files (x86)\\CyberLink\\Power2Go\\Power2Go.exe : Version 6.1.0.5391");
            System.out.println(bmsg.getBcsMessage());
            
            bmsg = BcsMessage.getBcsMessage("543~20140526093902873~4035~32~$PRCM,1,RSIM c:\\Program Files (x86)\\CyberLink\\Power2Go\\Power2Go.exe : Version 6.1.0.5391",
                    "yyyyMMddHHmmssS", "~", "^");
            System.out.println(bmsg.getBcsMessage("yyyyMMdd", "|", "^"));

    }
}
