defmodule Squeeze.Factory do
  use ExMachina.Ecto, repo: Squeeze.Repo

  use Squeeze.ActivityFactory
  use Squeeze.CredentialFactory
  use Squeeze.DetailedActivityFactory
  use Squeeze.PaymentMethodFactory
  use Squeeze.TrainingPlanFactory
  use Squeeze.UserFactory
  use Squeeze.UserPrefsFactory

  @moduledoc false
end
