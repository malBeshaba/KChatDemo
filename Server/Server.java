package Server;


import java.io.IOException;
import java.net.InetSocketAddress;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Vector;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class Server {

//    public static void main(String []args){
//
//        try{
//            ExecutorService executorService= Executors.newFixedThreadPool(5);
//            Vector<MessageThread> vectors=new Vector<MessageThread>();
//            Map<String, MessageThread> threadMap = new HashMap<String, MessageThread>();
//            ServerSocket serverSocket=new ServerSocket(80);
//            System.out.println("Server已建立，正在监听...");
//            while(true){
//                Socket socket=serverSocket.accept();
////                MessageThread messageThread=new MessageThread(socket,vectors);
////                executorService.execute(messageThread);
//            }
//        } catch (IOException e) {
//            e.printStackTrace();
//        }
//    }

    private static Socket client;
    private static boolean start = true;
    private ArrayList clients = new ArrayList<MessageThread>();
    Map<String, MessageThread> threadMap = new HashMap<>();
    private int clientID = 0;
    static ServerSocket textserver;

    static {
        try {
            textserver = new ServerSocket(10000);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    static ServerSocket sendSocket;

    static {
        try {
            sendSocket = new ServerSocket(8888);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    DBConnector connector = new DBConnector();
    Server server = this;

    public void listen() {
        try{
            ServerSocket serverSocket=new ServerSocket(80);

            System.out.println("Server已建立，正在监听...");

            while(true){
                 client=serverSocket.accept();
                 Runnable runnable = () -> new MessageThread(client, server);
                 new Thread(runnable).start();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

}
