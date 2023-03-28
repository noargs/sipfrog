defmodule Streamer do
  @moduledoc """
  Documentation for `Streamer`.
  """


  @doc """
  iex> Streamer.start_streaming("xrpusdt")
  {:ok, #PID<0.57.0>}

  07:55:04.048 [debug] Trade event received XRPUSDT@0.48750000

  07:55:04.049 [debug] Trade event received XRPUSDT@0.48750000

  07:55:04.049 [debug] Trade event received XRPUSDT@0.48740000

  07:55:04.049 [debug] Trade event received XRPUSDT@0.48740000
  """
  def start_streaming(symbol) do
    Streamer.Binance.start_link(symbol)
  end


end
