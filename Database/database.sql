DROP DATABASE IF EXISTS Java_chatting_app;
CREATE SCHEMA Java_chatting_app;

use Java_chatting_app;

CREATE TABLE user_login_history
(
	his_id VARCHAR(45) NOT NULL,
	user_id VARCHAR(45) NOT NULL,
	device_name VARCHAR(45) NOT NULL,
	location VARCHAR(45) NOT NULL,
	online_status VARCHAR(45) NOT NULL,
	device_icon VARCHAR(45) NOT NULL,
	
    PRIMARY KEY (his_id, user_id)
);

CREATE TABLE users
(
	id VARCHAR(8) NOT NULL,
    name VARCHAR(45),
    image VARCHAR(500),
    bg VARCHAR(45),
    online_status VARCHAR(60),
    usn VARCHAR(20),
    psw VARCHAR(100),
    address VARCHAR(100),
    dob VARCHAR(45),
    sex VARCHAR(7),
    email VARCHAR(100),
    nofFriends varchar(3),
    friend varchar(500),
    ban_status varchar(10),
    createAt varchar(45),

	PRIMARY KEY (id)
);

create table group_chat 
(
	id varchar(8) not null,
	group_name varchar(60),
	image varchar(100),
    createdAt varchar(45),
    admin_id varchar(8) not null, 

	primary key (id)
);

create table group_chat_users
(
	group_id varchar(8),
    user_id varchar(8),

	primary key (group_id, user_id)
);

create table chat_history
(
	send varchar(8),
    receive varchar(8),
	message varchar(500) charset utf8,
    send_at varchar(45),
	
    primary key (send, receive, message, send_at)
);

create table delete_chat_time_stamp
(
	chat_from varchar(8),
	chat_to varchar(8),
    delete_at varchar(45),
	
    primary key (chat_from, chat_to, delete_at)
);

-- =================== PROCEDURE ===================

use java_chatting_app;

drop procedure if exists getUsersOfGroup;
DELIMITER //
create procedure getUsersOfGroup (
	in group_id varchar(8)
)
begin
	select gp.user_id from group_chat_users gp
	where gp.group_id = group_id;
end //
DELIMITER ;

drop procedure if exists getFriendsAndGroups;
DELIMITER //
create procedure getFriendsAndGroups (
    in user_id varchar(8)
)
begin
    select distinct(group_id) as id, group_name as name, image
    from group_chat gc left join group_chat_users gcu on gc.id = gcu.group_id
    where gcu.user_id = user_id
    union
    select id, name, image
    from users u
    where friend like concat('%', user_id, '%') and not (id = user_id);
end //
DELIMITER ;

call getFriendsAndGroups('user_2');

drop procedure if exists getAllHistory;
DELIMITER //
create procedure getAllHistory(
    in user_id varchar(8)
)
begin
	select send, sender_name, receive, receiver_name, message 
	from (
	select * from chat_history chat 
	left join delete_chat_time_stamp dlt_chat on chat_from=user_id and chat_to=chat.receive
	where send = user_id and (delete_at is null or send_at > delete_at)
    order by chat.send_at
	) chat_his
	left join (select id, name sender_name from users) nameSend on nameSend.id = chat_his.send
	left join (
		select id, group_name receiver_name from group_chat 
		union
		select id, name sender_name from users
	) nameRecv on nameRecv.id = chat_his.receive;
end //
DELIMITER ;

drop procedure if exists getGroupChatHistory;
DELIMITER //
create procedure getGroupChatHistory (
	in user_id varchar(8),
	in group_id varchar(8)
)
begin
	if exists (select * from delete_chat_time_stamp
				where chat_from = user_id 
                and chat_to = group_id)
	then
		select send, sender_name, receive, receiver_name, message, send_at 
        from (select * from chat_history chat
			where chat.receive = group_id
				and chat.send_at > (select dlt_chat.delete_at 
							from delete_chat_time_stamp dlt_chat 
							where dlt_chat.chat_from = user_id
								and dlt_chat.chat_to = group_id limit 1)) chat_his
		left join (select id, name sender_name from users) nameSend on nameSend.id = chat_his.send
        left join (select id, group_name receiver_name from group_chat) nameRecv on nameRecv.id = chat_his.receive
		order by send_at;
    else
		select send, sender_name, receive, receiver_name, message, send_at 
        from (select * from chat_history chat
				where chat.receive = group_id) chat_his
		left join (select id, name sender_name from users) nameSend on nameSend.id = chat_his.send
        left join (select id, group_name receiver_name from group_chat) nameRecv on nameRecv.id = chat_his.receive
		order by send_at;
    end if;
end //
DELIMITER ;

drop procedure if exists getPrivateChatHistory;
DELIMITER //
create procedure getPrivateChatHistory (
	in send_id varchar(8),
	in receive_id varchar(8)
)
begin
	if exists (select * from delete_chat_time_stamp
				where chat_from = send_id 
                and chat_to = receive_id)
	then
		select send, sender_name, receive, receiver_name, message, send_at 
        from (select * from chat_history chat
			where (chat.send = send_id and chat.receive = receive_id) or (chat.send = receive_id and chat.receive = send_id)
				and chat.send_at > (select dlt_chat.delete_at 
							from delete_chat_time_stamp dlt_chat 
							where dlt_chat.chat_from = send_id
								and dlt_chat.chat_to = receive_id limit 1)) chat_his
        left join (select id, name sender_name from users) nameSend on nameSend.id = chat_his.send
        left join (select id, name receiver_name from users) nameRecv on nameRecv.id = chat_his.receive
        order by send_at;
    else
		select send, sender_name, receive, receiver_name, message, send_at 
        from (select * from chat_history chat
				where (chat.send = send_id and chat.receive = receive_id) or (chat.send = receive_id and chat.receive = send_id)
			) chat_his
        left join (select id, name sender_name from users) nameSend on nameSend.id = chat_his.send
        left join (select id, name receiver_name from users) nameRecv on nameRecv.id = chat_his.receive
        order by send_at;
    end if;
end //
DELIMITER ;

call getPrivateChatHistory('user_2', 'user_1');

drop procedure if exists deleteChatHistory;
DELIMITER //
create procedure deleteChatHistory (
	in send_id varchar(8),
	in receive_id varchar(8)
)
begin 
	if exists (select * from delete_chat_time_stamp
				where chat_from = send_id 
                and chat_to = receive_id)
	then
		update delete_chat_time_stamp set delete_at = DATE_FORMAT(NOW(), '%Y/%m/%d %T')
        where chat_from = send_id and chat_to = receive_id;
	else
		insert into delete_chat_time_stamp values (send_id, receive_id, DATE_FORMAT(NOW(), '%Y/%m/%d %T'));
    end if;
end //
DELIMITER ;

drop procedure if exists addChat;
DELIMITER //
create procedure addChat (
	in send_id varchar(8),
	in receive_id varchar(8),
    in messages varchar(500) charset utf8
)
begin 
	insert into chat_history values (send_id, receive_id, messages, DATE_FORMAT(NOW(), '%Y/%m/%d %T'));
end //
DELIMITER ;

-- =================== DATA ===================

insert into users values ('user_1', 'Phan Duong Minh', './assets/imgs/avts/avt_3.png', './assets/imgs/bgs/bg-3.png', 'Last online about an hour ago', 'minhminh0410', '123456', '27/476 Cho Hang Moi Street, Du Hang Kenh Ward, Hai Phong City', '4-10-2002', 'male', 'dm410@gmail.com', '8', 'user_3/user_2/user_6/user_11/user_12/user_4', 'normal', '2022/03/14 15:41:58');
insert into users values ('user_10', 'Biff Wellington', './assets/imgs/avts/avt_5.png', './assets/imgs/bgs/bg-5.png', 'Last online August 14 at 12:38 AM', 'BiffWellington', '123456', 'Lot 32, An Don Industrial Park, Da Nang City', '7-8-1987', 'male', 'BiffWellington@gmail.com', '7', 'user_1/user_2/user_3/user_5/user_4/user_7/user_9', 'normal', '2022/09/02 21:40:55');
insert into users values ('user_11', 'Barb E. Dahl', './assets/imgs/avts/avt_9.png', './assets/imgs/bgs/bg-9.png', 'Last online August 14 at 12:38 AM', 'BarbEDahl', '123456', 'Floor 8, Sun Wah Tower 115 Nguyen Hue Street , Ben Nghe Ward, Ho Chi Minh City', '7-8-1987', 'male', 'BarbEDahl@gmail.com', '7', 'user_1/user_2/user_3/user_5/user_4/user_7/user_9', 'normal', '2022/10/14 12:28:47');
insert into users values ('user_12', 'Adam Zapel', './assets/imgs/avts/avt_11.png', './assets/imgs/bgs/bg-11.png', 'Last online August 9 at 12:22 PM', 'AdamZapel', '123456', 'Floor 6, 8 Nguyen Hue, Ben Nghe Ward, Ho Chi Minh City', '7-8-1987', 'male', 'AdamZapel@gmail.com', '7', 'user_1/user_2/user_3/user_5/user_4/user_7/user_9', 'normal', '2022/12/10 17:31:33');
insert into users values ('user_2', 'Phan Phuc Dat', './assets/imgs/avts/avt_2.png', './assets/imgs/bgs/bg-2.png', 'Online now', 'pd', '123', 'Hamlet Binh Tien 1, lo 825, Xa Duc Hoa Ha, Long An', '28-8-2002', 'male', 'pd2808@gmail.com', '6', 'user_1/user_3/user_2/user_7/user_10/user_4', 'normal', '2022/12/09 01:16:35');
insert into users values ('user_3', 'Nguyen Ba Phuong', './assets/imgs/avts/avt_1.png', './assets/imgs/bgs/bg-1.png', 'Last online November 27 at 11:28 AM', 'nguyenbaphuong', '123456', 'unknown', 'unknown', 'female', 'unknown', '11', 'user_1/user_5/user_2/user_6/user_7/user_9/user_10/user_11/user_12/user_4/user_12', 'normal', '2023/01/06 11:12:42');
insert into users values ('user_4', 'Hoang Dieu Linh', './assets/imgs/avts/avt_8.png', './assets/imgs/bgs/bg-8.png', 'Last online October 30 at 9:55 PM', 'dieulinh113', '123456', '1/18 Su Van Hanh Street, Ward 12, District 10, Ho Chi Minh City', '27-8-2003', 'female', 'dl1130@gmail.com', '10', 'user_3/user_1/user_5/user_2/user_6/user_7/user_9/user_10/user_11/user_12', 'normal', '2022/07/13 15:57:11');
insert into users values ('user_5', 'Ngo Anh Hung', './assets/imgs/avts/avt_7.png', './assets/imgs/bgs/bg-7.png', 'Last online 23 hours ago', 'anhhungngo', '123456', '18B Cong Hoa Street, Ward 4, Tan Binh District, Ho Chi Minh City', '28-2-2000', 'male', 'anhhungngo@gmail.com', '4', 'user_4/user_10/user_1/user_3', 'normal', '2022/11/22 06:36:27');
insert into users values ('user_6', 'Phan Duong Tung Anh', './assets/imgs/avts/avt_6.png', './assets/imgs/bgs/bg-6.png', 'Last online about an hour ago', 'tunganhdaddy', '123456', '37/8A Quang Trung, Ward 10, Go Vap District, Ho Chi Minh City', '7-8-1987', 'male', 'tunganh@gmail.com', '7', 'user_1/user_2/user_3/user_5/user_4/user_7/user_9', 'normal', '2022/03/06 03:59:17');
insert into users values ('user_7', 'Earl E. Bird', './assets/imgs/avts/avt_4.png', './assets/imgs/bgs/bg-4.png', 'Last online August 30 at 9:44 PM', 'EarlEBird', '123456', '1C/236 Le Trong Tan, Khuong Mai Ward, Thanh Xuan Dist, Hanoi', '7-8-1987', 'male', 'EarlEBird@gmail.com', '7', 'user_1/user_2/user_3/user_5/user_4/user_7/user_9', 'normal', '2022/09/18 12:17:58');
insert into users values ('user_8', 'Don Key', './assets/imgs/avts/avt_12.png', './assets/imgs/bgs/bg-12.png', 'Last online August 17 at 10:42 PM', 'DonKey', '123456', '68 Group 1, hamlet 1a, Loc Ninh Town, Binh Phuoc', '7-8-1987', 'male', 'DonKey@gmail.com', '7', 'user_1/user_2/user_3/user_5/user_4/user_7/user_9', 'normal', '2022/09/13 16:15:30');
insert into users values ('user_9', 'Charity Case', './assets/imgs/avts/avt_10.png', './assets/imgs/bgs/bg-10.png', 'Last online August 17 at 3:57 PM', 'CharityCase', '123456', '12M Nguyen Thi Minh Khai, Da Kao, Dist.1, Ho Chi Minh City', '7-8-1987', 'male', 'CharityCase@gmail.com', '7', 'user_1/user_2/user_3/user_5/user_4/user_7/user_9', 'normal', '2022/08/31 07:05:50');

insert into chat_history values ('user_1', 'group_1', '2', '2023/01/08 15:37:54');
insert into chat_history values ('user_1', 'group_1', 'Alo Tôi là người Việt Nam', '2023/01/08 15:33:40');
insert into chat_history values ('user_1', 'group_1', 'hé lô mấy cưng', '2023/01/08 00:13:37');
insert into chat_history values ('user_1', 'group_1', 'toi la minh', '2023/01/08 15:38:02');
insert into chat_history values ('user_1', 'group_1', 'Ừ chúc mừng mày', '2023/01/08 15:41:41');
insert into chat_history values ('user_1', 'group_1', 'Đảk vậy đ.chí', '2023/01/08 00:15:20');
insert into chat_history values ('user_1', 'user_2', 'Chao ban toi la Duong Minh id user_1', '2023/01/08 15:10:51');
insert into chat_history values ('user_1', 'user_2', 'chao ta lai gap nhau', '2023/01/08 15:15:26');
insert into chat_history values ('user_1', 'user_2', 'Hello ban dep trai', '2023/01/08 14:58:00');
insert into chat_history values ('user_1', 'user_2', 'Seen', '2023/01/09 09:13:42');
insert into chat_history values ('user_1', 'user_2', 'Toi la user 1', '2023/01/08 15:08:14');
insert into chat_history values ('user_1', 'user_2', 'Toi la user_1', '2023/01/08 15:02:51');
insert into chat_history values ('user_1', 'user_2', 'Ừ tiếng việt', '2023/01/08 15:27:09');
insert into chat_history values ('user_1', 'user_2', 'Viet nam number 1', '2023/01/08 15:26:44');
insert into chat_history values ('user_1', 'user_2', 'Ý gì', '2023/01/08 15:42:10');
insert into chat_history values ('user_1', 'user_2', 'Đấm nhau không?', '2023/01/08 15:42:17');
insert into chat_history values ('user_2', 'group_1', '1', '2023/01/08 15:37:46');
insert into chat_history values ('user_2', 'group_1', 'adasda', '2023/01/08 15:41:00');
insert into chat_history values ('user_2', 'group_1', 'Alo toi la dat', '2023/01/08 15:28:02');
insert into chat_history values ('user_2', 'group_1', 'Del cần m chúc', '2023/01/08 15:41:51');
insert into chat_history values ('user_2', 'group_1', 'Duong roi', '2023/01/08 15:41:05');
insert into chat_history values ('user_2', 'group_1', 'Lô con kẹc', '2023/01/08 00:14:41');
insert into chat_history values ('user_2', 'group_1', 'qweqeqe', '2023/01/08 15:39:28');
insert into chat_history values ('user_2', 'group_1', 'Thanh Cong Roi', '2023/01/08 15:41:10');
insert into chat_history values ('user_2', 'group_2', 'Chào mọi người', '2023/01/08 00:20:42');
insert into chat_history values ('user_2', 'user_1', 'ai do', '2023/01/08 15:07:50');
insert into chat_history values ('user_2', 'user_1', 'Alo', '2023/01/08 15:50:17');
insert into chat_history values ('user_2', 'user_1', 'chao', '2023/01/08 15:07:12');
insert into chat_history values ('user_2', 'user_1', 'chao ban', '2023/01/08 14:58:40');
insert into chat_history values ('user_2', 'user_1', 'Chao cc toi la Phan Phuc Dat user 2', '2023/01/08 15:11:07');
insert into chat_history values ('user_2', 'user_1', 'Chao dchi', '2023/01/08 15:51:51');
insert into chat_history values ('user_2', 'user_1', 'Chúc chúc cl', '2023/01/08 15:42:02');
insert into chat_history values ('user_2', 'user_1', 'dbndfn', '2023/01/08 15:40:56');
insert into chat_history values ('user_2', 'user_1', 'Em ăn cơm chưa', '2023/01/08 00:13:45');
insert into chat_history values ('user_2', 'user_1', 'hello', '2023/01/08 15:01:10');
insert into chat_history values ('user_2', 'user_1', 'Hi em', '2023/01/08 00:13:41');
insert into chat_history values ('user_2', 'user_1', 'Thích thì chiều', '2023/01/08 15:42:24');
insert into chat_history values ('user_2', 'user_1', 'Tiếng việt à', '2023/01/08 15:27:03');
insert into chat_history values ('user_2', 'user_1', 'Vl luon dau cat moi', '2023/01/08 15:26:57');

insert into group_chat values ('group_1', 'Hoi Hoang Kim', './assets/imgs/group_avts/g1.png', '2023/01/06 11:12:42', 'user_3');
insert into group_chat values ('group_2', '4 anh em sieu nhan', './assets/imgs/group_avts/g2.png', '2022/09/18 12:17:58', 'user_1');
insert into group_chat values ('group_3', 'Hoi Tam Hoang', './assets/imgs/group_avts/g3.png', '2022/09/02 21:40:55', 'user_2');
insert into group_chat values ('group_4', 'Long Xao Dua', './assets/imgs/group_avts/g4.png', '2022/03/06 03:59:17', 'user_3');
insert into group_chat values ('group_5', 'Hoi Chi Em', './assets/imgs/group_avts/g5.png', '2022/08/31 07:05:50', 'user_4');
insert into group_chat values ('group_6', 'Dau Cat moi', './assets/imgs/group_avts/g6.png', '2022/09/13 16:15:30', 'user_5');

insert into group_chat_users values ('group_1', 'user_1');
insert into group_chat_users values ('group_1', 'user_3');
insert into group_chat_users values ('group_1', 'user_5');
insert into group_chat_users values ('group_2', 'user_1');
insert into group_chat_users values ('group_2', 'user_2');
insert into group_chat_users values ('group_2', 'user_4');
insert into group_chat_users values ('group_2', 'user_6');
insert into group_chat_users values ('group_3', 'user_2');
insert into group_chat_users values ('group_3', 'user_6');
insert into group_chat_users values ('group_3', 'user_7');
insert into group_chat_users values ('group_4', 'user_2');
insert into group_chat_users values ('group_4', 'user_3');
insert into group_chat_users values ('group_5', 'user_1');
insert into group_chat_users values ('group_5', 'user_2');
insert into group_chat_users values ('group_5', 'user_3');
insert into group_chat_users values ('group_5', 'user_4');
insert into group_chat_users values ('group_6', 'user_10');
insert into group_chat_users values ('group_6', 'user_11');
insert into group_chat_users values ('group_6', 'user_12');
insert into group_chat_users values ('group_6', 'user_5');


insert into user_login_history values ('his_1', 'user_1', 'Window PC', 'Ho Chi Minh City, Vietnam', 'Active now', 'window');
insert into user_login_history values ('his_1', 'user_10', 'Window PC', 'Ho Chi Minh City, Vietnam', 'Active now', 'window');
insert into user_login_history values ('his_1', 'user_11', 'Window PC', 'Ho Chi Minh City, Vietnam', 'Active now', 'window');
insert into user_login_history values ('his_1', 'user_12', 'Window PC', 'Ho Chi Minh City, Vietnam', 'Active now', 'window');
insert into user_login_history values ('his_1', 'user_2', 'Windows PC', 'Ho Chi Minh City, Vietnam', 'Active now', 'window');
insert into user_login_history values ('his_1', 'user_3', 'Windows PC', 'Ho Chi Minh City, Vietnam', 'Active now', 'window');
insert into user_login_history values ('his_1', 'user_4', 'Window PC', 'Ho Chi Minh City, Vietnam', 'Active now', 'window');
insert into user_login_history values ('his_1', 'user_5', 'Window PC', 'Ho Chi Minh City, Vietnam', 'Active now', 'window');
insert into user_login_history values ('his_1', 'user_6', 'Window PC', 'Ho Chi Minh City, Vietnam', 'Active now', 'window');
insert into user_login_history values ('his_1', 'user_7', 'Window PC', 'Ho Chi Minh City, Vietnam', 'Active now', 'window');
insert into user_login_history values ('his_1', 'user_8', 'Window PC', 'Ho Chi Minh City, Vietnam', 'Active now', 'window');
insert into user_login_history values ('his_1', 'user_9', 'Window PC', 'Ho Chi Minh City, Vietnam', 'Active now', 'window');
insert into user_login_history values ('his_2', 'user_1', 'iMac', 'Ho Chi Minh City, Vietnam', 'about an hour ago', 'mac');
insert into user_login_history values ('his_2', 'user_10', 'iMac', 'Ho Chi Minh City, Vietnam', 'about an hour ago', 'mac');
insert into user_login_history values ('his_2', 'user_11', 'iMac', 'Ho Chi Minh City, Vietnam', 'about an hour ago', 'mac');
insert into user_login_history values ('his_2', 'user_12', 'iMac', 'Ho Chi Minh City, Vietnam', 'about an hour ago', 'mac');
insert into user_login_history values ('his_2', 'user_2', 'iMac', 'Ho Chi Minh City, Vietnam', 'about an hour ago', 'mac');
insert into user_login_history values ('his_2', 'user_3', 'iMac', 'Ho Chi Minh City, Vietnam', 'about an hour ago', 'mac');
insert into user_login_history values ('his_2', 'user_4', 'iMac', 'Ho Chi Minh City, Vietnam', 'about an hour ago', 'mac');
insert into user_login_history values ('his_2', 'user_5', 'iMac', 'Ho Chi Minh City, Vietnam', 'about an hour ago', 'mac');
insert into user_login_history values ('his_2', 'user_6', 'iMac', 'Ho Chi Minh City, Vietnam', 'about an hour ago', 'mac');
insert into user_login_history values ('his_2', 'user_7', 'iMac', 'Ho Chi Minh City, Vietnam', 'about an hour ago', 'mac');
insert into user_login_history values ('his_2', 'user_8', 'iMac', 'Ho Chi Minh City, Vietnam', 'about an hour ago', 'mac');
insert into user_login_history values ('his_2', 'user_9', 'iMac', 'Ho Chi Minh City, Vietnam', 'about an hour ago', 'mac');
insert into user_login_history values ('his_3', 'user_1', 'Linux PC', 'Ho Chi Minh City, Vietnam', 'Yesterday at 9:54 PM', 'linux');
insert into user_login_history values ('his_3', 'user_10', 'Linux PC', 'Ho Chi Minh City, Vietnam', 'Yesterday at 9:54 PM', 'linux');
insert into user_login_history values ('his_3', 'user_11', 'Linux PC', 'Ho Chi Minh City, Vietnam', 'Yesterday at 9:54 PM', 'linux');
insert into user_login_history values ('his_3', 'user_12', 'Linux PC', 'Ho Chi Minh City, Vietnam', 'Yesterday at 9:54 PM', 'linux');
insert into user_login_history values ('his_3', 'user_2', 'Linux PC', 'Ho Chi Minh City, Vietnam', 'Yesterday at 9:54 PM', 'linux');
insert into user_login_history values ('his_3', 'user_3', 'Linux PC', 'Ho Chi Minh City, Vietnam', 'Yesterday at 9:54 PM', 'linux');
insert into user_login_history values ('his_3', 'user_4', 'Linux PC', 'Ho Chi Minh City, Vietnam', 'Yesterday at 9:54 PM', 'linux');
insert into user_login_history values ('his_3', 'user_5', 'Linux PC', 'Ho Chi Minh City, Vietnam', 'Yesterday at 9:54 PM', 'linux');
insert into user_login_history values ('his_3', 'user_6', 'Linux PC', 'Ho Chi Minh City, Vietnam', 'Yesterday at 9:54 PM', 'linux');
insert into user_login_history values ('his_3', 'user_7', 'Linux PC', 'Ho Chi Minh City, Vietnam', 'Yesterday at 9:54 PM', 'linux');
insert into user_login_history values ('his_3', 'user_8', 'Linux PC', 'Ho Chi Minh City, Vietnam', 'Yesterday at 9:54 PM', 'linux');
insert into user_login_history values ('his_3', 'user_9', 'Linux PC', 'Ho Chi Minh City, Vietnam', 'Yesterday at 9:54 PM', 'linux');
insert into user_login_history values ('his_4', 'user_1', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 27 at 11:28 AM', 'window');
insert into user_login_history values ('his_4', 'user_10', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 27 at 11:28 AM', 'window');
insert into user_login_history values ('his_4', 'user_11', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 27 at 11:28 AM', 'window');
insert into user_login_history values ('his_4', 'user_12', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 27 at 11:28 AM', 'window');
insert into user_login_history values ('his_4', 'user_2', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 27 at 11:28 AM', 'window');
insert into user_login_history values ('his_4', 'user_3', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 27 at 11:28 AM', 'window');
insert into user_login_history values ('his_4', 'user_4', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 27 at 11:28 AM', 'window');
insert into user_login_history values ('his_4', 'user_5', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 27 at 11:28 AM', 'window');
insert into user_login_history values ('his_4', 'user_6', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 27 at 11:28 AM', 'window');
insert into user_login_history values ('his_4', 'user_7', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 27 at 11:28 AM', 'window');
insert into user_login_history values ('his_4', 'user_8', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 27 at 11:28 AM', 'window');
insert into user_login_history values ('his_4', 'user_9', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 27 at 11:28 AM', 'window');
insert into user_login_history values ('his_5', 'user_1', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 5 at 2:38 PM', 'window');
insert into user_login_history values ('his_5', 'user_10', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 5 at 2:38 PM', 'window');
insert into user_login_history values ('his_5', 'user_11', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 5 at 2:38 PM', 'window');
insert into user_login_history values ('his_5', 'user_12', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 5 at 2:38 PM', 'window');
insert into user_login_history values ('his_5', 'user_2', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 5 at 2:38 PM', 'window');
insert into user_login_history values ('his_5', 'user_3', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 5 at 2:38 PM', 'window');
insert into user_login_history values ('his_5', 'user_4', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 5 at 2:38 PM', 'window');
insert into user_login_history values ('his_5', 'user_5', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 5 at 2:38 PM', 'window');
insert into user_login_history values ('his_5', 'user_6', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 5 at 2:38 PM', 'window');
insert into user_login_history values ('his_5', 'user_7', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 5 at 2:38 PM', 'window');
insert into user_login_history values ('his_5', 'user_8', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 5 at 2:38 PM', 'window');
insert into user_login_history values ('his_5', 'user_9', 'Window PC', 'Ho Chi Minh City, Vietnam', 'November 5 at 2:38 PM', 'window');
insert into user_login_history values ('his_6', 'user_1', 'iMac', 'Ho Chi Minh City, Vietnam', 'October 30 at 9:55 PM', 'mac');
insert into user_login_history values ('his_6', 'user_10', 'iMac', 'Ho Chi Minh City, Vietnam', 'October 30 at 9:55 PM', 'mac');
insert into user_login_history values ('his_6', 'user_11', 'iMac', 'Ho Chi Minh City, Vietnam', 'October 30 at 9:55 PM', 'mac');
insert into user_login_history values ('his_6', 'user_12', 'iMac', 'Ho Chi Minh City, Vietnam', 'October 30 at 9:55 PM', 'mac');
insert into user_login_history values ('his_6', 'user_2', 'iMac', 'Ho Chi Minh City, Vietnam', 'October 30 at 9:55 PM', 'mac');
insert into user_login_history values ('his_6', 'user_3', 'iMac', 'Ho Chi Minh City, Vietnam', 'October 30 at 9:55 PM', 'mac');
insert into user_login_history values ('his_6', 'user_4', 'iMac', 'Ho Chi Minh City, Vietnam', 'October 30 at 9:55 PM', 'mac');
insert into user_login_history values ('his_6', 'user_5', 'iMac', 'Ho Chi Minh City, Vietnam', 'October 30 at 9:55 PM', 'mac');
insert into user_login_history values ('his_6', 'user_6', 'iMac', 'Ho Chi Minh City, Vietnam', 'October 30 at 9:55 PM', 'mac');
insert into user_login_history values ('his_6', 'user_7', 'iMac', 'Ho Chi Minh City, Vietnam', 'October 30 at 9:55 PM', 'mac');
insert into user_login_history values ('his_6', 'user_8', 'iMac', 'Ho Chi Minh City, Vietnam', 'October 30 at 9:55 PM', 'mac');
insert into user_login_history values ('his_6', 'user_9', 'iMac', 'Ho Chi Minh City, Vietnam', 'October 30 at 9:55 PM', 'mac');
insert into user_login_history values ('his_7', 'user_1', 'Window PC', 'Ho Chi Minh City, Vietnam', 'October 15 at 9:15 PM', 'window');
insert into user_login_history values ('his_7', 'user_10', 'Window PC', 'Ho Chi Minh City, Vietnam', 'October 15 at 9:15 PM', 'window');
insert into user_login_history values ('his_7', 'user_11', 'Window PC', 'Ho Chi Minh City, Vietnam', 'October 15 at 9:15 PM', 'window');
insert into user_login_history values ('his_7', 'user_12', 'Window PC', 'Ho Chi Minh City, Vietnam', 'October 15 at 9:15 PM', 'window');
insert into user_login_history values ('his_7', 'user_2', 'Window PC', 'Ho Chi Minh City, Vietnam', 'October 15 at 9:15 PM', 'window');
insert into user_login_history values ('his_7', 'user_3', 'Window PC', 'Ho Chi Minh City, Vietnam', 'October 15 at 9:15 PM', 'window');
insert into user_login_history values ('his_7', 'user_4', 'Window PC', 'Ho Chi Minh City, Vietnam', 'October 15 at 9:15 PM', 'window');
insert into user_login_history values ('his_7', 'user_5', 'Window PC', 'Ho Chi Minh City, Vietnam', 'October 15 at 9:15 PM', 'window');
insert into user_login_history values ('his_7', 'user_6', 'Window PC', 'Ho Chi Minh City, Vietnam', 'October 15 at 9:15 PM', 'window');
insert into user_login_history values ('his_7', 'user_7', 'Window PC', 'Ho Chi Minh City, Vietnam', 'October 15 at 9:15 PM', 'window');
insert into user_login_history values ('his_7', 'user_8', 'Window PC', 'Ho Chi Minh City, Vietnam', 'October 15 at 9:15 PM', 'window');
insert into user_login_history values ('his_7', 'user_9', 'Window PC', 'Ho Chi Minh City, Vietnam', 'October 15 at 9:15 PM', 'window');


call getAllHistory('user_4');


