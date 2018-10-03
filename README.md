# Gossip Simulator

## How to run:

Navigate to the “ **project2** ” folder in the command line.

Build the executable using “ **mix escript.build** ”

Run it using “ **escript Project2 numNodes topology algorithm** ”

numNodes: Number of nodes to be spawned in the given topology.
Topology: Can be one of "full", "3D", "rand2D", "torus", "line", "imp2D"
Algorithm: is one of "gossip", "push-sum".

Make sure to enter the arguments in the mentioned order.



## What is working?

All the topologies have been successfully implemented using both Gossip and Push
Sum protocol. The upper limit for the number of nodes that can be handled by the
system is only due to the system limits on the number of processes.

Full convergence is being achieved for all the topologies. For the bonus part, failure
model has been implemented with a percentage parameter, which corresponds to the
percentage of the nodes(actors) that we kill randomly.


Graphs have been plotted and many interesting observations have been made. Some
of which are as follows:

- When implementing using Gossip protocol, Line topology takes the highest time to
    converge, while the Full topology takes the least time.
- When implementing using Push Sum protocol, Torus topology takes the highest time
    to achieve convergence while Line topology takes the least time.

## Largest network run for each topology and algorithm:

Note : In order to run large networks we have increased the wait time from 5000ms to
30000ms so that the actors can be spawned and the corresponding neighbor lists can
be generated.

Torus using Gossip : **100,000**
Torus using Push Sum : **100,000**

Line using Gossip : **100,000**
Line using Push Sum : **100,000**

Imperfect Line using Gossip : **10,000**
Imperfect Line using Push Sum : **10,000**

Full using Gossip : **8,000**
Full using Push Sum : **10,000**

Random 2D using Gossip : **2,000**
Random 2D using Push Sum : **2,000**

3D using Gossip : **50,000**
3D using Push Sum : **100,000**


