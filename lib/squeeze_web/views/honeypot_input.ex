defmodule SqueezeWeb.HoneypotInput do
  @moduledoc """
  Honeypot Input Helper
  """

  use Phoenix.HTML

  def honeypot_input(form, field, opts \\ []) do
    opts = opts ++ input_opts()
    [
      text_input(form, field, opts)
    ]
  end

  defp input_opts do
    [autocomplete: "off", tabindex: "-1", style: css_strategy()]
  end

  defp css_strategy do
    [
      "position:absolute!important;top:-9999px;left:-9999px;"
    ]
    |> Enum.random()
  end
end
