defmodule Squeeze.FitDecoder do
  use GenServer

  @moduledoc """
  Garmin uses FIT files for all of their data. According to their website:

  The Flexible and Interoperable Data Transfer (FIT) protocol is designed specifically for the storing and sharing of data that originates from sport, fitness and health devices.

  Unfortunately, FIT isn't text based like TCX, GPX, or CSV so we need to use their SDK to decode a fit file into json.
  They have not provided a elixir or erlang sdk so this code runs python using erlport and poolboy based on the example found [here](https://medium.com/stuart-engineering/how-we-use-python-within-elixir-486eb4d266f9)

  This module is only available in *development* to help make strava bulk import easier for the developer experience.

  You will need to install `python3` and the garmin-fit-sdk by running:

  ```
  pip install garmin-fit-sdk
  ```

  For more information about the FIT and the SDK, please check out Garmin's documentation: https://developer.garmin.com/fit/overview/

  ### Examples

  ```elixir
  iex> Squeeze.FitDecoder.call("9043730012.fit")
  {:ok, '{"file_id_mesgs": [{"serial_number": 0000, "time_created": "2023-01-21T20:11:58+00:00", "manufacturer": "garmin", "product": 2833}...'}

  ```
  """

  require Logger

  @timeout 10_000

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  def message(pid, file_path) do
    GenServer.call(pid, {:decode, file_path})
  end

  def call(file_path) do
    Task.async(fn ->
      :poolboy.transaction(
        :fit_decoder_worker,
        fn pid ->
          GenServer.call(pid, {:decode, file_path})
        end,
        @timeout
      )
    end)
    |> Task.await(@timeout)
  end

  #############
  # Callbacks #
  #############

  @impl true
  def init(_) do
    path = [:code.priv_dir(:squeeze), "python"] |> Path.join()

    with {:ok, pid} <- :python.start([{:python_path, to_charlist(path)}, {:python, 'python3'}]) do
      Logger.info("[#{__MODULE__}] Started python worker")
      {:ok, pid}
    end
  end

  @impl true
  def handle_call({:decode, file_path}, _from, pid) do
    result = :python.call(pid, :fit_to_json, :decode, [file_path])
    Logger.info("[#{__MODULE__}] Handled call")
    {:reply, {:ok, result}, pid}
  end
end
