defmodule LiveFlightWeb.PageController do
  use LiveFlightWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
