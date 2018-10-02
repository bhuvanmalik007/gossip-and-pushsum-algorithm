defmodule GossipTopologies do

  def line(numNodes) do
    for i <- 1..numNodes do
      neighboursList =
        cond do
          i == 1 -> [i + 1]
          i == numNodes -> [i - 1]
          true -> [i - 1, i + 1]
        end
        # IO.puts "neighboursList: #{inspect(neighboursList)}"
        spawn(fn -> GossipGenServer.start_link(i, neighboursList) end)
    end
    HelperFunctions.convergeTopology(numNodes, "gossip")
  end

  def full(numNodes) do
    for i <- 1..numNodes do
      range = 1..numNodes
      neighboursList = Enum.to_list(range)
       neighboursList = List.delete(neighboursList,i)
        spawn(fn -> GossipGenServer.start_link(i, neighboursList) end)
    end
    HelperFunctions.convergeTopology(numNodes, "gossip")
  end

  def impLine(numNodes) do
    for i <- 1..numNodes do
      randomList = Enum.to_list 1..numNodes
      neighboursList =  cond do
                              i == 1 -> [i+1] ++ [Enum.random(Enum.filter(randomList, fn x -> x != i and x != (i+1) end))]
                              i == numNodes -> [i-1] ++ [Enum.random(Enum.filter(randomList, fn x -> x != i and x != (i-1) end))]
                              true -> [i-1,i+1] ++ [Enum.random(Enum.filter(randomList, fn x -> x != i and x != (i-1) and x != (i+1) end))]
      end
      # IO.puts("\nneighbours of #{inspect(i)} are #{inspect(neighboursList)}")
      spawn(fn -> GossipGenServer.start_link(i, neighboursList) end)
    end
      HelperFunctions.convergeTopology(numNodes, "gossip")
  end

  def torus(numNodes) do
    rc = round(:math.sqrt(numNodes))
    for i <- 1..numNodes do
      neighboursList =  cond do
                          i == 1 -> [i+1,i+rc,i+rc-1,i+(rc*rc)-rc]
                          i == rc -> [i-1,i+rc,i+(rc*rc)-rc,i+1-rc]
                          i == (rc*rc) - rc + 1 -> [i+1,i-rc,i+rc-1,i+rc-(rc*rc)]
                          i == (rc*rc) -> [i-1,i-rc,i+rc-(rc*rc),i+1-rc]
                          i < rc -> [i-1,i+1,i+rc,i+(rc*rc)-rc]
                          i > (rc*rc) - rc + 1 and i < (rc*rc) -> [i-1,i+1,i-rc,i+rc-(rc*rc)]
                          rem(i-1,rc) == 0 -> [i+1,i-rc,i+rc,i+rc-1]
                          rem(i,rc) == 0 -> [i-1,i-rc,i+rc,i+1-rc]
                          true -> [i-1,i+1,i-rc,i+rc]
                      end
        spawn(fn -> GossipGenServer.start_link(i, neighboursList) end)
    end
    HelperFunctions.convergeTopology(numNodes, "gossip")
  end

  def random2D(numNodes) do
    coordinatesStore =
    Enum.reduce(1..numNodes, [], fn nodeNo, acc ->
      xC = Enum.random(1..numNodes)/numNodes
      yC = Enum.random(1..numNodes)/numNodes
      acc ++ Keyword.put_new([], :"#{inspect(nodeNo)}", %{x: xC, y: yC})
      end)

    for i <- 1..numNodes do
      parentCoordinatesMap = Keyword.get(coordinatesStore, :"#{inspect(i)}")
      parentX = Map.get(parentCoordinatesMap, :x)
      parentY = Map.get(parentCoordinatesMap, :y)

      neighboursList =
        Enum.reduce(1..numNodes, [], fn i, acc ->
          coordinatesMap = Keyword.get(coordinatesStore, :"#{inspect(i)}")
          x = Map.get(coordinatesMap, :x)
          y = Map.get(coordinatesMap, :y)
          distance = :math.sqrt(((parentX - x)*(parentX - x)) + ((parentY - y)*(parentY - y)))
          acc ++ (((distance >= 0 && distance <= 0.1) && [i]) || [])
          end)
      spawn(fn -> GossipGenServer.start_link(i, neighboursList) end)
    end
    HelperFunctions.convergeTopology(numNodes, "gossip")
  end


  def threeD(numNodes) do
    rc = round(HelperFunctions.nthRoot(3, numNodes, 1))
    for i <- 1..numNodes do
        neighboursList =  cond do
                        #First layer
                            i == 1 -> [i+1,i+rc,i+(rc*rc)]
                            i == rc -> [i-1,i+rc,i+(rc*rc)]
                            i == (rc*rc) - rc + 1 -> [i+1,i-rc,i+(rc*rc)]
                            i == (rc*rc) -> [i-1,i-rc,i+(rc*rc)]
                            i < rc -> [i-1,i+1,i+rc,i+(rc*rc)]
                            i > (rc*rc) - rc + 1 and i < (rc*rc) -> [i-1,i+1,i-rc,i+(rc*rc)]
                            rem(i-1,rc) == 0 -> [i+1,i-rc,i+rc,i+(rc*rc)]
                            rem(i,rc) == 0 -> [i-1,i-rc,i+rc,i+(rc*rc)]
                            i > 1 and i < (rc*rc) -> [i-1,i+1,i-rc,i+rc,i+(rc*rc)]
                        #Last Layer
                            i == (rc*rc*rc) - (rc*rc) + 1 -> [i+1,i+rc,i-(rc*rc)]
                            i == (rc*rc*rc) - (rc*rc) + rc -> [i-1,i+rc,i-(rc*rc)]
                            i == (rc*rc*rc) - (rc*rc) + (rc*rc) - rc + 1 -> [i+1,i-rc,i-(rc*rc)]
                            i == (rc*rc*rc) - (rc*rc) +( rc*rc) -> [i-1,i-rc,i-(rc*rc)]
                            i < (rc*rc*rc) - (rc*rc) + rc -> [i-1,i+1,i+rc,i-(rc*rc)]
                            i > (rc*rc*rc) - rc + 1 and i < (rc*rc*rc) -> [i-1,i+1,i-rc,i-(rc*rc)]
                            rem(i - 1 - ((rc*rc*rc) - (rc*rc)),rc) == 0 -> [i+1,i-rc,i+rc,i-(rc*rc)]
                            rem(i - (rc*rc*rc) - (rc*rc),rc) == 0 -> [i-1,i-rc,i+rc,i-(rc*rc)]
                            # rem(i - (rc*rc*rc - rc*rc,rc)) == 0 -> [i-1,i-rc,i+rc,i-rc*rc]
                            i > (rc*rc*rc) - (rc*rc) + 1 and i < (rc*rc*rc) -> [i-1,i+1,i-rc,i+rc,i+(rc*rc)]
                        #In-between Layers
                            rem(i-1,(rc*rc)) == 0 -> [i+1,i+rc,i-(rc*rc),i+(rc*rc)]
                            rem(i,(rc*rc)) == 0 -> [i-1,i-rc,i-(rc*rc),i+(rc*rc)]
                            rem(i-1-rc,(rc*rc)) == 0 -> [i-1,i+rc,i-(rc*rc),i+(rc*rc)]
                            rem(i+rc,(rc*rc)) == 0 -> [i+1,i-rc,i-(rc*rc),i+(rc*rc)]
                            rem(i,(rc*rc)) < rc -> [i-1,i+1,i+rc,i-(rc*rc),i+(rc*rc)]
                            rem(i,(rc*rc)) > (rc*rc)-rc and rem(i,(rc*rc)) < (rc*rc) -> [i-1,i+1,i-rc,i-(rc*rc),i+(rc*rc)]
                            rem(rem(i-1,(rc*rc)),rc) == 0 -> [i+1,i-rc,i+rc,i-(rc*rc),i+(rc*rc)]
                            rem(rem(i,(rc*rc)),rc) == 0-> [i-1,i-rc,i+rc,i-(rc*rc),i+(rc*rc)]

                            true -> [i-1,i+1,i-rc,i+rc,i-(rc*rc),i+(rc*rc)]
                        end
        spawn(fn -> GossipGenServer.start_link(i, neighboursList) end)
        end
    HelperFunctions.convergeTopology(numNodes, "gossip")
  end

end
