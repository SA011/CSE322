package Client;

import java.util.Scanner;

public class Client {
    public static void main(String[] args) {
        while (true){
            System.out.println("Input File Name: ");
            String file;
            file = new Scanner(System.in).nextLine();
            new ClientThread(file);
            System.out.println("Do you want to continue sending?(Y/N)");
            file = new Scanner(System.in).next();
            if(!file.startsWith("Y"))break;
        }
    }


}
