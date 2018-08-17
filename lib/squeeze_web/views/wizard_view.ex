defmodule SqueezeWeb.WizardView do
  use SqueezeWeb, :view

  def title(_page, _assigns) do
    "Update your preferences"
  end

  def improvement_amount(user) do
    prefs = user.user_prefs
    personal_record = prefs.personal_record.total
    percent = (personal_record - prefs.duration.total) / personal_record * 100
    "#{Decimal.round(Decimal.new(percent), 1)}%"
  end
end
