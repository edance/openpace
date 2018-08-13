defmodule SqueezeWeb.InputHelpers do
  use Phoenix.HTML

  import Phoenix.HTML

  def duration_select(form, field) do
    id = input_id(form, field)
    name = input_name(form, field)
    value = input_value(form, field)

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

  defp select_tag(form, parent, field, value) do
    id = input_id(form, parent)
    name = input_name(form, parent)
    value = Map.get(value, field)
    select(form, parent, 0..59, value: value, id: "#{id}_#{field}", name: "#{name}[#{field}]")
  end
end
