defmodule SqueezeWeb.FormHelpers do
  @moduledoc """
  This module contains different helper functions for the different data types
  used in the app.
  """

  use Phoenix.HTML

  import Phoenix.HTML

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

  def input(form, field, opts \\ []) do
    case Keyword.get_values(form.errors, field) do
      [] -> text_input(form, field, opts)
      _ ->
        class_list = "#{opts[:class]} is-invalid"
        text_input(form, field, Keyword.merge(opts, [class: class_list]))
    end
  end

  def pill_button(form, field, label, value, opts \\ []) do
    content_tag(:label, class: "btn btn-secondary") do
      [
        label,
        radio_button(form, field, value, opts)
      ]
    end
  end
end
