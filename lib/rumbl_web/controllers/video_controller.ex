defmodule RumblWeb.VideoController do
  use RumblWeb, :controller
  import Ecto
  alias Rumbl.Db
  alias Rumbl.Repo
  alias Rumbl.Db.Video
  alias Rumbl.Db.Category

  plug :load_categories when action in [:new, :create, :edit, :update]

  def action(conn, _) do
    # __MODULE__ mean the current module
    apply(__MODULE__, action_name(conn),
      [conn, conn.params, conn.assigns.current_user])
  end

  def index(conn, _params, user) do
    # videos = Db.list_videos()
    videos = Repo.all(user_videos(user))
    render(conn, "index.html", videos: videos)
  end

  def new(conn, _params, user) do
    # changeset = Db.change_video(%Video{})
    # render(conn, "new.html", changeset: changeset)
    changeset =
      user
      |> build_assoc(:videos)
      |> Video.changeset()

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"video" => video_params}, user) do
    changeset =
      user
      |> build_assoc(:videos)
      |> Video.changeset(video_params)

    case Db.create_video(changeset) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video created successfully.")
        |> redirect(to: Routes.video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp load_categories(conn, _) do
    query =
      Category
      |> Category.alphabetical
      |> Category.names_and_ids
    categories = Repo.all query
    assign(conn, :categories, categories)
  end

  def show(conn, %{"id" => id}, user) do
    # video = Db.get_video!(id)
    video = Repo.get!(user_videos(user), id)
    render(conn, "show.html", video: video)
  end

  def edit(conn, %{"id" => id}, user) do
    # video = Db.get_video!(id)
    video = Repo.get!(user_videos(user), id)
    changeset = Db.change_video(video)
    render(conn, "edit.html", video: video, changeset: changeset)
  end

  def update(conn, %{"id" => id, "video" => video_params}, user) do
    # video = Db.get_video!(id)
    video = Repo.get!(user_videos(user), id)
    case Db.update_video(video, video_params) do
      {:ok, video} ->
        conn
        |> put_flash(:info, "Video updated successfully.")
        |> redirect(to: Routes.video_path(conn, :show, video))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", video: video, changeset: changeset)
    end
  end

  defp user_videos(user) do
    assoc(user, :videos)
  end

  def delete(conn, %{"id" => id}, user) do
    # video = Db.get_video!(id)
    video = Repo.get!(user_videos(user), id)
    {:ok, _video} = Db.delete_video(video)

    conn
    |> put_flash(:info, "Video deleted successfully.")
    |> redirect(to: Routes.video_path(conn, :index))
  end
end
