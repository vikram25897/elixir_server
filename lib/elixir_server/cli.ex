defmodule ElixirServer.CLI do
  @moduledoc false
  require Logger
  alias ElixirServer.HtmlGenerator
  alias ElixirServer.Validator
  alias ElixirServer.Validator.ValidationException
  alias ElixirServer.Webserver

  @doc """
  Starts the server with the given arguments and handles validation exceptions.
  """
  def main(args) do
    # Validate arguments and start the webserver
    args
    |> Validator.validate()
    |> case do
      %{only_generate: false} = args ->
        handle_webserver_response(Webserver.start(args))

      %{only_generate: true, output: output, entrypoint: entrypoint} ->
        generate_html(entrypoint, output)
    end
  rescue
    exception in ValidationException ->
      exception
      |> handle_validation_exception(__STACKTRACE__)
  end

  @spec generate_html(String.t(), String.t()) :: :ok
  def generate_html(entrypoint, output_path) do
    case HtmlGenerator.generate(entrypoint) do
      {:ok, raw_html} ->
        File.write!(output_path, raw_html)
        Logger.info("Output written to #{output_path}")

      {:error, error} ->
        Logger.error(error)
    end
  end

  defp handle_webserver_response({:ok, _} = _response) do
    receive do
      {:server_terminated, message} ->
        IO.puts("Server terminated due to: #{message}")
    end
  end

  defp handle_webserver_response({:error, error}) do
    Logger.error(error)
  end

  defp handle_validation_exception(exception, stracktrace) do
    message = Exception.message(exception)
    Exception.format_banner(:error, message, stracktrace)
  end
end
