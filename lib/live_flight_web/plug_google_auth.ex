defmodule LiveFlightWeb.PlugGoogleAuth do
  @moduledoc """
  Plug to check the CSRF state concordance when receiving data from Google.

  Denies to treat the HTTP request if fails.
  """
  import Plug.Conn
  use LiveFlightWeb, :verified_routes
  use LiveFlightWeb, :controller

  def init(opts), do: opts

  def call(conn, _opts) do
    g_csrf_from_cookies =
      fetch_cookies(conn)
      |> Map.get(:cookies, %{})
      |> Map.get("g_csrf_token")

    g_csrf_from_params =
      Map.get(conn.params, "g_csrf_token")

    case {g_csrf_from_cookies, g_csrf_from_params} do
      {nil, _} ->
        halt_process(conn, "CSRF cookie missing")

      {_, nil} ->
        halt_process(conn, "CSRF token missing")

      {cookie, param} when cookie != param ->
        halt_process(conn, "CSRF token mismatch")

      _ ->
        conn
    end
  end

  defp halt_process(conn, msg) do
    conn
    |> fetch_session()
    |> fetch_flash()
    |> put_flash(:error, msg)
    |> redirect(to: ~p"/")
    |> halt()
  end
end
