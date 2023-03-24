defmodule Streamer.Binance do
  @moduledoc """
  - Stream live cryptocurrency prices (trade events) from the Binance exchange
  - `Streamer` uses `Websockex` a Websocket client to connect and receive live feed from Binance API
  - Receive the event as a JSON string, and decode with `jason` and convert it into data struct

  - Base endpoint is "wss://stream.binance.com:9443/ws/"
  - Raw streams are accessed at /ws/<streamName>
  - All symbols for streams are lowercase
  - (Binance Api Github)[https://github.com/binance/binance-spot-api-docs/blob/master/web-socket-streams.md]
  """

  use WebSockex

  @stream_endpoint "wss://stream.binance.com:9443/ws/"



  @doc """
  - Compatible stream name consist of lowercase symbols and format as follows
  **Stream Name:** `<symbol>@trade`
  - Generic url format for any symbol:
  "wss://stream.binance.com:9443/ws/`<symbol>`@trade"

  - Working url for `XRPUSDT` symbol:
  "wss://stream.binance.com:9443/ws/`<symbol>`@trade"

  ## Examples

      iex> Streamer.Binance.start_link("xrpusdt")
      {:ok, #PID<0.372.0>}
      Received Message - Type: :text -- Message: "{\"e\":\"trade\",\"E\":1679627000939,
      \"s\":\"XRPUSDT\",\"t\":511353200,\"p\":\"0.43390000\",\"q\":\"2822.00000000\",
      \"b\":5074911827,\"a\":5074911247,\"T\":1679627000938,\"m\":false,\"M\":true}"
  """
  def start_link(symbol) do
    symbol |> url_for |> WebSockex.start_link(__MODULE__, nil)
  end


  @doc"""
  - Every incoming message from Binance will cause the `handle_frame/2` callback to be called
    with the message and process state
  """
  def handle_frame({type, msg}, state) do
    IO.puts "Received Message - Type: #{inspect type} -- Message: #{inspect msg}"
    {:ok, state}
  end

  defp url_for(symbol) do
    symbol = String.downcase(symbol)
    "#{@stream_endpoint}#{symbol}@trade"
  end
end