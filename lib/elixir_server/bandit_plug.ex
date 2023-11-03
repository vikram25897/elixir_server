defmodule ElixirServer.BanditPlug do
  @moduledoc false
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    raw_html = GenServer.call(ElixirServer.Webserver, :raw_html)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, raw_html)
  end
end
