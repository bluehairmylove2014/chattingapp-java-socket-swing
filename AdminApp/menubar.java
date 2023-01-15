

import javax.swing.JCheckBoxMenuItem;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import java.awt.event.*;

public class menubar implements ActionListener {
    private JMenuBar jmb;
    menubar() {
        // Khởi tạo
        jmb = new JMenuBar();
    }
    public JMenuBar createMenu() {
        //Thiết lập những thành phần cơ bản của menu bar
        JMenu jmFile = new JMenu("File");
        JMenu jmOptions = new JMenu("Options");
        JMenuItem jmiReset = new JMenuItem("Reset");
        JMenu jmHelp = new JMenu("Help");

            // Thêm các thành phần cho menu "File"
        JMenuItem jmiOpen = new JMenuItem("Open");
        JMenuItem jmiClose = new JMenuItem("Close");
        JMenuItem jmiSave = new JMenuItem("Save");
        JMenuItem jmiExit = new JMenuItem("Exit");
        jmFile.add(jmiOpen);
        jmFile.add(jmiClose);
        jmFile.add(jmiSave);
        jmFile.addSeparator();
        jmFile.add(jmiExit);
        jmb.add(jmFile);

            // Thêm các thành phần cho menu "Options"
        // Tạo một submenu của Option có tên Colors
        JMenu jmColors = new JMenu("Colors");
        JCheckBoxMenuItem jmiRed = new JCheckBoxMenuItem("Red", true);
        JCheckBoxMenuItem jmiGreen = new JCheckBoxMenuItem("Green", false);
        JCheckBoxMenuItem jmiBlue = new JCheckBoxMenuItem("Blue", false);
        jmColors.add(jmiRed);
        jmColors.add(jmiGreen);
        jmColors.add(jmiBlue);
        jmOptions.add(jmColors);
        // Tạo một submenu có tên Priority.
        JMenu jmPriority = new JMenu("Priority");
        JMenuItem jmiHigh = new JMenuItem("High");
        JMenuItem jmiLow = new JMenuItem("Low");
        jmPriority.add(jmiHigh);
        jmPriority.add(jmiLow);
        jmOptions.add(jmPriority);

        jmOptions.addSeparator(); 
        jmOptions.add(jmiReset);
        jmb.add(jmOptions);

        // Thêm các thành phần cho menu "Help"
        JMenuItem jmiAbout = new JMenuItem("About");
        jmHelp.add(jmiAbout); jmb.add(jmHelp);

        // Thêm những ActionListeners cho các thành phần của menu bar.
        jmiOpen.addActionListener(this);
        jmiClose.addActionListener(this);
        jmiSave.addActionListener(this);
        jmiExit.addActionListener(this);

        jmiRed.addActionListener(this);
        jmiGreen.addActionListener(this);
        jmiBlue.addActionListener(this);

        jmiHigh.addActionListener(this);
        jmiLow.addActionListener(this);
        jmiReset.addActionListener(this);
        jmiAbout.addActionListener(this);

        return jmb;
    }
    public void actionPerformed(ActionEvent ae) {
        // Lấy action command.
        String comStr = ae.getActionCommand();
        // Thiết lập ngắt khi bấm quit
        if (comStr.equals("Exit")) 
            System.exit(0);
        // Nếu không phải quit
    }
}
