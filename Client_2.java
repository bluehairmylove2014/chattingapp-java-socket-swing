import javax.swing.*;
import javax.swing.border.EmptyBorder;

import java.awt.*;
import java.awt.event.*;

import java.io.*;
import java.net.*;
import java.util.ArrayList;

public class Client_2 implements ActionListener {
    JFrame chat_jfrm, usn_jfrm;
    // Client Config
    int portnumber;
    Socket client;
    ClientProcess cp;

    String send_msg_icon = "./assets/imgs/icons/send-message.png";
    ArrayList<ArrayList<String>> chatrooms;

    JPanel currenUser, prevUserPanel, chatPanel, chatSide;
    JTextField inputField;
    JTextArea ta_chat;

    String usn, prevRoom;

    Client_2() {
        this.chat_jfrm = new JFrame("Chatting");
        this.usn_jfrm = new JFrame("Username Request");
        // Client Config
        this.portnumber = 2014;
        this.client = null;
        this.currenUser = new JPanel();
        this.prevUserPanel = null;
        this.chatPanel = new JPanel();
        this.inputField = new JTextField();
        this.ta_chat = new JTextArea();
        this.chatSide = new JPanel();
        this.usn = "";
        this.prevRoom = "";
        
        this.chatrooms = new ArrayList<ArrayList<String>>();

        runUsnRequest();
    }
    void runUsnRequest() {
        // GUI
        usn_jfrm.setLayout(new FlowLayout());
        usn_jfrm.setResizable(false);

        // Tùy chỉnh kích thước     
        usn_jfrm.setSize(800, 600);
        usn_jfrm.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        JPanel wrapper = new JPanel();
        wrapper.setLayout(new BoxLayout(wrapper, BoxLayout.Y_AXIS));
        wrapper.setPreferredSize(new Dimension(800, 600));

        JLabel welcome = new JLabel("WELCOME TO MESSENGER (SHOPEE VERSION)");
        JLabel title = new JLabel("Enter your username");
        welcome.setAlignmentX(Component.CENTER_ALIGNMENT);
        welcome.setFont(new Font("Verdana", Font.BOLD, 20));
        welcome.setBorder(new EmptyBorder(40, 0, 170, 0));
        title.setAlignmentX(Component.CENTER_ALIGNMENT);
        title.setFont(new Font("Verdana", Font.BOLD, 18));

        JPanel usn_input_field = new JPanel();
        usn_input_field.setLayout(new FlowLayout());

        JTextField usn_input = new JTextField();
        usn_input.setColumns(12);
        usn_input.setFont(new Font("Verdana", Font.PLAIN, 18));
        JButton get_usn_btn = new JButton("Enter");
        get_usn_btn.addActionListener(new ActionListener() {  
            public void actionPerformed(java.awt.event.ActionEvent ae){  
                usn = usn_input.getText();
                if(usn != null) {
                    usn_jfrm.setVisible(false); 
                    runChat();
                }
            }  
        });

        usn_input_field.add(usn_input);
        usn_input_field.add(get_usn_btn);
        
        wrapper.add(welcome);
        wrapper.add(title);
        wrapper.add(usn_input_field);

        usn_jfrm.getContentPane().add(wrapper);
        usn_jfrm.pack();
        usn_jfrm.setVisible(true);
    }
    void runChat() {
        // Run Client
        this.cp = new ClientProcess();
        Thread cl_thrd = new Thread(cp);
        cl_thrd.start();

        // GUI
        chat_jfrm.setLayout(new FlowLayout());
        chat_jfrm.setResizable(false);

        // Tùy chỉnh kích thước     
        chat_jfrm.setSize(800, 600);
        
        chat_jfrm.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        chat_jfrm.addWindowListener(new java.awt.event.WindowAdapter() {
            @Override
            public void windowClosing(java.awt.event.WindowEvent windowEvent) {
                cp.getPrintWriter().println("exit");
                try {
                    if(client != null)
                        client.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
                System.exit(0);
            }
        });

        // Contact side
        JPanel contactSide = new JPanel();
        contactSide.setLayout(new BoxLayout(contactSide, BoxLayout.Y_AXIS));
        contactSide.setPreferredSize(new Dimension(250, 600));
        contactSide.setBackground(new Color(255, 255, 255));

        JLabel chatLabel = new JLabel("<html><p style=\"font-family:Verdana;font-size:14px;\">Chats</p></html>");
        chatLabel.setBorder(new EmptyBorder(20, 0, 30, 20));
        contactSide.add(chatLabel);

        this.renderPanel(contactSide, this.generateUserPanel());
        
        // Chat side
        currenUser.setLayout(new BoxLayout(currenUser, BoxLayout.Y_AXIS));
        chatSide.setLayout(new BorderLayout());
        chatSide.setPreferredSize(new Dimension(450, 600));
        chatSide.setBackground(new Color(255, 255, 255));

        // Chat Field
        chatPanel.setLayout(new BorderLayout());
        ta_chat.setMargin(new Insets(30, 10, 20, 10));
        chatPanel.add(ta_chat);
        chatPanel.setVisible(false);

        // Input Field
        JPanel inputMsgPanel = new JPanel();
        inputMsgPanel.setLayout(new FlowLayout());
        inputMsgPanel.setBackground(new Color(255, 255, 255));
        inputMsgPanel.setPreferredSize(new Dimension(450, 60));
        //Create input field
        inputField.setColumns(18);
        inputField.setFont(new Font("Verdana", Font.ITALIC, 20));
        inputField.setMargin(new Insets(0, 10, 0, 10));
        //Create send btn
        ImageIcon scaledIcon = new ImageIcon(ScaleImage(imgLoading(send_msg_icon), 20, 20));
        JButton sendBtn = new JButton(scaledIcon);
        sendBtn.setActionCommand("chat@");
        sendBtn.addActionListener(this);
        inputMsgPanel.add(inputField);
        inputMsgPanel.add(sendBtn);

        
        chatSide.add(currenUser, BorderLayout.NORTH);
        chatSide.add(chatPanel, BorderLayout.CENTER);
        chatSide.add(inputMsgPanel, BorderLayout.SOUTH);

        chat_jfrm.getContentPane().add(contactSide);
        chat_jfrm.getContentPane().add(chatSide);
        chat_jfrm.pack();
        chat_jfrm.setVisible(true);
    }
    void renderCurrentUser(JPanel root, String id) {
        if(prevUserPanel != null) {
            root.remove(prevUserPanel);
        }
        for(int i = 0; i < chatrooms.size(); i++) {
            if(chatrooms.get(i).get(0).equals(id)) {
                //Create a sub panel
                JPanel user_info_Panel = new JPanel();
                user_info_Panel.setLayout(new BoxLayout(user_info_Panel, BoxLayout.X_AXIS));

                    //Get avt image
                Image originalIcon = imgLoading(chatrooms.get(i).get(2));

                    //Scale the original image
                ImageIcon scaledIcon = new ImageIcon(ScaleImage(originalIcon, 50, 50));
                JLabel avtLabel = new JLabel(scaledIcon);
                avtLabel.setBorder(new EmptyBorder(0, 0, 0, 10));

                    // Text partial
                String userName = chatrooms.get(i).get(1);

                JLabel textPartial = new JLabel("<html><p style=\"font-family:Verdana;font-size:10px;\">"  + userName + "<html>");

                user_info_Panel.add(avtLabel);
                user_info_Panel.add(textPartial);

                root.add(user_info_Panel);
                prevUserPanel = user_info_Panel;
                break;
            }
        }
    }
    void renderPanel(JPanel target, JPanel[] element) {
        int size = element.length;
        for(int i = 0; i < size; i++)
            target.add(element[i]);
    }
    JPanel[] generateUserPanel() {
        // Get the valid size
        JPanel[] user_panel_list = new JPanel[chatrooms.size()];

        // Generate panel
        for(int i = 0; i < chatrooms.size(); i++) {
            JPanel btnPanel = new JPanel();
            btnPanel.setLayout(new BorderLayout());
            btnPanel.setMaximumSize(new Dimension(250, 60));

                //Get avt image
            Image originalIcon = new ImageIcon(chatrooms.get(i).get(2)).getImage();

                //Scale the original image
            ImageIcon scaledIcon = new ImageIcon(originalIcon.getScaledInstance(60, 60, Image.SCALE_SMOOTH));
            JButton userBtn = new JButton(chatrooms.get(i).get(1), scaledIcon);
            userBtn.setHorizontalAlignment(SwingConstants.LEFT);
            userBtn.setMargin(new Insets(0,0,0,0));
            userBtn.setContentAreaFilled(false);
            userBtn.setActionCommand("@toroomid@" + chatrooms.get(i).get(0));
            userBtn.addActionListener(this);

            btnPanel.add(userBtn);
            user_panel_list[i] = btnPanel;
        }

        return user_panel_list;
    }

    public class ClientProcess implements Runnable {
        PrintWriter pw = null;
        BufferedReader br = null;
        String msg = "";
        Thread msgReceiver;

        ClientProcess() {
            try {
                // Create a client socket
                client = new Socket(InetAddress.getLocalHost(), portnumber);
                System.out.println("Client socket is created " + client);
                
                // Create an output stream of the client socket
                OutputStream clientOut = client.getOutputStream();
                pw = new PrintWriter(clientOut, true);
                
                // Create an input stream of the client socket
                InputStream clientIn = client.getInputStream();
                br = new BufferedReader(new InputStreamReader(clientIn));

                // Get chatroom data
                pw.println("get_chatroom_data");
                String res = br.readLine();
                while(!res.equals("end")) {
                    ArrayList<String> chatroom = new ArrayList<String>();
                    while(!res.equals("end")) {
                        chatroom.add(res);
                        res = br.readLine();
                    }
                    chatrooms.add(chatroom);
                    // Get next chatroom
                    res = br.readLine();
                }

                // Set username
                pw.println("usn@" + usn);
                
            } catch (IOException ioe) {
                System.err.println("Error: " + ioe);
            }
            
            msgReceiver = new Thread(new Runnable() {
                @Override
                public void run() {
                    try {
                        while (true) {
                            String command = br.readLine();
                            if(command.contains("newmsg@")) {
                                String msg = command.substring(command.lastIndexOf("@") + 1);
                                // Gui handle
                                ta_chat.append(msg + "\n");
                                chatSide.revalidate();
                                chatSide.repaint();
                            }
                            else if(command.contains("sending_chat_history")) {
                                String crdata = "";
                                String res = br.readLine();
                                while(!res.equals("end")) {
                                    crdata += (res + "\n");
                                    res = br.readLine();
                                }
                                // Gui handle
             
                                ta_chat.setText(crdata);
                                chatSide.revalidate();
                                chatSide.repaint();
                            }
                        }
                    } catch(IOException ioe) {
                        System.err.println("Error receiver: " + ioe);
                    }
                }
            });
        }

        // Public method
        public PrintWriter getPrintWriter() {
            return pw;
        }
        public BufferedReader BufferedReader() {
            return br;
        }

        public void run() {
            // Waiting for any command from server such as "update, refresh,..."
            msgReceiver.start();
        }
    }

    Image imgLoading(String filepath) {
        ImageIcon icon = new ImageIcon(filepath);
        return icon.getImage();
    }
    ImageIcon IconLoading(String filepath) {
        ImageIcon icon = new ImageIcon(filepath);
        return icon;
    }
    Image ScaleImage(Image img, int width, int height) {
        Image scaled = img.getScaledInstance(width, height, Image.SCALE_SMOOTH);
        return scaled;
    }

    public void actionPerformed(java.awt.event.ActionEvent ae) {
        // Lấy action command.
        String comStr = ae.getActionCommand();
        if (comStr.contains("@toroomid@"))  {
            String nextRoom = comStr.substring(comStr.lastIndexOf("@") + 1);
            if(currenUser.getComponentCount() == 0) {
                chatPanel.setVisible(true);
            }
            this.renderCurrentUser(currenUser, nextRoom);
            cp.getPrintWriter().println(prevRoom + comStr);
            prevRoom = nextRoom;
        }
        else if (comStr.contains("chat@"))  {
            String msg = inputField.getText();
            if(msg != null && currenUser.getComponentCount() != 0) {
                cp.getPrintWriter().println(comStr + msg);
                // Gui handle
                ta_chat.append(usn + ": " + msg + "\n");
                inputField.setText(null);
            }
        }
    }

    public static void main(String args[]) {
        // Create the frame on the event dispatching thread.
        SwingUtilities.invokeLater(new Runnable() {
            public void run() { new Client_2(); }
        });
    }
}