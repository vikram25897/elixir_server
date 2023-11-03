defmodule ElixirServer.HtmlGenerator do
  @moduledoc false
  require Logger
  @spec generate(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def generate(entrypoint) do
    case Path.extname(entrypoint) do
      ".html" -> File.read(entrypoint)
      _ -> compile_ex_file(entrypoint)
    end
  end

  defp compile_ex_file(entrypoint) do
    [{module_name, _bytecode}] = Code.compile_file(entrypoint)
    generate_html_from_ex(module_name)
  rescue
    e ->
      Logger.error(Exception.format_banner(:error, e, __STACKTRACE__))
      {:error, "Error when compiling entrypoint #{entrypoint}"}
  end

  defp generate_html_from_ex(module_name) do
    if Kernel.function_exported?(module_name, :assigns, 0) &&
         Kernel.function_exported?(module_name, :template_path, 0) do
      assigns = module_name.assigns()
      template_path = module_name.template_path()

      try do
        {:ok, EEx.eval_file(template_path, assigns: assigns)}
      rescue
        e ->
          Logger.error(Exception.format_banner(:error, e, __STACKTRACE__))
          {:error, "Error when compiling template #{template_path}"}
      end
    else
      if Kernel.function_exported?(module_name, :raw_html, 0) do
        {:ok, module_name.raw_html()}
      else
        {:error,
         "Module #{module_name} needs to export either `assigns/0` and `template_path/0` or `raw_html/0`."}
      end
    end
  end
end
