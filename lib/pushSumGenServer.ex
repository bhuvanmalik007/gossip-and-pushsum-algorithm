defmodule PushSumGenServer do
  use GenServer

  def start_link(nodeNo, neighboursList) do
    GenServer.start_link(__MODULE__, [nodeNo, neighboursList], name: {:via, Registry, {:node_store, nodeNo}})
  end

  # Getting PID of a node by passing it's index
  def pidRetriever(nodeNo) do
    case Registry.lookup(:node_store, nodeNo) do
    [{pid, _}] -> pid
    [] -> nil
    end
  end

  # Receives the first gossip for any node and kick starts the spreading and receiving processes of that node
  def init([nodeNo, neighboursList]) do
    receive do
      {_, s, w} ->
        rumoringProcess = Task.start fn -> spreadGossip(neighboursList,s + nodeNo, w + 1, nodeNo) end
        PushSumGenServer.node(1, s + nodeNo, w + 1, rumoringProcess, nodeNo, nodeNo)
    end
    {:ok, nodeNo}
  end

  # Receives the gossip, keeps track of the limit and sends message when it converges.
  def node(limit,s,w, rumoringProcess, oldRatio, nodeNo)  do
    {_, nodePid} = rumoringProcess
    newRatio = s/w
    delta = abs(newRatio - oldRatio)
    limit = if delta > :math.pow(10,-10), do: 0, else: limit + 1
    if(limit >= 3) do
      Process.exit(nodePid, :kill)
      send(:global.whereis_name(:mainproc),{:converged, nodeNo})
      Process.exit(self(),:kill)
    else
      s=s/2
      w=w/2
      send(nodePid,{:updatedGossip,s,w})
      receive do
          {:transrumor,receivedS,receivedW} -> node(limit,receivedS+s,receivedW+w, rumoringProcess, newRatio, nodeNo)
      after
          100 -> node(limit,s,w,rumoringProcess, newRatio, nodeNo)
      end
    end
  end

  # Recursively spreads the gossip
  def spreadGossip(neighboursList, s, w, nodeNo) do
    try do
      {s,w} = receive do
                  {:updatedGossip, newS, newW} -> {newS, newW}
              end
              indexToPing = Enum.random(neighboursList)
              neighbour_id = PushSumGenServer.pidRetriever(indexToPing)
          if neighbour_id != nil do
              send(neighbour_id,{:transrumor,s,w})
          end
          spreadGossip(neighboursList, s, w, nodeNo)
    rescue
      _ ->
        spreadGossip(neighboursList, s, w, nodeNo)
    end
  end

end
