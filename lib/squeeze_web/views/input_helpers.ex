defmodule SqueezeWeb.InputHelpers do
  use Phoenix.HTML

  import Phoenix.HTML

  map =
    &Enum.map(&1, fn i ->
      pre = if i < 10, do: "0"
      {"#{pre}#{i}", i}
    end)

  @minsec map.(0..59)

  def duration_select(form, field, opts \\ []) do
    id = input_id(form, field)
    name = input_name(form, field)
    value = input_value(form, field) || %{}

    content_tag(:div, class: "duration-select")do
      [
        select_tag(form, field, :hours, value, opts),
        select_tag(form, field, :minutes, value, opts),
        select_tag(form, field, :seconds, value, opts)
      ]
    end
  end

  defp select_tag(form, parent, field, value, opts) do
    opts = opts
    |> Keyword.put(:id, "#{input_id(form, parent)}_#{field}")
    |> Keyword.put(:name, "#{input_name(form, parent)}[#{field}]")
    |> Keyword.put(:value, Map.get(value, field))
    |> Keyword.put(:prompt, field)

    select(form, parent, @minsec, opts)
  end
end
