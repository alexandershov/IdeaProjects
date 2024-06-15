defmodule Thames.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :order, :integer
      add :chat_id, :string
      add :role, :string
      add :content, :string

      timestamps(type: :utc_datetime)
    end
  end
end
