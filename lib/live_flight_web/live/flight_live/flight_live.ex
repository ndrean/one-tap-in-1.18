defmodule LiveFlightWeb.FlightLive do
  use LiveFlightWeb, :live_view

  def render(assigns) do
    ~H"""
    <p id="map-hook" phx-hook="MapHook">
      <div id="map" class="h-screen" phx-update="ignore"></div>
    </p>
    """
  end

  def mounted(_, _, socket) do
    {:ok, socket}
  end
end
