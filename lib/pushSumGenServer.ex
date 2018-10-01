defmodule PushSumGenServer do
  use GenServer

  def start_link(nodeNo, neighboursList) do
    GenServer.start_link(__MODULE__, [nodeNo, neighboursList], name: {:via, Registry, {:node_store, nodeNo}})
  end

  def pidRetriever(nodeNo) do
    # IO.puts "trying"
    case Registry.lookup(:node_store, nodeNo) do
    [{pid, _}] -> pid
    [] -> nil
    end
  end

  def init([nodeNo, neighboursList]) do
    # IO.puts("\nnodeNo: #{inspect(nodeNo)}   neighboursList:  #{inspect(neighboursList)}")
    receive do
      {_, s, w} ->
        # IO.puts("\nrumorMessageinit: #{inspect(rumorMessage)}")
        rumoringProcess = Task.start fn -> spreadGossip(neighboursList,s + nodeNo, w + 1, nodeNo) end
        PushSumGenServer.node(1, s + nodeNo, w + 1, rumoringProcess, nodeNo, nodeNo)
    end
    {:ok, nodeNo}
  end

  def node(limit,s,w, rumoringProcess, oldRatio, nodeNo)  do
        # IO.puts("\ns: #{inspect(s)}   w:  #{inspect(w)}")
    {_, nodePid} = rumoringProcess
    newRatio = s/w
    delta = abs(newRatio - oldRatio)
    limit = if delta > :math.pow(10,-10), do: 0, else: limit + 1
    # IO.puts("\nnodeNo: #{inspect(nodeNo)}   limit:  #{inspect(limit)}")
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

  def spreadGossip(neighboursList, s, w, nodeNo) do
    # IO.puts("\nnodeNo: #{inspect(nodeNo)}   neighboursList:  #{inspect(neighboursList)}")
    try do
      {s,w} = receive do
                  {:updatedGossip, newS, newW} -> {newS, newW}
              end
              indexToPing = Enum.random(neighboursList)
            #  IO.puts("\nnodeNo: #{inspect(nodeNo)}   indexToPing:  #{inspect(indexToPing)}")
              neighbour_id = PushSumGenServer.pidRetriever(indexToPing)
          if neighbour_id != nil do
              send(neighbour_id,{:transrumor,s,w})
            #  IO.puts("\nnodeNo: #{inspect(nodeNo)} sent message")
          end
          # IO.puts("\nnodeNo: #{inspect(nodeNo)}   about to recurse")
          spreadGossip(neighboursList, s, w, nodeNo)
    rescue
      _ ->
        # IO.puts("\nnodeNo: #{inspect(nodeNo)}  rescued here")
        spreadGossip(neighboursList, s, w, nodeNo)
  end
end

end
