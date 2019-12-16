package Server;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Vector;



public class  MessageThread extends Socket{
    public final static String TYPE_SIGNOUT="000";
    public final static String TYPE_SIGNUP="001";
    public final static String TYPE_LOGIN="002";
    public final static String TYPE_TEXT="003";
    public final static String TYPE_PIC="004";
    public final static String TYPE_FILE="005";
    public final static String TYPE_FRIENDASK="006";
    public final static String TYPE_FRIENDLIST="007";

    public String serverHelper=null;

    public boolean flag;
    public boolean isSignIn=false;
    public boolean isLogIn=false;
    //private String name;
    private String userName;
    private Socket client;
    private Vector<MessageThread> vectors;
    private HashMap<String, MessageThread> threadHashMap;
    private OutputStream objos;
    private ServerSocket fileserver;
    Server server;
    ServerSocket serverSocket;
//    ServerSocket textserver;
    static String content;

    public DBConnector dbConnector = new DBConnector();


    public MessageThread(Socket socket, Server server){
        this.client = socket;
        this.server = server;
        this.doSocket();
    }



    private boolean signUp(String inData){
        return dbConnector.signUp(inData);
    }

    public boolean logIn(String inData){
        String username=inData.split(",")[0];
        userName=username;
        server.threadMap.put(username, this);
        return  dbConnector.logIn(inData);
    }

    void receiveText() {
        try {
            Socket data = Server.textserver.accept();
            System.out.println("receive connect");
            InputStream inputStream = data.getInputStream();
            byte[] buffer = new byte[1024];
            inputStream.read(buffer);
            String content = withNotNil(new String(buffer));
            this.content = content;
//            DataOutputStream text = new DataOutputStream(data.getOutputStream());
//            text.write(content.getBytes());
//            text.close();
            System.out.println("content"+this.content);
            inputStream.close();
            data.close();
            this.objos.write("003:receive".getBytes());
        }catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void sendText(String name) {
        try{
            Socket socket = Server.sendSocket.accept();
            OutputStream outputStream = socket.getOutputStream();
            System.out.println("sendserver connect");
            String text = "msg:" + name + ":" + this.content;
            System.out.println("text:"+text);
            if (this.content != null) {
                System.out.println(this);
                outputStream.write(text.getBytes());
                System.out.println("send success");
            }
            socket.close();
            outputStream.close();
        }catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void InText(String from_to,DataInputStream is) throws IOException {
        try{
            String from=from_to.split(",")[0].split(":")[1];
            String to=from_to.split(",")[1].split(":")[1];
            MessageThread temp;
            int size=vectors.size();
            for(int i=0;i<size;++i){
                temp=vectors.get(i);
                if(to.equals(temp.userName)&&temp!=this){
                    byte[] data = new byte[1024];
                    is.read(data);
                    String inData= withNotNil(new String(data));

                    objos.write(inData.getBytes());

                    String serverHelperCome=null;
                    serverHelperCome=TYPE_TEXT+",coming";
                    temp.objos.write(serverHelperCome.getBytes());

                    String printMessage=from+" : ";
                    temp.objos.write(printMessage.getBytes());

                    String printCode=TYPE_TEXT+" ";
                    temp.objos.write(printCode.getBytes());
                    temp.objos.write(inData.getBytes());
                    break;
                }
            }
        }catch (IOException e){
            e.printStackTrace();
        }
    }

    public void InPic(String from_to,InputStream is) throws IOException{
        try{
            String from=from_to.split(",")[0].split(":")[1];
            String to=from_to.split(",")[1].split(":")[1];
            MessageThread temp;
            int size=vectors.size();
            for(int i=0;i<size;++i){
                temp=vectors.get(i);
                if(to.equals(temp.userName)&&temp!=this){
                    String serverHelperCome=null;
                    serverHelperCome=TYPE_PIC+",coming";
                    temp.objos.write(serverHelperCome.getBytes());
                    String printMessage=from+" : ";
                    temp.objos.write(printMessage.getBytes());
                    String printCode=TYPE_PIC+" ";
                    temp.objos.write(printCode.getBytes());
                    OutputStream os=temp.client.getOutputStream();
                    byte[]buff=new byte[1024];
                    int length=0;
                    while((length=is.read(buff))!=-1){
                        os.write(buff,0,length);
                    }
                    os.flush();
                    os.close();
                    break;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public void InFile(String from_to,InputStream is){
        try{
            String from=from_to.split(",")[0].split(":")[1];
            String to=from_to.split(",")[1].split(":")[1];
            MessageThread temp;
            int size=vectors.size();
            for(int i=0;i<size;++i){
                temp=vectors.get(i);
                if(to.equals(temp.userName)&&temp!=this){
                    String serverHelperCome=null;
                    serverHelperCome=TYPE_FILE+",coming";
                    temp.objos.write(serverHelperCome.getBytes());
                    String printMessage=from+":";
                    temp.objos.write(printMessage.getBytes());
                    String printCode=TYPE_FILE+" ";
                    temp.objos.write(printCode.getBytes());
                    OutputStream os=temp.client.getOutputStream();
                    byte[]buff=new byte[1024];
                    int length=0;
                    while((length=is.read(buff))!=-1){
                        os.write(buff,0,length);
                    }
                    os.flush();
                    os.close();
                    break;
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public boolean FriendAdd(String from_to){
        String from=from_to.split(",")[0];
        String to=from_to.split(",")[1];
        return dbConnector.addFriend(from,to);
    }

    public String FriendList(String from) throws SQLException {
        return dbConnector.findFriendList(from);
    }

    public String withNotNil(String str) {
        StringBuffer buf = new StringBuffer(str);
        for (int i = 0; i < buf.length(); i ++) {
            while (buf.charAt(i) == '\u0000') {
                buf.deleteCharAt(i);
                if (i == buf.length()) {
                    break;
                }
            }
        }
        return buf.toString();
    }


    public void doSocket() {
        try{
            DataInputStream dis=new DataInputStream(client.getInputStream());
            objos= client.getOutputStream();
            flag=true;
            serverHelper="已连接...";
            System.out.println(serverHelper);
            while(flag){
                byte[] bytes = new byte[3];
                dis.read(bytes);
                String inCode = new String(bytes);
                System.out.println("inCode:"+inCode);
                switch (inCode){
                    case TYPE_SIGNUP:{
                        serverHelper=TYPE_SIGNUP+":isready";
                        System.out.println(serverHelper);
                        objos.write(serverHelper.getBytes());
                        byte[] data = new byte[1024];
                        dis.read(data);
                        String inData= withNotNil(new String(data));
                        System.out.println(inData);
                        isSignIn=signUp(inData);

                        if(!isSignIn) {
                            serverHelper=TYPE_SIGNUP+" fail...";
                            objos.write(serverHelper.getBytes());
                        }
                        else{
                            serverHelper=TYPE_SIGNUP+" succeed...";
                            isLogIn = true;
                            objos.write(serverHelper.getBytes());
                        }
                        break;
                    }
                    case TYPE_LOGIN:{
                        serverHelper=TYPE_LOGIN+":isready";
                        objos.write(serverHelper.getBytes());
                        byte[] data = new byte[1024];
                        dis.read(data);
                        String inData= withNotNil(new String(data));
                        isLogIn=logIn(inData);
                        if(!isLogIn) {
                            serverHelper=TYPE_LOGIN+" fail...";
                            System.out.println(inData+TYPE_LOGIN+" fail...");
                            objos.write(serverHelper.getBytes());
                        }
                        else{
                            serverHelper=TYPE_LOGIN+" succeed...";
                            System.out.println(inData+TYPE_LOGIN+" succeed...");
                            objos.write(serverHelper.getBytes());
                        }
                        break;
                    }
                    case TYPE_TEXT:{
                        String userName, friendName, content;
                        serverHelper=TYPE_TEXT+":isready";
                        objos.write(serverHelper.getBytes());
                        byte[] data1=new byte[1024];
                        dis.read(data1);
                        String inFrom_To= withNotNil(new String(data1));
                        System.out.println(inFrom_To);
                        userName = inFrom_To.split(",")[0].split(":")[1];
                        friendName = inFrom_To.split(",")[1].split(":")[1];
                        MessageThread friendThread = server.threadMap.get(friendName);

                        if (friendThread == null) {
                            objos.write("003:friendoffline".getBytes());
                            System.out.println("friend offline");
                        }else{
                            System.out.println("textserver connect");
                            friendThread.objos = friendThread.client.getOutputStream();
                            friendThread.objos.write("003:send".getBytes());
                            Thread receiveTextThread = new Thread(new Runnable() {
                                @Override
                                public void run() {
                                    System.out.println("friendThread start");
                                    while (true) {
                                        receiveText();
                                    }
                                }
                            });
                            receiveTextThread.start();

                            friendThread.objos.write("003:receive".getBytes());
                            Thread sendTextThread = new Thread(new Runnable() {
                                @Override
                                public void run() {
                                    System.out.println("sendsocket is ready");
                                    while (true) {
                                        sendText(friendName);
                                    }
                                }
                            });
                            sendTextThread.start();
                        }


                        break;
                    }
                    case TYPE_PIC:{
                        if(!isSignIn||!isLogIn) {
                            break;
                        }
                        serverHelper=TYPE_PIC+":isready";
                        objos.write(serverHelper.getBytes());
                        byte[] data = new byte[1024];
                        dis.read(data);
                        String inFrom_To= withNotNil(new String(data));
                        InputStream is= client.getInputStream();
                        InPic(inFrom_To,is);
                        is.close();
                        break;
                    }
                    case TYPE_FILE:{
                        if(!isSignIn||!isLogIn) {
                            break;
                        }
                        String userName, friendName, content;
                        serverHelper=TYPE_FILE+":isready";
                        objos.write(serverHelper.getBytes());
                        byte[] data1=new byte[1024];
                        dis.read(data1);
                        String inFrom_To= withNotNil(new String(data1));
                        System.out.println(inFrom_To);
                        userName = inFrom_To.split(",")[0].split(":")[1];
                        friendName = inFrom_To.split(",")[1].split(":")[1];
                        MessageThread friendThread = server.threadMap.get(friendName);


                        if (friendThread == null) {
                            objos.write("005:friendoffline".getBytes());
                        }else{

                            friendThread.objos.write("005:send".getBytes());
                            Thread receiveTextThread = new Thread(new Runnable() {
                                @Override
                                public void run() {
                                    while (true) {
                                        receiveFile("file");
                                    }
                                }
                            });
                            receiveTextThread.start();

                            friendThread.objos.write("005:receive".getBytes());
                            Thread sendTextThread = new Thread(new Runnable() {
                                @Override
                                public void run() {
                                    while (true) {
                                        sendFile();
                                    }
                                }
                            });
                            sendTextThread.start();
                        }
                        break;
                    }
                    case TYPE_SIGNOUT:{
                        serverHelper=TYPE_SIGNOUT+":isready";
                        objos.write(serverHelper.getBytes());
                        serverHelper="正在退出...";
                        objos.write(serverHelper.getBytes());
                        flag=false;
                        break;
                    }
                    case TYPE_FRIENDASK:{
                        serverHelper=TYPE_FRIENDASK+":isready";
                        objos.write(serverHelper.getBytes());
                        byte[] data = new byte[1024];
                        dis.read(data);
                        String inFrom_TO= withNotNil(new String(data));
                        if(FriendAdd(inFrom_TO)){
                            serverHelper=TYPE_FRIENDASK+" succeed...";
                            System.out.println(inFrom_TO+TYPE_FRIENDASK+" succeed...");
                            objos.write(serverHelper.getBytes());
                        }
                        else {
                            serverHelper=TYPE_FRIENDASK+" fail...";
                            System.out.println(inFrom_TO+TYPE_FRIENDASK+" fail...");
                            objos.write(serverHelper.getBytes());
                        }
                        break;
                    }
                    case TYPE_FRIENDLIST:{
                        serverHelper=TYPE_FRIENDLIST+":isready";
                        System.out.println(serverHelper);
                        objos.write(serverHelper.getBytes());
                        byte[] data = new byte[1024];
                        dis.read(data);
                        String from= withNotNil(new String(data));
                        String list = "list:" + FriendList(from);
                        System.out.println(list);
                        objos.write(list.getBytes());
                        break;
                    }
                    default:{
                        serverHelper="老板，宁发的口令不对...";
                        objos.write(serverHelper.getBytes());
                        break;
                    }
                }
            }
            objos.close();
            objos.close();
        } catch (IOException | SQLException e) {
            e.printStackTrace();
        }finally {
            try {
                client.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

     void receiveFile(String fileName) {
         try{
             //开始接收
             Socket data = fileserver.accept();
             InputStream dataStream = data.getInputStream();
             String savePath = "/Users/malBeshaba/Desktop"  + "/" + fileName;
             FileOutputStream file = new FileOutputStream(savePath, false);
             byte[] buffer = new byte[1024];
             int size = -1;
             while ((size = dataStream.read(buffer)) != -1){
                 file.write(buffer, 0 ,size);
             }
             file.close();
             dataStream.close();
             data.close();
         }catch(Exception e){
             e.printStackTrace();
         }
     }

     void sendFile() {
         try {
             Socket socket = serverSocket.accept();
             OutputStream outputStream = socket.getOutputStream();
             FileInputStream fileInput = new FileInputStream("/Users/haowenyu/Desktop/gitTest"  + "/" + "file");
             //绝对路径，写死了，需要改则改此处以及上面的receivefile方法中的路径
             byte[] buffer = new byte[1024];
             int size = -1;
             while ((size = fileInput.read(buffer))!=-1){
                 outputStream.write(buffer,0,size);
             }
             //传输完毕，关闭资源
             socket.shutdownOutput();
             fileInput.close();
             outputStream.close();
         }catch (IOException e){
             e.printStackTrace();
         }
     }
}
