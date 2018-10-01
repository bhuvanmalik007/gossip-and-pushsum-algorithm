defmodule GossipAlgorithm.CLI do
  def main(args) do
    args |> parse_args |> carryOn
  end

  defp parse_args(args) do
    {_,parameters,_} = OptionParser.parse(args, switches: [help: :boolean])
    parameters
  end

  def carryOn([]) do
    IO.puts "No arguments given"
  end

  def carryOn(parameters) do
    numNodes = String.to_integer(Enum.at(parameters,0))
    topology = Enum.at(parameters,1)
    algorithm = Enum.at(parameters,2)
    IO.puts("#{numNodes}")
    Registry.start_link(keys: :unique, name: :node_store)
    case topology do
      "line" -> if algorithm == "gossip", do: Topologies.line(numNodes), else: Topologies.pushSumLine(numNodes)
      "full" -> if algorithm == "gossip", do: Topologies.full(numNodes), else: Topologies.pushSumFull(numNodes)
      "impline" -> if algorithm == "gossip", do: Topologies.impLine(numNodes), else: Topologies.pushSumImpLine(numNodes)
      "torus" -> if algorithm == "gossip", do: Topologies.torus(numNodes), else: Topologies.pushSumTorus(numNodes)
      "rand2D" -> if algorithm == "gossip", do: Topologies.random2D(numNodes), else: Topologies.pushSumRandom2D(numNodes)
      "3D" -> if algorithm == "gossip", do: Topologies.threeD(numNodes), else: Topologies.pushSumThreeD(numNodes)
      _ -> IO.puts "No matches found for the given arguments."
    end
  end
end
