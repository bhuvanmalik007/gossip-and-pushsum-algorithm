defmodule GossipGenServer do
  use GenServer

  def start_link(nodeNo, neighboursList) do
    GenServer.start_link(__MODULE__, [nodeNo, neighboursList], name: {:via, Registry, {:node_store, nodeNo}})
  end

  def pidRetriever(nodeNo) do
    case Registry.lookup(:node_store, nodeNo) do
    [{pid, _}] -> pid
    [] -> nil
    end
  end

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

  def node(limit,rumorMessage,rumoringProcess, nodeNo)  do
    # IO.puts("\nrumorMessageinsidenode: #{inspect(rumorMessage)}")
    {_, nodePid} = rumoringProcess
    if(limit < 10) do
        receive do
          {:transrumor,rumorMessage} -> node(limit+1,rumorMessage,rumoringProcess, nodeNo)
        end
      else
        # IO.puts("\nthis got killed: #{inspect(Task.shutdown(nodePid, :brutal_kill))}")
        send(:global.whereis_name(:mainproc),{:converged, nodeNo})
        Task.shutdown(nodePid, :brutal_kill)
        # Process.exit(nodePid, :kill)
        IO.puts("*******************************#{inspect(nodeNo)}th process killed successfully*******************************")
        # IO.puts("\nthis got killed: #{inspect(Task.shutdown(rumoringProcess, :brutal_kill))}")
        # IO.puts("\nTask: #{inspect(Task.shutdown)}")
    end
  end

  def spreadGossip(neighboursList, rumorMessage, nodeNo) do
    # IO.puts("No #{inspect(nodeNo)} gossip girl at work")
    indexToPing = Enum.random(neighboursList)
    # IO.puts("\nindexToPing: #{inspect(indexToPing)}")
    neighbour_id = GossipGenServer.pidRetriever(indexToPing)
    # IO.puts("\nneighbour_id: #{inspect(neighbour_id)}")
    if neighbour_id != nil do
        send(neighbour_id,{:transrumor,rumorMessage})
    end
    Process.sleep(100)
    spreadGossip(neighboursList,rumorMessage, nodeNo)
  end

  # Server Callbacks

   # def getState(processId) do
    #   GenServer.call(processId, {:getMyState})
    # end

  def handle_call({:getMyState}, _from, appState) do
    {:reply, appState, appState}
  end


  def handle_info(_msg, state) do
    # IO.puts "unknown message"
    {:noreply, state}
  end

  def hello do
    IO.puts("Hello World")
  end

  # end of genny

end
