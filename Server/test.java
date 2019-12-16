package Server;

public class test {
    public static void main(String[]a){
        DBConnector dbConnector=new DBConnector();
        String s="a,a";
        String x=s.split(",")[0];
        String y=s.split(",")[1];
        System.out.println(x);
        System.out.println(y);
        dbConnector.signUp("a,a");
        dbConnector.logIn("a,a");
        dbConnector.signUp("c,c");
        dbConnector.signUp("b,b");
        dbConnector.addFriend("a","b");
        dbConnector.addFriend("a","c");
    }
}
