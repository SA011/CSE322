package Server;

import java.io.*;
import java.net.Socket;
import java.nio.file.Files;
import java.util.Base64;
import java.util.Date;
import java.util.StringTokenizer;

public class Worker implements Runnable{
    private Socket client;
    private Thread t;
    private PrintWriter log, pw;
    private int chunk = 1024;

    Worker(Socket s, PrintWriter log){
        client = s;
        t = new Thread(this);
        this.log = log;
        t.start();
    }

    @Override
    public void run() {
        String input = "";
        try {
            BufferedReader br = new BufferedReader(new InputStreamReader(client.getInputStream()));
            pw = new PrintWriter(client.getOutputStream());
            input = br.readLine();
            if(input == null){
                client.close();
                return;
            }
            String path = getPath(input, "GET");
            if(path != null) {
                File file;

                try{
                    file = new File(path);
                }catch (Exception e){
                    file = null;
                }
                if(file != null && file.isDirectory()){
                    sendHTML(getDirectoryContent(path), input);

                }else if(file != null){
                    String ext = Files.probeContentType(file.toPath());
                    if(ext != null && ext.startsWith("image")){
                        //show Image
                        byte[] content = readContent(file);
                        String img = "<img src = \"data:" + ext+
                                ";base64, " + Base64.getEncoder().encodeToString(content) + "\">";
                        sendHTML(img, input);
                    }else if(path.endsWith(".txt")){
                        sendHTML("<pre>\n" + readFile(path) + "</pre>\n", input);
                    }else{
                        //download
                        downloadFile(file, input);
                    }
                }else{
                    sendError(input);
                }

            } else if ((path = getPath(input, "UPLOAD")) != null) {
                DataInputStream inp = new DataInputStream(client.getInputStream());
                pw.write("SEND\n");
                pw.flush();
                File dir = new File("uploaded");
                if(!dir.exists()){
                    dir.mkdir();
                }
                path = path.substring(1);
                int u = path.lastIndexOf('/');
                if(u != -1){
                    dir = new File("uploaded/" + path.substring(0, u));
                    if(!dir.exists())dir.mkdir();
                }
                FileOutputStream fout = new FileOutputStream("uploaded/" + path );

                byte[] data = new byte[chunk];
                int read;
                while((read = inp.read(data)) != -1){
                    fout.write(data, 0, read);
                }
                fout.close();
            } else if(input.startsWith("ERROR")){
                System.out.println("INVALID FILE UPLOADED");
            }else{
                //sendError(input);
            }

            client.close();
        } catch (Exception e) {
            try {
                sendError(input);
                client.close();
            }catch (Exception t){

            }
        }

    }

    private void downloadFile(File file, String input) throws Exception{
        OutputStream pw = client.getOutputStream();
        String ret = "HTTP/1.1 200 OK\r\n" +
                "Server.Server: Java HTTP Server.Server: 1.0\r\n" +
                "Date: " + new Date() + "\r\n" +
                "Content-Type: application/octet-stream\r\n" +
                "Accept-Ranges: bytes\r\n" +
                "Content-Length: " + file.length() + "\r\n" +
                "Content-Disposition: attachment; filename=\"" + file.getName() + "\"\r\n" +
                "\r\n";
        pw.write(ret.getBytes());
        byte[] content = readContent(file);

        log.write("HTTP REQUEST:\n" + input);
        log.write("\nHTTP RESPONSE:\n" + ret);
        log.flush();
        for(int i = 0; i < content.length; i += chunk){
            int len = Math.min(chunk, content.length - i);
            byte[] temp = new byte[len];
            for(int j = 0; j < len; j++)temp[j] = content[i + j];
            pw.write(temp);
        }
        pw.flush();


    }

    private void sendError(String input) throws Exception{
        String html = readFile("src/temp.html").replaceAll("contents", "<h1>ERROR 404 NOT FOUND</h1>");
        String ret = "HTTP/1.1 404 NOT Found\r\n" +
                "Server.Server: Java HTTP Server.Server: 1.0\r\n" +
                "Date: " + new Date() + "\r\n" +
                "Content-Type: text/html\r\n" +
                "Content-Length: " + html.length() + "\r\n" +
                "\r\n";

        log.write("HTTP REQUEST:\n" + input);
        log.write("\nHTTP RESPONSE:\n" + ret);
        log.flush();
        pw.write(ret + html);
        pw.flush();
    }

    private void sendHTML(String content, String input) throws Exception{
        String html = readFile("src/temp.html").replaceAll("contents", content);
        String ret = "HTTP/1.1 200 OK\r\n" +
                "Server.Server: Java HTTP Server.Server: 1.0\r\n" +
                "Date: " + new Date() + "\r\n" +
                "Content-Type: text/html\r\n" +
                "Content-Length: " + html.length() + "\r\n" +
                "\r\n";

        log.write("HTTP REQUEST:\n" + input);
        log.write("\nHTTP RESPONSE:\n" + ret);
        log.flush();
        pw.write(ret + html);
        pw.flush();
    }

    private String readFile(String path) throws Exception{
        BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(path)));
        StringBuilder ret = new StringBuilder();
        String line;
        while((line = br.readLine()) != null)
            ret.append(line + "\n");
        return ret.toString();
    }

    private String getDirectoryContent(String directory) {
        File file = new File(directory);
        String contents[] = file.list();
        StringBuilder elem = new StringBuilder();
        elem.append("<ul>\n");
        for (var v : contents) {
            if(new File(directory + "/" + v).isDirectory())
                elem.append("<li><b><a href = \"." + directory.substring(directory.lastIndexOf('/')) +
                        "/" + v + "\"> " + v + " </a></b></li>\n");
            else
                elem.append("<li><a href = \"." + directory.substring(directory.lastIndexOf('/')) +
                        "/" + v + "\"> " + v + " </a></li>\n");
        }
        elem.append("</ul>");
        return elem.toString();
    }

    private byte[] readContent(File file) throws IOException {
        FileInputStream fileIn = null;
        byte[] fileData = new byte[(int) file.length()];

        fileIn = new FileInputStream(file);
        fileIn.read(fileData);
        return fileData;
    }

    private String getPath(String input, String type) throws Exception{
        if(input == null)return null;
        if(input.length() > 0 && input.startsWith(type)){
            StringTokenizer token = new StringTokenizer(input);
            token.nextToken();
            return "." + token.nextToken();
        }
        return null;
    }
}
