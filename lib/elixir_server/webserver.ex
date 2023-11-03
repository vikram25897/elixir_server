defmodule ElixirServer.Webserver do
  @moduledoc false
  use GenServer
  require Logger

  alias ElixirServer.HtmlGenerator

  def start(args) do
    GenServer.start(__MODULE__, Map.put(args, :parent, self()), name: __MODULE__)
  end

  def init(%{port: port, host: host, entrypoint: entrypoint} = data) do
    with {:ok, raw_html} <- HtmlGenerator.generate(entrypoint),
         {:ok, _} <- start_listening(port, host) do
      {:ok, Map.put(data, :raw_html, raw_html)}
    else
      {:error, error} -> {:stop, error}
    end
  end

  defp start_listening(port, host) do
    Bandit.start_link(plug: ElixirServer.BanditPlug, port: port, ip: host)
  end

  def handle_call(:raw_html, _from, state) do
    case HtmlGenerator.generate(state.entrypoint) do
      {:ok, raw_html} ->
        {:reply, raw_html, %{state | raw_html: raw_html}}

      {:error, error} ->
        Logger.error(error)
        {:reply, state.raw_html, state}
    end
  end

  def terminate(reason, state) do
    send(state.parent, {:server_terminated, reason})
  end
end
