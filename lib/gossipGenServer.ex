defmodule GossipGenServer do
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
    # IO.puts("\nregistry keys: #{inspect(Registry.keys(:node_store, self()))}")
    receive do
      {_,rumorMessage} ->
        # IO.puts("\nrumorMessageinit: #{inspect(rumorMessage)}")
        rumoringProcess = Task.start fn -> spreadGossip(neighboursList,rumorMessage, nodeNo) end
        GossipGenServer.node(1,rumorMessage,rumoringProcess, nodeNo)
    end
    {:ok, nodeNo}
  end

  # Receives the gossip, keeps track of the limit and sends message when it converges.
  def node(limit, rumorMessage, rumoringProcess, nodeNo)  do
    {_, nodePid} = rumoringProcess
    if(limit < 10) do
        receive do
          {:transrumor,rumorMessage} -> node(limit+1,rumorMessage,rumoringProcess, nodeNo)
        end
      else
        send(:global.whereis_name(:mainproc),{:converged, nodeNo})
        Task.shutdown(nodePid, :brutal_kill)
    end
  end

  # Recursively spreads the gossip
  def spreadGossip(neighboursList, rumorMessage, nodeNo) do
    indexToPing = Enum.random(neighboursList)
    neighbour_id = GossipGenServer.pidRetriever(indexToPing)
    if neighbour_id != nil do
        send(neighbour_id,{:transrumor,rumorMessage})
    end
    Process.sleep(100)
    spreadGossip(neighboursList,rumorMessage, nodeNo)
  end

  def handle_call({:getMyState}, _from, appState) do
    {:reply, appState, appState}
  end

  def handle_info(_msg, state) do
    # IO.puts "unknown message"
    {:noreply, state}
  end

end
