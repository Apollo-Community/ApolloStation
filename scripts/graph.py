import pandas as pd
import matplotlib.pyplot as plt
import sys

data = pd.read_csv("data/graphs/csv/"+sys.argv[1]+".csv",index_col=0)
ax = data.plot(subplots=True,figsize=(12,6))
ax2 = data.TICK.plot(style='r')
ax2.set_ylim(0,4)
plt.savefig("data/graphs/"+sys.argv[1]+".png")
