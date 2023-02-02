defmodule SqueezeWeb.StravaBulkUploadLive do
  use SqueezeWeb, :live_view

  alias Squeeze.SlugGenerator
  alias Squeeze.Strava.BulkImport
  alias SqueezeWeb.Endpoint

  @allow_strava_upload Application.compile_env(:squeeze, :allow_strava_upload)

  @impl true
  def mount(_params, _session, socket) do
    socket = if @allow_strava_upload do
      socket
      |> assign(:activity_count, 0)
      |> allow_upload(:export, max_file_size: 500_000_000, accept: ~w(.zip), progress: &handle_progress/3, auto_upload: true, max_entries: 1)

    else
      # Redirect if not allowed
      socket
      |> redirect(to: Routes.overview_path(Endpoint, :index))
    end

    {:ok, socket}
  end

  defp handle_progress(:export, entry, socket) do
    user = socket.assigns.current_user

    if entry.done? do
      consume_uploaded_entry(socket, entry, fn %{path: path} ->
        dist = copy_file_to_tmp(path)
        process_file(user, dist)
        {:ok, nil}
      end)

      {:noreply, put_flash(socket, :info, "file uploaded")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl true
  def handle_event("save", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(:activity_uploaded, socket) do
    socket = assign(socket, activity_count: socket.assigns.activity_count + 1)
    {:noreply, socket}
  end

  defp copy_file_to_tmp(path) do
    # Create working folder
    folder = Path.join(["tmp", SlugGenerator.gen_slug()])
    File.mkdir(folder)

    # Copy over to working dir
    dist = Path.join(folder, Path.basename(path))
    File.copy(path, dist)

    dist
  end

  defp process_file(user, path) do
    view = self()
    Task.start_link(fn ->
      BulkImport.import_from_file(user, path)
      |> Enum.map(fn (_) ->
        send(view, :activity_uploaded)
      end)
    end)
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
