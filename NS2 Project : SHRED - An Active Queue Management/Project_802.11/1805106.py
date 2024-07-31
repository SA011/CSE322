import matplotlib.pyplot as plt
import sys

graph_file              = open("data.txt", "r")

paramx                  = ["Number of Nodes","Number of Flows","Number of Packet per second", "Speed"]
paramy                  = ["Network Throughtput (kilobits/sec)","End to End Delay (sec)","Packet Delivery Ratio","Packet Drop Ratio","Energy Consumption"]
Xaxis                   = [[20,40,60,80,100], [10, 20, 30, 40, 50], [100, 200, 300, 400, 500], [5, 10, 15, 20, 25]]


T = 5
PREV = 1
if len(sys.argv) > 2 : 
    PREV = int(sys.argv[2])
# Yaxis = [[0.0]*T]*T*(PREV + 1)
Yaxis = [[0.0 for i in range(T)] for j in range(T*(PREV + 1))]

linecount = 0
cnt = [0]*(PREV + 1)
temp = [0.0] * T * (PREV + 1)
N = 1
t = 0
# figs = []
if len(sys.argv) > 1 : 
    N = int(sys.argv[1])

N = N * (PREV + 1)
count = 0
for lines in graph_file:
    linecount += 1
    param_list = lines.split()
    if param_list[0] != '0':
        x = linecount % 2
        x &= PREV
        cnt[x] += 1
        # print(param_list);
        for j in range(0, T):
            temp[j + (x * T)] += float(param_list[j])
    # print("TEMP: ", temp)
    if linecount % N == 0:
        for j in range(0, PREV + 1):
            if cnt[j] == 0:
                cnt[j] = 1

        for j in range(0, T * (PREV + 1)):
            Yaxis[j][count] = temp[j] / cnt[j // T]
            # print(temp[j], j, Yaxis[j][count])
            # print(Yaxis)
        cnt = [0] * (PREV + 1)
        temp = [0.0] * T * (PREV + 1)
        count += 1
        # print(Yaxis)
        
        if count == 5:
            for j in range(0, T):
                if PREV == 1:
                    f, ax = plt.subplots(1, 2)
                    ax[0].plot(Xaxis[t],Yaxis[j],marker = "o",color = "b")
                    ax[1].plot(Xaxis[t],Yaxis[j + T],marker = "o",color = "g")
                    ax[0].set_title("Modified")
                    ax[1].set_title("Previous")
                    f.text(0.5, 0.04, paramx[t], ha='center', va='center')
                    f.text(0.06, 0.5, paramy[j], ha='center', va='center', rotation='vertical')
                else:
                    plt.figure(t * T + j + 1)
                    plt.xlabel(paramx[t])
                    plt.ylabel(paramy[j])
                    plt.plot(Xaxis[t],Yaxis[j],marker = "o",color = "b")
                plt.savefig(f"result_{t*T+j+1}.png")


            t += 1
            count = 0
            Yaxis = [[0.0 for i in range(T)] for j in range(T*(PREV + 1))]
            
    if t == 4:
        break


graph_file.close()

# plt.show()


