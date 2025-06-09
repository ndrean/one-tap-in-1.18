defmodule LiveFlight.Accounts.Notifier do
  @moduledoc false
  use GenServer
  import Ecto.Query
  alias LiveFlight.Accounts.{User, UserToken}
  require Logger

  def init(_) do
    EctoWatch.subscribe({User, :inserted})
    EctoWatch.subscribe({UserToken, :inserted})
    {:ok, nil}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_info({{User, :inserted}, %{id: _user_id}}, state) do
    {:noreply, state}
  end

  def handle_info({{UserToken, :inserted}, %{id: token_id}}, state) do
    email =
      from(ut in UserToken,
        join: u in assoc(ut, :user),
        where: ut.id == ^token_id,
        select: u.email
      )
      |> LiveFlight.Repo.one()

    Logger.info("User token inserted with ID #{token_id}, email: #{inspect(email)}")

    Phoenix.PubSub.broadcast(
      LiveFlight.PubSub,
      "user:",
      %{email: email}
    )

    {:noreply, state}
  end
end
