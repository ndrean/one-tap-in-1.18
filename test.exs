Mix.install([:ecto_sql, :postgrex])
Application.put_env(:myapp, Repo, datavase: "example_db")

defmodule Repo do
  use Ecto.Repo,
    otp_app: :myapp,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end
end

defmodule User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> unique_constraint(:email)
  end
end

defmodule Migration do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string
      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:users, [:email])
  end
end

defmodule Main do
  import Ecto.Query, warn: false

  def main do
    Repo.__adapter__().storage_down(Repo.config())
    :ok = Repo.__adapter__().storage_up(Repo.config())
    {:ok, _} = Supervisor.start_link([Repo], strategy: :one_for_one)
    Ecto.Migrator.run(Repo, [{0, Migration}], :up, all: true, log_migrations_sql: :info)
    IO.puts("Database and migration setup complete.")

    Repo.insert!(%User{name: "Alice", email: "alice@test.com"})
    Repo.all(User) |> dbg()
  end
end

Main.main()
