defmodule Rumbl.User do
  use Ecto.Schema
  require Logger
  import Ecto.Changeset
  import Phoenix.Controller

  # defstruct [:id, :name, :username, :password]

  schema "users" do
    field :name , :string
    field :username , :string
    field :password , :string , virtual: true
    field :password_hash , :string
    has_many(:videos, Rumbl.Db.Video)

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    cs = user
      |> cast(params, [:name, :username])
      |> validate_required([:username])
      |> validate_length(:username, min: 1, max: 20)
      |> unique_constraint(:username)
    # |> validate_length(:username, min: 1, max: 20)
    cs |> inspect() |> Logger.debug()
    cs

  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%Rumbl.User{}, user_params)
    case Repo.insert(changeset) do
      {:ok ,user} ->
        conn
        |> Rumbl.Auth.login(user)
        |> put_flash(:info, "#{ user.name } created!" )
        |> redirect(to: Routes.user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def registration_changeset(model, params) do
    model
      |> changeset(params)
      |> cast(params, [:password])
      |> validate_required(:password)
      |> validate_length(:password, min: 6, max: 100)
      |> put_pass_hash()
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{ valid?: true, changes: %{ password: pass}} ->
        put_change(changeset, :password_hash , Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
  # def changeset(model, params \\ %{}) do
  #   model |> inspect() |> Logger.debug()
  #   model
  #   # |> cast(params, ~w(name username), [])
  #   # |> validate_length(:username, min: 1, max: 20)
  # end
end
