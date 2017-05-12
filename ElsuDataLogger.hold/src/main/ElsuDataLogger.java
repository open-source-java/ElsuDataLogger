package main;

import elsu.network.application.*;

/**
 *
 * @author ssd.administrator
 */
public class ElsuDataLogger extends AbstractNetworkApplication {

    /**
     * main(Strings[] args) method is the applicaton entry point for
     * ElsuMessageProcessor. The optional parameters are: custom config file and
     * /disableAll option.
     *
     * @param args
     */
    public static void main(String[] args) {
        try {
            // instantiate the main controller class and call its run()
            // method to start service factory
            ElsuDataLogger dgpsedl = new ElsuDataLogger();
            dgpsedl.run(args);
        } catch (Exception ex){
            // Display a message if anything goes wrong
            System.err.println("DGPSElsuDataLogger, main, " + ex.getMessage());
            System.err.println(
                    "application.main, Usage: java -jar ElsuMessageProcessor.jar "
                    + "[./app.config] [/disabled]");
            System.exit(1);
        }
    }
}
