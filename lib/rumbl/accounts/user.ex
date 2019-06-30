defmodule Rumbl.User do
  use Ecto.Schema
  require Logger
  import Ecto.Changeset
  # defstruct [:id, :name, :username, :password]
  schema "users" do
    field :name , :string
    field :username , :string
    field :password , :string , virtual: true
    field :password_hash , :string

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    cs = user
      |> cast(params, [:name, :username])
      |> validate_required([:username])
      |> validate_length(:username, min: 1, max: 20)
    # |> validate_length(:username, min: 1, max: 20)
    cs |> inspect() |> Logger.debug()
    cs

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
