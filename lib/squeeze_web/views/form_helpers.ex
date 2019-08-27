defmodule SqueezeWeb.FormHelpers do
  @moduledoc """
  This module contains different helper functions for the different data types
  used in the app.
  """

  use Phoenix.HTML

  import Phoenix.HTML

  alias Squeeze.Duration

  map =
    &Enum.map(&1, fn i ->
      pre = if i < 10, do: "0"
      {"#{pre}#{i}", i}
    end)

  @minsec map.(0..59)

  def autocomplete(form, field, options, opts \\ []) do
    list_name = "autocomplete-#{:rand.uniform(1000)}"
    option_html = options
    |> Enum.map(fn({k, v}) -> "<option data-value='#{v}'>#{k}</option>" end)
    class_list = "#{opts[:class]} autocomplete"
    opts = Keyword.merge(opts, [class: class_list])

    [
      input(form, field, opts ++ [class: class_list, list: list_name]),
      hidden_input(form, field, id: "#{list_name}-hidden"),
      raw("<datalist id=#{list_name}>#{option_html}</datalist>")
    ]
  end

  def async_form(form_data, action, options \\ [], fun) do
    form_for(form_data, action, options ++ [data: [remote: "true"]], fun)
  end

  def invalid_field?(form, field) do
    Keyword.get_values(form.errors, field) != []
  end

  def input_class_list(form, field, class_list \\ "") do
    if invalid_field?(form, field) do
      "#{class_list} is-invalid"
    else
      class_list
    end
  end

  def input(form, field, opts \\ []) do
    class_list = input_class_list(form, field, opts[:class])
    text_input(form, field, Keyword.merge(opts, [class: class_list]))
  end

  def pill_button(form, field, label, value, opts \\ []) do
    content_tag(:label, class: "btn btn-secondary w-100") do
      [
        label,
        radio_button(form, field, value, opts)
      ]
    end
  end

  def duration_input(form, field, opts \\ []) do
    default_opts = [
      autocomplete: "off",
      class: "time-input #{opts[:class]}",
      placeholder: opts[:placeholder] || "hh:mm:ss",
      value: Map.get(form.data, field) |> Duration.format()
    ]
    opts = Keyword.merge(opts, default_opts)
    input(form, field, opts)
  end

  def duration_select(form, field, opts \\ []) do
    content_tag(:div, class: "duration-select form-row") do
      [
        select_tag(form, field, :hours, opts),
        select_tag(form, field, :minutes, opts),
        select_tag(form, field, :seconds, opts),
        hidden_input(form, field)
      ]
    end
  end

  def distance_input(form, field) when is_atom(field) do
    distance_input(form, Atom.to_string(field))
  end
  def distance_input(form, field, opts \\ []) do
    input_field = "#{field}_amount" |> String.to_atom()
    [
      input(form, input_field, opts),
      distance_input_select(form, field)
    ]
  end

  defp distance_input_select(form, field) do
    field = "#{field}_unit" |> String.to_atom()
    content_tag(:div, class: "input-group-append") do
      [
        select(form, field, distance_types(), class: "form-control custom-select")
      ]
    end
  end

  defp distance_types do
    [
      "mi",
      "km",
      "m"
    ]
  end

  defp select_tag(form, parent, field, opts) do
    opts = opts
    |> Keyword.put(:name, field)
    |> Keyword.put(:prompt, field)

    content_tag(:div, class: "col") do
      select(form, parent, @minsec, opts)
    end
  end
end
