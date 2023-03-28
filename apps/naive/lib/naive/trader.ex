defmodule Naive.Trader do
  @moduledoc false
  use GenServer

  require Logger

  defmodule State do
    @moduledoc """
    - :symbol - what symbol does it need to trade ("symbol" here is a pair of assets
      for example "XRPUSDT", which is XRP to/from USDT)
    - :buy_order - placed buy order (if any)
    - :sell_order - placed sell order (if any)
    - :profit_interval - what net profit % we would like to achieve when buying/selling
      an asset - single trade cycle
    - :tick_size - smallest acceptable price movement up or down, i.e. in real world
      tick size for USD is a single cent, you can't sell something for $1.234, it's
      either $1.23 or $1.24, single cent difference is the tick size
      (investopedia article on tick)[https://www.investopedia.com/terms/t/tick.asp]
    """
    @enforce [:symbol, :profit_interval, :tick_size]
    defstruct [
      :symbol,
      :buy_order,
      :sell_order,
      :profit_interval,
      :tick_size
    ]
  end

  def start_link(%{} = args) do
    GenServer.start_link(__MODULE__, args, name: :trader)
  end

  def init(%{symbol: symbol, profit_interval: profit_interval}) do
    symbol = String.upcase(symbol)
    Logger.info("Initialising new trader for #{symbol}")
    tick_size = fetch_tick_size(symbol)

    {:ok,
     %State{
       symbol: symbol,
       profit_interval: profit_interval,
       tick_size: tick_size
     }}
  end

  @doc """
  - `get_exchange_info/0` to fetch the list of all the symbols, and filter out
     only those that we are requested to trade.
  - Tick size is defined as a `PRICE_FILTER`
  - (Binance elixir dependency docs)[https://github.com/binance/binance-spot-api-docs/blob/master/rest-api.md#exchange-information]
  - following is how the important parts of the result looks like:
    {:ok, %{
      symbols: [
        %{
            "symbols": "ETHUSDT",
            ...
            "filters": [
              ...
              %{"filterType: "PRICE_FILTER", "tickSize": tickSize, ...}
            ],
            ...
        }
      ]
    }}
  """
  defp fetch_tick_size(symbol) do
    Binance.get_exchange_info()
    |> elem(1)
    |> Map.get(:symbols)
    |> Enum.find(&(&1["symbol"] == symbol))
    |> Map.get("filters")
    |> Enum.find(&(&1["filterType"] == "PRICE_FILTER"))
    |> Map.get("tickSize")
  end
end
