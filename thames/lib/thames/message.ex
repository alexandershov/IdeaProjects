defmodule Thames.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :role, :string
    field :order, :integer
    field :chat_id, :string
    field :content, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:order, :chat_id, :role, :content])
    |> validate_required([:order, :chat_id, :role, :content])
  end
end
