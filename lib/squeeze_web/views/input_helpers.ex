defmodule SqueezeWeb.InputHelpers do
  use Phoenix.HTML

  import Phoenix.HTML

  require IEx

  def duration_select(form, field) do
    id = input_id(form, field)
    name = input_name(form, field)
    value = duration_value(form, field)

    content_tag :div do
      [
        select_tag(form, field, :hours, value),
        ":",
        select_tag(form, field, :minutes, value),
        ":",
        select_tag(form, field, :seconds, value)
      ]
    end
  end

  defp duration_value(form, field)  do
    value = input_value(form, field) || 10800 + 10 * 60 + 12 # 3:10:12

    {hours, minutes, seconds, _} =
      Timex.Duration.from_seconds(value)
      |> Timex.Duration.to_clock()
    %{hours: hours, minutes: minutes, seconds: seconds}
  end

  defp select_tag(form, parent, field, value) do
    id = input_id(form, parent)
    name = input_name(form, parent)
    value = Map.get(value, field)
    select(form, parent, 0..59, value: value, id: "#{id}_#{field}", name: "#{name}[#{field}]")
  end
end
