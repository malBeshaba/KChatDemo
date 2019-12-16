package Server;

import org.omg.CORBA.PUBLIC_MEMBER;

import java.sql.*;

public class DBConnector {

    public final static String DB_DRIVER_CLASS= "com.mysql.cj.jdbc.Driver";
    public final static String DB_URL="jdbc:mysql://127.0.0.1:3306/wechat_registry";
    public final static String USERNAME="root";
    public final static String PASSWORD="";

    public static Connection getConnection(){
        Connection conn=null;
        try{
            Class.forName(DB_DRIVER_CLASS);
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        try{
            conn= DriverManager.getConnection(DB_URL,USERNAME,PASSWORD);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return conn;
    }


    /*
     *注册
     */
    public boolean signUp(String inData){
        String username=inData.split(",")[0];
        String password=inData.split(",")[1];
        boolean isSignUp=false;
        try{
            Connection connection=getConnection();
            String sql1="INSERT INTO registry VALUES(?,?)";
            String sql2="INSERT INTO friend_list VALUES(?,?)";
            PreparedStatement statement1=connection.prepareStatement(sql1);
            PreparedStatement statement2=connection.prepareStatement(sql2);
            statement1.setString(1,username);
            statement1.setString(2,password);
            statement2.setString(1,username);
            statement2.setString(2,null);
            statement1.executeUpdate();
            statement2.executeUpdate();
            isSignUp=true;
        } catch (SQLException e) {
            e.printStackTrace();
        }finally {
            return isSignUp;
        }
    }

    /*
     *登录
     */
    public boolean logIn(String inData){
        String username=inData.split(",")[0];
        System.out.println(username);
        String password=inData.split(",")[1];
        boolean isLogIn=false;
        ResultSet rs=null;
        try{
            Connection connection=getConnection();
            String sql="SELECT mypassword FROM registry WHERE username="+"'"+username+"'";

            PreparedStatement statement=connection.prepareStatement(sql);
            //statement.setString(1,username);
            rs=statement.executeQuery();
            if(rs.next()){
                if(password.equals(rs.getString("mypassword"))){
                    isLogIn=true;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }finally {
            return isLogIn;
        }
    }

    /*
     *查询好友列表
     */
    public String findFriendList(String username) throws SQLException {
        String s=null;
        ResultSet rs=null;
        try{
            Connection connection=getConnection();
            String sql="SELECT friendlist FROM friend_list WHERE username="+"'"+username+"'";
            PreparedStatement statement=connection.prepareStatement(sql);
            rs=statement.executeQuery();
            if(rs.next()){
                s=rs.getString(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return s;
    }

    /*
     *添加好友
     */
    public boolean addFriend(String user1,String user2){
        boolean isAdd=false;
        try{
            Connection connection=getConnection();
            String newFriendList1="";String newFriendList2="";
            if(findFriendList(user1)==null){
                newFriendList1+=user2;
            }
            else {
                newFriendList1+=findFriendList(user1)+","+user2;
            }

            if(findFriendList(user2)==null){
                newFriendList2+=user1;
            }
            else {
                newFriendList2+=findFriendList(user2)+","+user1;
            }
            String sql1="UPDATE friend_list SET friendlist=? WHERE username="+"'"+user1+"'";
            String sql2="UPDATE friend_list SET friendlist=? WHERE username="+"'"+user2+"'";

            PreparedStatement statement1=connection.prepareStatement(sql1);
            PreparedStatement statement2=connection.prepareStatement(sql2);

            statement1.setString(1,newFriendList1);
          //  statement1.setString(2,);
            statement2.setString(1,newFriendList2);
           // statement2.setString(2,);

            statement1.executeUpdate();
            statement2.executeUpdate();
            isAdd=true;
        } catch (SQLException e) {
            e.printStackTrace();
        }finally {
            return isAdd;
        }

    }
}
