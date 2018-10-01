defmodule HelperFunctions do
  def nthRoot(n, x, precision \\ 1.0e-5) do
    f = fn(prev) -> ((n - 1) * prev + x / :math.pow(prev, (n-1))) / n end
    fixed_point(f, x, precision, f.(x))
  end

  defp fixed_point(_, guess, tolerance, next) when abs(guess - next) < tolerance, do: next
  defp fixed_point(f, _, tolerance, next), do: fixed_point(f, next, tolerance, f.(next))

  def converging(numNodes) do
    IO.puts "#{inspect(numNodes)} nodes remaining"
    if(numNodes > 0) do
      receive do
          {:converged,nodeNo} ->
            IO.puts "Node number #{inspect(nodeNo)} Converged"
            converging(numNodes-1)
      after
              5000 -> IO.puts "Convergence could not be reached for #{numNodes} nodes"
                      # converging(numNodes-1)
      end
    else
      nil
    end
  end

  def convergeTopology(numNodes, algorithm) do
    asyncTask = Task.async(fn -> HelperFunctions.converging(numNodes) end)
    :global.register_name(:mainproc,asyncTask.pid)
    startTime = System.system_time(:millisecond)
    randomStartingNodePid = GossipGenServer.pidRetriever(Enum.random(1..numNodes))
    algorithm == "gossip" && send(randomStartingNodePid,{:mainproc,"It's alive, it's alive, Carter V"}) || send(randomStartingNodePid,{:mainproc, 0, 0})
    Task.await(asyncTask, :infinity)
    timeDifference = System.system_time(:millisecond) - startTime
    IO.puts "Time taken for convergence: #{timeDifference} milliseconds"
  end

end
