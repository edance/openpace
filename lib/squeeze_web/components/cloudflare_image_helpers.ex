defmodule SqueezeWeb.CloudflareImageHelpers do
  use Phoenix.Component

  @moduledoc """
  A component to generate Cloudflare image tags with the given image_id and options.
  """

  @doc """
  Generates an image tag with the given image_id and options.
  ## Examples
      <.cloudflare_img
        src={Routes.static_path(SqueezeWeb.Endpoint, "/images/home/overview.jpg")}
        height={100}
        width={100}
        class="rounded-xl shadow-xl ring-1 ring-gray-400/10"
      />
  """
  attr :src, :string, required: true
  attr :height, :integer, required: true
  attr :width, :integer, required: true
  attr :alt, :string, required: true
  attr :cloudflare_opts, :list, default: []
  attr :class, :string, default: ""

  def cloudflare_img(assigns) do
    %{src: src, cloudflare_opts: options, width: width, height: height} = assigns
    options = options ++ [{:width, width}, {:height, height}]

    assigns =
      assigns
      |> assign(:src, generate_url(src, options))

    ~H"""
    <img src={@src} alt={@alt} height={@height} width={@width} class={@class} />
    """
  end

  defp generate_url(src, options) do
    case System.get_env("PHX_HOST") do
      nil ->
        src

      # If we have a defined host, we generate the Cloudflare URL
      _ ->
        variant = build_variant(options)
        "/cdn-cgi/image/#{variant}#{src}"
    end
  end

  defp build_variant(options) do
    options
    |> Enum.map_join(",", &transform_option/1)
    |> case do
      # Default variant if no options are specified
      "" -> "public"
      variant -> variant
    end
  end

  defp transform_option({:width, value}), do: "w=#{value}"
  defp transform_option({:height, value}), do: "h=#{value}"
  defp transform_option({:fit, value}), do: "fit=#{value}"
  defp transform_option({:quality, value}), do: "quality=#{value}"
  defp transform_option({:format, value}), do: "format=#{value}"
  defp transform_option(_), do: ""
end
