defmodule Rumbl.Db.Video do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Rumbl.Permalink, autogenerate: true}

  schema "videos" do
    field :description, :string
    field :title, :string
    field :url, :string
    field :slug, :string
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
    |> cast(attrs, [:url, :title, :description, :category_id])
    |> slugify_title()
    |> validate_required([:url, :title, :description])
    |> assoc_constraint(:category)
  end

  defp slugify_title(changeset) do
    if title = get_change(changeset, :title) do
      put_change(changeset, :slug, slugify(title))
    else
      changeset
    end
  end

  defp slugify(str) do
    str
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/u, "-")
  end
end

defimpl Phoenix.Param, for: Rumbl.Db.Video do
  def to_param(%{slug: slug, id: id}) do
    "#{id}-#{slug}"
  end
end
