defmodule Squeeze.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Squeeze.Accounts.{Credential, User, UserPrefs}
  alias Squeeze.Repo

  @doc """
  Creates a guest user account. All visitors are assigned an account to help
  with onboarding and preferences.

  ## Examples

  iex> create_guest_user()
  {:ok, %User{}}
  """
  def create_guest_user do
    create_user()
  end

  @doc """
  Gets or creates a user based on their credentials.

  ## Examples

  iex> get_or_update_user_by_credential(%{field: field})
  {:ok, %User{}}

  iex> get_or_update_user_by_credential(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def get_or_update_user_by_credential(%User{} = user, attrs \\ %{}) do
    %{credential: %{provider: provider, uid: uid}} = attrs
    case get_credential(provider, uid) do
      nil -> update_user(user, attrs)
      credential -> {:ok, credential.user}
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
    |> Repo.preload([:credential, :user_prefs])
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
    %User{}
    |> User.changeset(attrs)
    |> Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
    |> Changeset.cast_assoc(:user_prefs, with: &UserPrefs.changeset/2)
    |> Repo.insert()
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
    |> Changeset.cast_assoc(:credential, with: &Credential.changeset/2)
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
  Gets a single credential by provider and uid.

  Returns nil if Credential does not exist.

  ## Examples

      iex> get_credential("strava", 1)
      %Credential{}

      iex> get_credential("strava", 2)
      nil

  """
  def get_credential(provider, uid) do
    Credential
    |> Repo.get_by(provider: provider, uid: uid)
    |> Repo.preload(:user)
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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_prefs changes.

  ## Examples

  iex> change_user_prefs(user_prefs)
  %Ecto.Changeset{source: %UserPrefs{}}

  """
  def change_user_prefs(%UserPrefs{} = user_prefs) do
    UserPrefs.changeset(user_prefs, %{})
  end
end
