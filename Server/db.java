
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;

import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

//This class and data just create statically for test GUI.
//The real database and how to get it will be update soon !

public class db {
    // static Map<String, Map<String, String>> users = new HashMap<String,
    // Map<String, String>>();

    static final String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";
    static final String DB_URL = "jdbc:mysql://localhost/java_chatting_app";
    static final String USER = "root";
    static final String PASS = "Duongminh410";

    public db() {
    }

    public Connection getConnection(String dbURL, String userName, String password) {
        Connection conn = null;
        try {
            Class.forName(JDBC_DRIVER);
            conn = DriverManager.getConnection(dbURL, userName, password);
            // Return null if error occur and cannot connect to database
        } catch (Exception ex) {
            // Handle exception
            ex.printStackTrace();
        }
        return conn;
    }

    public ArrayList<user> getAllUser() {

        ArrayList<user> allUser = new ArrayList<>();
        // Connect to database
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();
                String sql = "select * from users";

                // Get data from table 'users'
                ResultSet user_rs = st.executeQuery(sql);
                // Import users data
                while (user_rs.next()) {
                    user temp = new user(user_rs.getString("id"), user_rs.getString("name"),
                            user_rs.getString("image"), user_rs.getString("bg"),
                            user_rs.getString("usn"), user_rs.getString("psw"),
                            user_rs.getString("address"), user_rs.getString("dob"),
                            user_rs.getString("sex"), user_rs.getString("email"), user_rs.getString("ban_status"));
                    allUser.add(temp);
                }
            }

            // Close connection
            // conn.close();
            return allUser;
        } catch (SQLException se) {
            se.printStackTrace();
            return null;
        } catch (Exception ex) {
            ex.printStackTrace();
            return null;
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }

    }

    public user getUserByUsername(String username) {
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();
                String sql = String.format("select * from users where usn = '%s'", username);

                // Get data from table 'users'
                ResultSet user_rs = st.executeQuery(sql);
                // Import users data
                if (user_rs.next()) {
                    user temp = new user(user_rs.getString("id"), user_rs.getString("name"),
                            user_rs.getString("image"), user_rs.getString("bg"),
                            user_rs.getString("usn"), user_rs.getString("psw"),
                            user_rs.getString("address"), user_rs.getString("dob"),
                            user_rs.getString("sex"), user_rs.getString("email"), user_rs.getString("ban_status"));
                    // System.out.println(temp.getName());
                    return temp;
                }
                return null;
            }
            // return false;
        } catch (SQLException se) {
            se.printStackTrace();
            // return false;
        } catch (Exception ex) {
            ex.printStackTrace();
            // return false;
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return null;
    }

    public String getIdByUsername(String username) {
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();
                String sql = String.format("select * from users where usn = '%s'", username);

                // Get data from table 'users'
                ResultSet rs = st.executeQuery(sql);
                // Import users data
                if (rs.next()) {
                    return rs.getString("id");
                }
                return null;
            }
            // return false;
        } catch (SQLException se) {
            se.printStackTrace();
            // return false;
        } catch (Exception ex) {
            ex.printStackTrace();
            // return false;
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return null;
    }

    public String getNameById(String id) {
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();
                String sql = String.format("select * from users where id = '%s'", id);

                // Get data from table 'users'
                ResultSet rs = st.executeQuery(sql);
                // Import users data
                if (rs.next()) {
                    return rs.getString("name");
                }
                return null;
            }
            // return false;
        } catch (SQLException se) {
            se.printStackTrace();
            // return false;
        } catch (Exception ex) {
            ex.printStackTrace();
            // return false;
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return null;
    }

    public boolean accountVerification(String username, String password) throws SQLException {
        // Connect to database
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();
                String sql = String.format("select * from users where usn = '%s'", username);

                // Get data from table 'users'
                ResultSet rs = st.executeQuery(sql);
                // Import users data
                if (rs.next()) {
                    if (password.equals(rs.getString("psw"))) {
                        return true;
                    } else
                        return false;
                }
                // return false;
            }
            // return false;
        } catch (SQLException se) {
            se.printStackTrace();
            // return false;
        } catch (Exception ex) {
            ex.printStackTrace();
            // return false;
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return false;
    }

    public boolean checkUsn(String username) throws SQLException {
        // Connect to database
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();
                String sql = String.format("select * from users where usn = '%s'", username);

                // Get data from table 'users'
                ResultSet rs = st.executeQuery(sql);
                // Import users data
                if (!rs.next()) {
                    return true;
                }
                return false;
            }
        } catch (SQLException se) {
            se.printStackTrace();
            // return false;
        } catch (Exception ex) {
            ex.printStackTrace();
            // return false;
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return false;
    }

    public int createNewUser(user newUser) {
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();
                String sql = String.format(
                        "insert into users (id, name, image, usn, psw, address, dob, sex, email) values ('%s','%s','%s','%s','%s','%s','%s','%s','%s');",
                        newUser.getId(), newUser.getName(), newUser.getImage(), newUser.getUsername(),
                        newUser.getPassword(), newUser.getAddress(), newUser.getDob(), newUser.getSex(),
                        newUser.getEmail());

                // Get data from table 'users'

                int a = st.executeUpdate(sql);
                System.out.println("c > " + a);
                return a;
                // return false;
            }
            // return false;
        } catch (SQLException se) {
            se.printStackTrace();
            // return false;
        } catch (Exception ex) {
            ex.printStackTrace();
            // return false;
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return 0;
    }

    public String getAllFriend(String username) {

        // Connect to database
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();
                String sql = String.format("select * from users where usn = '%s'", username);

                // Get data from table 'users'
                ResultSet rs = st.executeQuery(sql);
                // Import users data
                if (rs.next()) {
                    return rs.getString("friend");
                }
            }

        } catch (SQLException se) {
            se.printStackTrace();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return null;
    }

    public String getFriendOnline(String username) {

        // Connect to database
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();
                String sql = String.format("select * from users where usn = '%s'", username);

                // Get data from table 'users'
                ResultSet rs = st.executeQuery(sql);
                // Import users data
                String frdonl = "";
                if (rs.next()) {
                    String[] frl = rs.getString("friend").split("/");
                    for (String fr : frl) {
                        // System.out.println(fr);
                        ResultSet rs2 = st.executeQuery(String.format("select * from users where id = '%s'", fr));
                        if (!rs2.next())
                            continue;
                        // System.out.print(rs2.getString("online_status"));
                        if (rs2.getString("online_status").equals("Online now")) {
                            // System.out.println( " > done");
                            frdonl += fr + "/";
                        }
                        rs2.close();

                    }
                    System.out.println("frdonl> "+ frdonl.length());
                    if (frdonl != null && frdonl != "" && frdonl.length() >= 2)
                        return frdonl.substring(0, frdonl.length() - 1);
                }
                return null;
            }

        } catch (SQLException se) {
            se.printStackTrace();
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return null;
    }

    public int setOnlineStatus(String username, String status) {
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();
                String sql = String.format("update users set online_status = '%s' where usn = '%s' ", status, username);

                int a =  st.executeUpdate(sql);
                System.out.println("status > "+ sql);
                return a;

            }
            return 0;
        } catch (SQLException se) {
            se.printStackTrace();
            // return false;
        } catch (Exception ex) {
            ex.printStackTrace();
            // return false;
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return 0;
    }

    public boolean isFriend(String username, String usernameFr) {
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();
                String sql = String.format("select * from users where usn = '%s'", username);

                // Get data from table 'users'
                ResultSet rs = st.executeQuery(sql);
                // Import users data
                if (rs.next()) {
                    // System.out.println(rs.getString("friend"));
                    String friendid = getIdByUsername(usernameFr);
                    String friendRs = rs.getString("friend");
                    if (friendRs == null) {
                        return false;
                    }
                    String[] friendlist = friendRs.split("/");
                    for (String item : friendlist) {
                        if (item.equals(friendid))
                            return true;
                    }
                }
                return false;
            }
        } catch (SQLException se) {
            se.printStackTrace();
            // return false;
        } catch (Exception ex) {
            ex.printStackTrace();
            // return false;
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return false;
    }

    public int addFriend2Users(String username, String usernameFr) {
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();

                String sql = String.format("select * from users where usn = '%s'", username);

                // Get data from table 'users'
                ResultSet rs = st.executeQuery(sql);
                // Import users data
                if (!rs.next()) {
                    return -1;
                }
                String friendRs = rs.getString("friend");
                rs.close();
                if (friendRs == null)
                    friendRs = getIdByUsername(usernameFr);
                else
                    friendRs += "/" + getIdByUsername(usernameFr);
                String sql2 = String.format("update users set friend = '%s' where usn = '%s'", friendRs, username);
                return st.executeUpdate(sql2);
            }
        } catch (SQLException se) {
            se.printStackTrace();
            // return false;
        } catch (Exception ex) {
            ex.printStackTrace();
            // return false;
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return 0;
    }

    public int unFriend2Users(String username, String usernameFr) {
        Connection conn = getConnection(DB_URL, USER, PASS);
        try {

            // Check connetion result
            if (conn != null) {
                Statement st = conn.createStatement();

                String sql = String.format("select * from users where usn = '%s'", username);

                // Get data from table 'users'
                ResultSet rs = st.executeQuery(sql);
                // Import users data
                if (!rs.next()) {
                    return -1;
                }
                String friendid = getIdByUsername(usernameFr);
                String friendRs = rs.getString("friend");
                System.out.println("conc" + friendRs);
                String sql2 = "";
                if (friendRs.equals(friendid)) {
                    sql2 = String.format("update users set friend = NULL where usn = '%s' ", username);
                } else {
                    String str = "";
                    String[] friendlist = friendRs.split("/");
                    for (String item : friendlist) {
                        if (item.equals(friendid))
                            continue;
                        str += item + "/";
                        System.out.println(item);
                    }
                    str = str.substring(0, str.length() - 1);

                    sql2 = String.format("update users set friend = '%s' where usn = '%s' ", str, username);
                }
                System.out.println(sql2);
                return st.executeUpdate(sql2);
            }
        } catch (SQLException se) {
            se.printStackTrace();
            // return false;
        } catch (Exception ex) {
            ex.printStackTrace();
            // return false;
        } finally {
            try {
                if (conn != null)
                    conn.close();
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
        return 0;
    }

}
