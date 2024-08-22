defmodule Squeeze.Challenges.RecurringChallenges do
  @moduledoc false

  import Ecto.Query, warn: false
  alias Ecto.{Changeset, Multi}
  alias Squeeze.Challenges
  alias Squeeze.Challenges.{Challenge, Score}
  alias Squeeze.Repo
  alias Squeeze.SlugGenerator

  @fields_to_clone ~w(
    name
    activity_type
    challenge_type
    timeline
    segment_id
    polyline
    private
    recurring
  )a

  def find_and_create(datetime \\ Timex.now()) do
    list_recurring_challenges_ending_today(datetime)
    |> Enum.each(&create_new_challenge/1)
  end

  def create_new_challenge(challenge) do
    slug = SlugGenerator.gen_slug()

    changeset =
      %Challenge{}
      |> Challenge.changeset(challenge_attrs(challenge))
      |> Changeset.put_change(:slug, slug)
      |> Changeset.put_change(:user_id, challenge.user_id)

    Multi.new()
    |> Multi.insert(:challenge, changeset)
    |> Multi.insert_all(:scores, Score, fn %{challenge: new_challenge} ->
      Challenges.list_users(challenge)
      |> Enum.map(&score_attrs(new_challenge, &1))
    end)
    |> Repo.transaction()
  end

  def challenge_attrs(challenge) do
    challenge
    |> Map.take(@fields_to_clone)
    |> Map.merge(challenge_dates(challenge))
  end

  def score_attrs(%Challenge{} = challenge, user) do
    now = Timex.now() |> Timex.to_naive_datetime() |> NaiveDateTime.truncate(:second)

    amount =
      case challenge.challenge_type do
        :segment -> nil
        _ -> 0.0
      end

    %{
      user_id: user.id,
      challenge_id: challenge.id,
      amount: amount,
      score: Challenges.ranking_score(challenge, amount),
      inserted_at: now,
      updated_at: now
    }
  end

  def challenge_dates(%{timeline: :day, start_date: date}) do
    %{
      start_date: Timex.shift(date, days: 1),
      end_date: Timex.shift(date, days: 1)
    }
  end

  def challenge_dates(%{timeline: :weekend} = challenge) do
    %{
      start_date: Timex.shift(challenge.start_date, days: 7),
      end_date: Timex.shift(challenge.end_date, days: 7)
    }
  end

  def challenge_dates(%{timeline: :week} = challenge) do
    %{
      start_date: Timex.shift(challenge.start_date, days: 7),
      end_date: Timex.shift(challenge.end_date, days: 7)
    }
  end

  def challenge_dates(%{timeline: :month} = challenge) do
    date = challenge.start_date |> Timex.shift(months: 1)

    %{
      start_date: date,
      end_date: Timex.end_of_month(date)
    }
  end

  defp list_recurring_challenges_ending_today(datetime) do
    today = datetime |> Timex.to_date()

    query =
      from p in Challenge,
        where: p.end_date == ^today,
        where: p.recurring == true

    Repo.all(query)
  end
end
