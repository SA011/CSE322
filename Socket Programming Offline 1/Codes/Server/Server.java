package Server;

import java.io.*;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {
    public static void main(String[] args) throws IOException {
        ServerSocket serverSocket = new ServerSocket(5106);
        FileOutputStream fout = new FileOutputStream("log.txt");
        PrintWriter pr = new PrintWriter(fout);
        while(true){
            Socket client = serverSocket.accept();
            new Worker(client, pr);

        }
    }
}