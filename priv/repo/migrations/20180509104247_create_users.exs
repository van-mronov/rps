defmodule RPS.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :password_digest, :string

      timestamps()
    end

  end
end
