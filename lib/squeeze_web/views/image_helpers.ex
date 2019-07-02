defmodule SqueezeWeb.ImageHelpers do
  @moduledoc """
  This module contains different helper functions for the different data types
  used in the app.
  """

  use Phoenix.HTML

  alias SqueezeWeb.Router.Helpers

  def responsive_img(conn, image_path, opts \\ []) do
    urls = image_urls(conn, image_path)
    srcset = "#{urls.base1x} 1x, #{urls.base2x} 2x"
    opts = Keyword.merge(opts, [src: urls.base1x, srcset: srcset])
    tag(:img, opts)
  end

  def responsive_picture(conn, image_path, opts \\ []) do
    urls = image_urls(conn, image_path)
    content_tag(:picture) do
      [
        tag(:source, srcset: "#{urls.webp1x} 1x, #{urls.webp2x} 2x", type: "image/webp"),
        responsive_img(conn, image_path, opts)
      ]
    end
  end

  defp image_urls(conn, image_path) do
    [path, extension] = String.split(image_path, ".")
    %{
      base1x: Helpers.static_path(conn, "#{path}@1x.#{extension}"),
      base2x: Helpers.static_path(conn, "#{path}@2x.#{extension}"),
      webp1x: Helpers.static_path(conn, "#{path}@1x.webp"),
      webp2x: Helpers.static_path(conn, "#{path}@2x.webp")
    }
  end
end
