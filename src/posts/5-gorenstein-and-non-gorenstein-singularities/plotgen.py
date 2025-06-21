import numpy as np;
import matplotlib.pyplot as plt;

color_o1 = "#f43753"
X = np.arange(-5,5)
Y = np.arange(-5,5)

def gen_nodal_cubic():
    fig = plt.figure()
    ax = fig.gca(projection="3d")
    ax.contour(X, Y, Y**2 - X**3, levels=[0], colors=[color_o1])
    fig.savefig("nodal_cubic.svg")

gen_nodal_cubic()