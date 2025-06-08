defmodule LiveFlightWeb.OneTapController do
  use LiveFlightWeb, :controller
  alias LiveFlightWeb.UserAuth
  alias LiveFlight.Accounts

  def handle(conn, %{"credential" => jwt} = _params) do
    case ExGoogleCerts.verified_identity(%{jwt: jwt})  do
      {:ok, profile} ->
        user =
          case Accounts.get_user_by_email(profile["email"]) do
            nil ->
              {:ok, user} =
                Accounts.register_user(%{
                  email: profile["email"],
                  confirmed_at: if(profile["email_verified"], do: DateTime.utc_now(), else: nil)
                })

              user

            user ->
              user
          end

        conn
        |> fetch_session()
        |> fetch_flash()
        |> put_flash(:info, "Google identity verified successfully.")
        |> UserAuth.log_in_user(user)

      {:error, reason} ->
        conn
        |> fetch_session()
        |> fetch_flash()
        |> put_flash(:error, "Google identity verification failed: #{reason}")
        |> redirect(to: ~p"/")
    end
  end

  def handle(conn, %{}) do
    conn
    |> fetch_session()
    |> fetch_flash()
    |> put_flash(:error, "Protocol error, please contact the maintainer")
    |> redirect(to: ~p"/")
  end
end
