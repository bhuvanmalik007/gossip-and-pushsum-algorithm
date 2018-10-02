defmodule GossipAlgorithm.CLI do
  def main(args) do
    args |> parse_args |> handler
  end

  defp parse_args(args) do
    {_,parameters,_} = OptionParser.parse(args, switches: [help: :boolean])
    parameters
  end

  def handler([]) do
    IO.puts "No arguments given"
  end

  def handler(parameters) do
    numNodes = String.to_integer(Enum.at(parameters,0))
    topology = Enum.at(parameters,1)
    algorithm = Enum.at(parameters,2)
    IO.puts("#{numNodes}")
    Registry.start_link(keys: :unique, name: :node_store)
    case topology do
      "line" -> (algorithm == "gossip" && GossipTopologies.line(numNodes)) || PushSumTopologies.pushSumLine(numNodes)
      "full" -> (algorithm == "gossip" && GossipTopologies.full(numNodes)) || PushSumTopologies.pushSumFull(numNodes)
      "impline" -> (algorithm == "gossip" && GossipTopologies.impLine(numNodes)) ||  PushSumTopologies.pushSumImpLine(numNodes)
      "torus" -> (algorithm == "gossip" && GossipTopologies.torus(numNodes)) || PushSumTopologies.pushSumTorus(numNodes)
      "rand2D" -> (algorithm == "gossip" && GossipTopologies.random2D(numNodes)) || PushSumTopologies.pushSumRandom2D(numNodes)
      "3D" -> (algorithm == "gossip" && GossipTopologies.threeD(numNodes)) || PushSumTopologies.pushSumThreeD(numNodes)
      _ -> IO.puts "No matches found for the given arguments."
    end
  end
end
