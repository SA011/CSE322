import matplotlib.pyplot as plt
import sys

graph_file              = open("data2.txt", "r")

paramx                  = "Average Packet Size Per Flow"
paramy                  = "Threshold"

X = 0
Y1 = []
Y2 = []
Y3 = []
for lines in graph_file:
#   if(len(Y3) == 100):
#      break
  if(lines[0] == ':'):
    x = lines.split()
    if(x[0][1:] == "PACKET:"):
        X = x[1]
    elif(x[0][1:] == "TH_MIN_MOD:"):
        Y1.append([float(X), float(x[1])])
    elif(x[0][1:] == "TH_MIN:"):
        Y2.append([float(X), float(x[1])])
    elif(x[0][1:] == "TH_MAX:"):
        # print(X, x[1])
        Y3.append([float(X), float(x[1])])
        # print(Y3[len(Y3) - 1])
 
# print(Y3)   
Y1.sort()
Y2.sort()
Y3.sort()
# print(Y3)

plt.xlabel(paramx)
plt.ylabel(paramy)
x = []
y = []
for a, b in Y1:
   x.append(a)
   y.append(b)
plt.plot(x,y,color = "b", label = "TH_MIN_MOD")
x = []
y = []
for a, b in Y2:
   x.append(a)
   y.append(b)
plt.plot(x,y,color = "g", label = "TH_MIN")
x = []
y = []
for a, b in Y3:
   x.append(a)
   y.append(b)
plt.plot(x,y,color = "r", label = "TH_MAX")
graph_file.close()
#plt.ylim([0, 30])
plt.legend()
# plt.show()
plt.savefig(f"Threshold.png")


