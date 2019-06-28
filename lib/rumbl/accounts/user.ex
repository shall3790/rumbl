defmodule Rumbl.User do
  use Ecto.Schema
  import Ecto.Changeset
  # defstruct [:id, :name, :username, :password]
  schema "users" do
    field :name , :string
    field :username , :string
    field :password , :string , virtual: true
    field :password_hash , :string

    timestamps()
    end
end
