package Client;

import java.io.*;
import java.net.Socket;
import java.nio.file.Files;
import java.util.Date;

public class ClientThread implements Runnable{
    private String filename;
    private Thread t;
    private int chunk = 1024;
    public ClientThread(String file) {
        this.filename = file;
        t = new Thread(this);
        t.start();
    }

    @Override
    public void run() {
        try {
            Socket socket = new Socket("localhost", 5106);
            PrintWriter pw = new PrintWriter(socket.getOutputStream());
            OutputStream pr = socket.getOutputStream();
            BufferedReader br = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            File file;
            try{
                file = new File(filename);
                String ext = Files.probeContentType(file.toPath());
                if(!ext.startsWith("image") && !filename.endsWith(".txt") && !filename.endsWith(".mp4")){
                    throw new Exception();
                }
                byte[] content = readContent(file);
                pw.write("UPLOAD " + filename + "\n");
                pw.flush();
                String ok = br.readLine();
                if(ok.equals("SEND")){
                    for(int i = 0; i < content.length; i += chunk){
                        int len = Math.min(chunk, content.length - i);
                        byte[] temp = new byte[len];
                        for(int j = 0; j < len; j++)temp[j] = content[i + j];
                        pr.write(temp);
                    }
                    pr.flush();
                }else{
                    System.out.println("CONNECTION FAILED");
                    return;
                }

            }catch (Exception e){
                System.out.println("INVALID FILE");
                pw.write("ERROR\n");
                pw.flush();
            }
        } catch (Exception e) {

        }

    }


    private byte[] readContent(File file) throws IOException {
        FileInputStream fileIn = null;
        byte[] fileData = new byte[(int) file.length()];

        fileIn = new FileInputStream(file);
        fileIn.read(fileData);
        return fileData;
    }
}
