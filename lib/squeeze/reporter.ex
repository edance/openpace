defmodule Squeeze.Reporter do
  @moduledoc """
  This module reports information to slack
  """
  require Logger

  alias Slack.Web.Chat
  alias Squeeze.Accounts.User

  def report_new_user(%User{} = user) do
    text = if user.user_prefs.rename_activities do
      "Namer Sign Up: #{user.first_name} #{user.last_name}"
    else
      "Sign Up: #{user.first_name} #{user.last_name}"
    end
    post_message(text)
  end

  defp post_message(text) do
    Chat.post_message("#general", text)
    Logger.info(text)
  end
end
