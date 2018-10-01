defmodule GossipAlgorithm do
  def main(args) do
    args |> parse_args |> carryOn
  end

  defp parse_args(args) do
    {_,parameters,_} = OptionParser.parse(args)
    parameters
  end

  def carryOn([]) do
    IO.puts "No arguments given"
  end

  def carryOn(parameters) do
    numNodes = String.to_integer(Enum.at(parameters,0))
    topology = Enum.at(parameters,1)
    algorithm = Enum.at(parameters,2)
    Registry.start_link(keys: :unique, name: :node_store)
    case topology do
      "full" -> if algorithm == "gossip", do: GossipSimulator.Implementation.gossip_full(numNodes,trigger_node_count,nodes_to_ping,stopping_threshold), else: GossipSimulator.Implementation.pushsum_full(numNodes,trigger_node_count,nodes_to_ping,stopping_threshold)
      "2d" -> if algorithm == "gossip", do: GossipSimulator.Implementation.gossip_2d(numNodes,trigger_node_count,nodes_to_ping,stopping_threshold), else: GossipSimulator.Implementation.pushsum_2d(numNodes,trigger_node_count,nodes_to_ping,stopping_threshold)
      "line" -> if algorithm == "gossip", do: GossipSimulator.Implementation.gossip_line(numNodes,trigger_node_count,nodes_to_ping,stopping_threshold), else: GossipSimulator.Implementation.pushsum_line(numNodes,trigger_node_count,nodes_to_ping,stopping_threshold)
      "imp2d" -> if algorithm == "gossip", do: GossipSimulator.Implementation.gossip_imp2d(numNodes,trigger_node_count,nodes_to_ping,stopping_threshold), else: GossipSimulator.Implementation.pushsum_imp2d(numNodes,trigger_node_count,nodes_to_ping,stopping_threshold)
      _ -> IO.puts "Default"
    end
  end
end
