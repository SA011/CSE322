import matplotlib.pyplot as plt
import sys

graph_file              = open("data.txt", "r")

paramx                  = ["Area Size","Number of Nodes","Number of Flows"]
paramy                  = ["Network Throughtput (kilobits/sec)","End to End Delay (sec)","Packet Delivery Ratio","Packet Drop Ratio"]
Xaxis                   = [[250,500,750,1000,1250], [20,40,60,80,100], [10, 20, 30, 40, 50]]

Net_throughput          = []
e_to_e_delay            = []
pkt_del_ratio           = []
pkt_drop_ratio          = []
linecount = 0
cnt = 0
temp = [0.0,0.0,0.0,0.0]
N = 1
t = 0
figs = []
if len(sys.argv) > 1 : 
    N = int(sys.argv[1])
for lines in graph_file:
    linecount += 1
    param_list = lines.split()
    # print(lines)
    # print(param_list)
    if param_list[0] != '0':
        # print(param_list[0])
        cnt += 1
        temp[0] += float(param_list[0])
        temp[1] += float(param_list[1])
        temp[2] += float(param_list[2])
        temp[3] += float(param_list[3])

    if linecount % N == 0:
        if cnt == 0:
            cnt = 1
        Net_throughput.append(float(temp[0])/cnt)
        e_to_e_delay.append(float(temp[1])/cnt)
        pkt_del_ratio.append(float(temp[2])/cnt)
        pkt_drop_ratio.append(float(temp[3])/cnt)
        cnt = 0
        temp = [0.0, 0.0, 0.0, 0.0]
        if len(Net_throughput) == 5:
            figs.append(plt.figure(t * 4 + 1))
            plt.xlabel(paramx[t])
            plt.ylabel(paramy[0])
            plt.plot(Xaxis[t],Net_throughput,marker = "o",color = "b")
            plt.savefig(f"result_{t*4+1}.png")
            # plt.show()
            
            figs.append(plt.figure(t * 4 + 2))
            plt.xlabel(paramx[t])
            plt.ylabel(paramy[1])
            plt.plot(Xaxis[t],e_to_e_delay,marker = "o",color = "b")
            plt.savefig(f"result_{t*4+2}.png")
            # plt.show()


            figs.append(plt.figure(t * 4 + 3))
            plt.xlabel(paramx[t])
            plt.ylabel(paramy[2])
            plt.plot(Xaxis[t],pkt_del_ratio,marker = "o",color = "b")
            plt.savefig(f"result_{t*4+3}.png")
            # plt.show()

            figs.append(plt.figure(t * 4 + 4))
            plt.xlabel(paramx[t])
            plt.ylabel(paramy[3])
            plt.plot(Xaxis[t],pkt_drop_ratio,marker = "o",color = "b")
            plt.savefig(f"result_{t*4+4}.png")
            # plt.show()
            t += 1
            Net_throughput          = []
            e_to_e_delay            = []
            pkt_del_ratio           = []
            pkt_drop_ratio          = []



graph_file.close()

# plt.show()


