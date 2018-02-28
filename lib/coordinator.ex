defmodule Metex.Coordinator do
    def loop(results \\ [], limit) do
        receive do
            {:ok, result} ->
                new_results = [result | results]
                if limit == Enum.count(new_results) do
                    send(self(), :exit)
                end
                loop(new_results, limit)
            :exit ->
                IO.puts(results |> Enum.sort |> Enum.join(", "))
            _ ->
                loop(results, limit)
        end
    end
end