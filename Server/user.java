// import java.util.List;
import java.util.ArrayList;

public class user {
    private String id, name, image, bg, online_status, usn, password, address, dob, sex, email, ban_status;
    private int nofFriends;
    private ArrayList<String>friend;

    public user(String name, String usn, String password, String address, String dob, String sex, String email){
        int count = (new db()).getAllUser().size() + 1;
        this.id = String.format("user_" + count );
        this.name = name;
        this.image = "./assets/imgs/avts/avt_3.png";
        this.usn = usn;
        this.password = password;
        this.address = address;
        this.dob = dob;
        this.sex = sex;
        this.email = email;
        this.friend = new ArrayList<String>();
    }

    public user(String id, String name, String image, String bg, String usn, String password,
            String address, String dob, String sex, String email, String ban_status) {
        this.id = id;
        this.name = name;
        this.image = image;
        this.bg = bg;
        // this.online_status = online_status;
        this.usn = usn;
        this.password = password;
        this.address = address;
        this.dob = dob;
        this.sex = sex;
        this.email = email;
        this.ban_status = ban_status;

    }

    public String getId(){
        return id;
    }
    public String getName(){
        return name;
    }

    public String getImage(){
        return image;
    }

    public String getUsername(){
        return usn;
    }
    public String getPassword(){
        return password;
    }
    public String getAddress(){
        return address;
    }
    public String getDob(){
        return dob;
    }
    public String getSex(){
        return sex;
    }
    public String getEmail(){
        return email;
    }
    public ArrayList<String> getFriend(){
        return friend;
    }

    public void setFriend(String friendStr){
        if (friend != null){
            friend.clear();
        }
        friend = new ArrayList<>();
        while(friendStr.indexOf('/') != -1){
            friend.add(friendStr.substring(0, friendStr.indexOf('/')) );
            friendStr = friendStr.substring(friendStr.indexOf('/') +1 );
        }
        friend.add(friendStr);
    }

}
