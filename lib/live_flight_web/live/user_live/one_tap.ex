defmodule LiveFlightWeb.UserLive.OneTap do
  use LiveFlightWeb, :live_view

  def render(assigns) do
    ~H"""
    <div id="one-tap-login" phx-update="ignore">
      <script src="https://accounts.google.com/gsi/client" async>
      </script>

      <div
        id="g_id_onload"
        data-client_id={@g_client_id}
        data-login_uri={@g_cb_uri}
        data-auto_prompt="true"
      >
      </div>
      <div
        class="g_id_signin"
        data-type="standard"
        data-text="signin_with"
        data-shape="rectangular"
        data-theme="outline"
        data-size="large"
        data-logo_alignment="center"
        data-width="200"
      >
      </div>
    </div>
    """
  end

  def mount(_params, %{"_csrf_token" => _csrf_token} = _session, socket) do
    callback_uri =
      Path.join(
        LiveFlightWeb.Endpoint.url(),
        Application.fetch_env!(:live_flight, :google_callback_uri)
      )

    google_client_id =
      Application.fetch_env!(:live_flight, :google_client_id)

    socket =
      assign(socket,
        g_cb_uri: callback_uri,
        g_client_id: google_client_id
      )

    {:ok, socket}
  end
end
