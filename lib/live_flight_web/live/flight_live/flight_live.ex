defmodule LiveFlightWeb.FlightLive do
  use LiveFlightWeb, :live_view

  def render(assigns) do
    ~H"""
    <p id="map-hook" phx-hook="MapHook">
      <div id="map" class="h-screen" phx-update="ignore" data-maptiler-key={@maptiler_key}></div>
    </p>
    """
  end

  def mounted(_, _, socket) do
    maptiler_key = Application.get_env(:live_flight, :maptiler_key)
    {:ok, assign(socket, maptiler_key: maptiler_key)}
  end
end
