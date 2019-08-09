defmodule Rumbl.Db.Video do
  use Ecto.Schema
  import Ecto.Changeset

  schema "videos" do
    field :description, :string
    field :title, :string
    field :url, :string
    # field :user_id, :id
    belongs_to(:user, Rumbl.User)
    belongs_to(:category, Rumbl.Db.Category)
    timestamps()
  end

  # @required_fields ~w(url, title, description)
  # @optional_fields ~w(category_id)

  @doc false
  def changeset(video, attrs \\ %{}) do
    video
    |> cast(attrs, [:url, :title, :description])
    |> validate_required([:url, :title, :description])
  end
end
