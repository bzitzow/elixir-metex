defmodule Metex.Worker do
    def temperature_of(location) do
        result = url_for(location) |> HTTPoison.get |> parse_response
        case result do
            {:ok, temp} ->
                "#{location}: #{temp}°C"
            :error ->
                "#{location} not found"
        end
    end

    def loop do
        receive do
            {sender_pid, location} ->
                send(sender_pid, {:ok, temperature_of(location)})
            _ ->
                IO.puts "don't know how to process this message"
        end
        loop
    end

    defp url_for(location) do
        location = URI.encode(location)
        "http://api.openweathermap.org/data/2.5/weather?q=#{location}&appid=#{apikey}"
    end

    defp parse_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
        body |> JSON.decode! |> compute_temperature
    end

    defp parse_response(_) do
        :error
    end

    defp compute_temperature(json) do
        try do
            temp = (json["main"]["temp"] - 273.15) |> Float.round(1)
            {:ok, temp}
        rescue
            _ -> :error
        end
    end
    # {"coord":{"lon":-104.98,"lat":39.74},"weather":[{"id":800,"main":"Clear","description":"clear sky","icon":"01d"}],"base":"stations","main":{"temp":267.67,"pressure":1014,"humidity":38,"temp_min":263.15,"temp_max":272.15},"visibility":16093,"wind":{"speed":6.7,"deg":260,"gust":9.8},"clouds":{"all":1},"dt":1519569360,"sys":{"type":1,"id":602,"message":0.0044,"country":"US","sunrise":1519565870,"sunset":1519606103},"id":5419384,"name":"Denver","cod":200}

    defp apikey do
        "69fafe8524e92acb5f081c48881cd853"
    end
end