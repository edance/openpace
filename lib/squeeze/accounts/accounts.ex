defmodule Squeeze.Accounts do
  @moduledoc """
  The Accounts context which is responsible for users, preferences, and credentials.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.{Credential, User, UserPrefs}
  alias Squeeze.Repo
  alias Squeeze.Utils

  @doc """
  Something something

  ## Examples

  ```elixir
  iex> get_user_by_slug(slug)
  %User{}
  ```
  """
  def get_user_by_slug!(slug) do
    query = from u in User,
      where: u.slug == ^slug,
      preload: [:credentials, :user_prefs]

    Repo.one!(query)
  end

  def get_user_by_credential(%{provider: provider, uid: uid}) do
    query = from u in User,
      left_join: c in assoc(u, :credentials),
      where: c.provider == ^provider and c.uid == ^uid
    query
    |> Repo.one()
    |> Repo.preload([:credentials, :user_prefs])
  end
  def get_user_by_credential(_), do: nil

  @doc """
  Get user by email address.

  ## Examples

      iex> get_user_by_email(email)
      %User{}

      iex> get_user_by_email(bad_email)
      nil

  """
  def get_user_by_email(email) when is_nil(email), do: nil
  def get_user_by_email(email) do
    User
    |> Repo.get_by(email: email)
    |> Repo.preload([:credentials, :user_prefs])
  end

  @doc """
  Get user by email address.

  ## Examples

  iex> get_by_email(email)
  {:ok, %User{}}

  iex> get_by_email(bad_email)
  {:error, :not_found}

  """
  def get_by_email(email) do
    user = User
    |> Repo.get_by(email: email)
    |> Repo.preload([:credentials, :user_prefs])

    case user do
      nil ->
        {:error, :not_found}
      user ->
        {:ok, user}
    end
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

  iex> get_user!(123)
  %User{}

  iex> get_user!(456)
  ** (Ecto.NoResultsError)

  """
  def get_user(id) do
    user = User
    |> Repo.get(id)
    |> Repo.preload([:credentials, :user_prefs])

    case user do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do
    User
    |> Repo.get!(id)
    |> Repo.preload([:credentials, :user_prefs])
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{user_prefs: %{}}) do
    new_attrs = attrs
    |> Utils.key_to_atom()
    |> Map.put_new(:user_prefs, %{})

    %User{}
    |> User.changeset(new_attrs)
    |> Changeset.cast_assoc(:user_prefs, with: &UserPrefs.changeset/2)
    |> Repo.insert_with_slug()
  end

  def register_user(attrs \\ %{user_prefs: %{}}) do
    new_attrs = attrs
    |> Utils.key_to_atom()
    |> Map.put_new(:user_prefs, %{})

    %User{}
    |> User.registration_changeset(new_attrs)
    |> Changeset.cast_assoc(:user_prefs, with: &UserPrefs.changeset/2)
    |> Repo.insert_with_slug()
  end

  def update_user_password(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Changeset.cast_assoc(:user_prefs, with: &UserPrefs.changeset/2)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns the list of credentials by user.

  ## Examples

  iex> list_credentials(user)
  [%Credential{}, ...]

  """
  def list_credentials(%User{} = user) do
    Credential
    |> by_user(user)
    |> Repo.all()
  end

  def fetch_credential_by_provider(%User{} = user, provider) do
    credential = Credential
    |> Repo.get_by(provider: provider, user_id: user.id)
    |> Repo.preload(user: [:user_prefs])

    if credential do
      {:ok, credential}
    else
      {:error, :not_found}
    end
  end

  def fetch_credential(provider, uid) do
    case get_credential(provider, uid) do
      nil -> {:error, :not_found}
      credential -> {:ok, credential}
    end
  end

  @doc """
  Gets a single credential by provider and uid.

  Returns nil if Credential does not exist.

  ## Examples

      iex> get_credential("strava", 1)
      %Credential{}

      iex> get_credential("strava", 2)
      nil

  """
  def get_credential(provider, uid) when is_integer(uid) do
    get_credential(provider, "#{uid}")
  end
  def get_credential(provider, uid) do
    Credential
    |> Repo.get_by(provider: provider, uid: uid)
    |> Repo.preload(user: [:user_prefs])
  end

  @doc """
  Creates a credential
  """
  def create_credential(%User{} = user, attrs) do
    %Credential{}
    |> Credential.changeset(attrs)
    |> Changeset.put_change(:user_id, user.id)
    |> Repo.insert()
  end

  @doc """
  Updates a credential
  """
  def update_credential(%Credential{} = credential, attrs) do
    credential
    |> Credential.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Credential.

  ## Examples

  iex> delete_credential(credential)
  {:ok, %Credential{}}

  iex> delete_credential(credential)
  {:error, %Ecto.Changeset{}}

  """
  def delete_credential(%Credential{} = credential) do
    Repo.delete(credential)
  end

  @doc """
  Updates a user_prefs.

  ## Examples

  iex> update_user_prefs(user_prefs, %{field: new_value})
  {:ok, %UserPrefs{}}

  iex> update_user_prefs(user_prefs, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_user_prefs(%UserPrefs{} = user_prefs, attrs) do
    user_prefs
    |> UserPrefs.changeset(attrs)
    |> Repo.update()
  end

  def put_personal_record(%User{} = user, %{"distance" => distance} = personal_record_attrs)
  when is_binary(distance) do
    {distance, ""} = Float.parse(distance)

    put_personal_record(user, Map.put(personal_record_attrs, "distance", distance))
  end
  def put_personal_record(%User{} = user, %{"distance" => distance} = personal_record_attrs) do
    prs = user.user_prefs.personal_records
    |> Enum.reject(&(&1.distance == distance))
    |> Enum.map(&Map.from_struct/1)

    user.user_prefs
    |> UserPrefs.changeset(%{personal_records: prs ++ [personal_record_attrs]})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_prefs changes.

  ## Examples

      iex> change_user_prefs(user_prefs)
      %Ecto.Changeset{source: %UserPrefs{}}

  """
  def change_user_prefs(%UserPrefs{} = user_prefs) do
    UserPrefs.changeset(user_prefs, %{})
  end

  defp by_user(query, %User{} = user) do
    from q in query, where: [user_id: ^user.id]
  end
end
