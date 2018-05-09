defmodule RPS.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :name, :string
    field :password_digest, :string
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :password])
    |> validate_required([:name, :password])
    |> put_password_digest()
  end

  defp put_password_digest(changeset) do
    if password = get_change(changeset, :password) do
      put_change(changeset, :password_digest, Comeonin.Bcrypt.hashpwsalt(password))
    else
      changeset
    end
  end
end
