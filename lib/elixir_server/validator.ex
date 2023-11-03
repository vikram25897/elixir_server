defmodule ElixirServer.Validator do
  @moduledoc false
  alias ElixirServer.Exceptions.ValidationException

  @definition [
    host: :string,
    port: :integer,
    only_generate: :boolean
  ]

  @aliases [
    h: :host,
    p: :port,
    o: :only_generate
  ]

  @allowed_options Enum.reduce(@aliases, [], fn {k, v}, acc ->
                     acc ++ ["-#{Atom.to_string(k)}", "--#{Atom.to_string(v)}"]
                   end)

  @spec validate(list()) :: map()
  def validate(args) do
    args
    |> do_validate(%{})
    |> put_defaults()
  end

  defp do_validate(args, acc) when is_list(args) and is_map(acc) do
    args
    |> OptionParser.next(strict: @definition, aliases: @aliases)
    |> do_validate(acc)
  end

  defp do_validate({:invalid, key, value, _rest}, _acc)
       when key in @allowed_options do
    raise ValidationException, {:invalid, key, value}
  end

  defp do_validate({:undefined, key, value, _rest}, _acc) do
    raise ValidationException, {:undefined, key, value}
  end

  defp do_validate({:error, [path]}, acc) do
    if acc[:only_generate] do
      Map.put(acc, :output, path)
    else
      Map.put(acc, :entrypoint, path)
    end
  end

  defp do_validate({:error, [input, output]}, acc) do
    if acc[:only_generate] do
      acc
      |> Map.put(:entrypoint, input)
      |> Map.put(:output, output)
    else
      raise ValidationException,
        message: "When not using `only_generate`, only one path is required."
    end
  end

  defp do_validate({:error, []}, acc) do
    if acc[:only_generate] do
      raise ValidationException,
        message: "When using `only_generate`, atleast one path is required."
    else
      acc
    end
  end

  defp do_validate({:ok, key, value, rest}, acc) do
    acc = Map.put(acc, key, value)

    do_validate(rest, acc)
  end

  defp put_defaults(args) do
    host =
      case Map.get(args, :host, "loopback") do
        host when host in ["any", "loopback"] -> String.to_existing_atom(host)
        other -> raise ValidationException, {:invalid, "--host", other}
      end

    port =
      case Map.get(args, :port, 4000) do
        negative when negative < 0 -> raise ValidationException, {:invalid, "--port", negative}
        port -> port
      end

    entrypoint =
      case validate_entrypoint(Map.get(args, :entrypoint)) do
        {:ok, entrypoint} -> entrypoint
        {:error, error} -> raise ValidationException, message: error
      end

    %{
      host: host,
      port: port,
      entrypoint: entrypoint,
      only_generate: args[:only_generate] || false,
      output: args[:output]
    }
  end

  defp validate_entrypoint(nil) do
    path =
      Enum.find(["index.html", "index.exs", "index.ex"], fn path ->
        case validate_entrypoint(path) do
          {:ok, _path} -> true
          _ -> false
        end
      end) ||
        raise ValidationException, message: "No entrypoint file provided"

    {:ok, path}
  end

  defp validate_entrypoint(path) do
    if Path.extname(path) in [".html", ".ex", ".exs"] do
      if File.exists?(path) do
        {:ok, path}
      else
        {:error, "File #{path} doesn't exist"}
      end
    else
      {:error,
       "The entrypoint file must have one of the following extensions: .html, .ex, or .exs."}
    end
  end
end
