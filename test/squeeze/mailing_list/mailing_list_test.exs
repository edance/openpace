defmodule Squeeze.MailingListTest do
  use Squeeze.DataCase

  alias Squeeze.MailingList

  describe "subscriptions" do
    alias Squeeze.MailingList.Subscription

    test "create_subscription/1 with valid data creates a subscription" do
      assert {:ok, %Subscription{} = subscription} =
               MailingList.create_subscription(%{email: "test@email.com", type: "some type"})

      assert subscription.email == "test@email.com"
      assert subscription.type == "some type"
    end

    test "create_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MailingList.create_subscription(%{email: ""})
    end
  end
end
