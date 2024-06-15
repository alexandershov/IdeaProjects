defmodule Thames.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :chat_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:chat_id])
    |> validate_required([:chat_id])
  end
end
