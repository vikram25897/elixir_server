defmodule ElixirServer.Exceptions.ValidationException do
  defexception [:message]

  @impl true
  def exception({:invalid, key, value}) do
    %__MODULE__{message: "Invalid value #{value} received for #{key |> String.replace("-", "")}"}
  end

  @impl true
  def exception({:undefined, key, _}) do
    %__MODULE__{message: "Unknown option #{key |> String.replace("-", "")}"}
  end

  @impl true
  def exception(message: message) do
    %__MODULE__{message: message}
  end

  @impl true
  def message(t) do
    t.message
  end
end
