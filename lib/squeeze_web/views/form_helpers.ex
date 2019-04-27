defmodule SqueezeWeb.FormHelpers do
  @moduledoc """
  This module contains different helper functions for the different data types
  used in the app.
  """

  use Phoenix.HTML

  import Phoenix.HTML

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
    class_list = "#{opts[:class]} awesomplete autocomplete"
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

  def input(form, field, opts \\ []) do
    case Keyword.get_values(form.errors, field) do
      [] -> text_input(form, field, opts)
      _ ->
        class_list = "#{opts[:class]} is-invalid"
        text_input(form, field, Keyword.merge(opts, [class: class_list]))
    end
  end

  def pill_button(form, field, label, value, opts \\ []) do
    content_tag(:label, class: "btn btn-secondary w-100") do
      [
        label,
        radio_button(form, field, value, opts)
      ]
    end
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

  defp select_tag(form, parent, field, opts) do
    opts = opts
    |> Keyword.put(:name, field)
    |> Keyword.put(:prompt, field)

    content_tag(:div, class: "col") do
      select(form, parent, @minsec, opts)
    end
  end
end
