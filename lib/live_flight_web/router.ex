defmodule LiveFlightWeb.Router do
  use LiveFlightWeb, :router

  import LiveFlightWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LiveFlightWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers, %{"referrer-policy" => "no-referrer-when-downgrade"}
    plug :fetch_current_scope_for_user
  end

  pipeline :google_auth do
    plug LiveFlightWeb.PlugGoogleAuth
  end

  scope "/", LiveFlightWeb do
    pipe_through [:browser]

    get "/", PageController, :home
  end

  scope "/", LiveFlightWeb do
    pipe_through [:google_auth]
    post "/google_auth", OneTapController, :handle
  end

  scope "/", LiveFlightWeb do
    live_session :default,
      on_mount: [{LiveFlightWeb.UserAuth, :mount_current_scope}] do
      live "/map", FlightLive, :index
      # live "/users/profile", UserLive.Profile, :show
      # live "/users/profile/edit", UserLive.Profile, :edit
      # live "/users/confirm/:token", UserLive.Confirmation, :edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveFlightWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:live_flight, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LiveFlightWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", LiveFlightWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{LiveFlightWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email

      live "/posts", PostLive.Index, :index
      live "/posts/new", PostLive.Form, :new
      live "/posts/:id", PostLive.Show, :show
      live "/posts/:id/edit", PostLive.Form, :edit
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", LiveFlightWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{LiveFlightWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
      live "/users/one-tap", UserLive.OneTap
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end
end
