defmodule BananaBank.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias BananaBank.Accounts.Account

  @required_params [:name, :password, :email, :cep]
  @required_params_update [:name, :email, :cep]

  schema "users" do
    field :name, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    field :email, :string
    field :cep, :string
    has_one :account, Account

    timestamps()
  end

  def changeset(params) do
    %__MODULE__{}
    |> do_validations(params, @required_params)
  end

  def changeset(user, params) do
    user
    |> do_validations(params, @required_params_update)
  end

  defp do_validations(changeset, params, fields_to_validate) do
    changeset
    |> cast(params, fields_to_validate)
    |> validate_required(fields_to_validate)
    |> validate_length(:name, min: 3)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:cep, min: 8)
    |> add_password_hash()
  end

  defp add_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    change(changeset, %{password_hash: Pbkdf2.hash_pwd_salt(password)})
  end

  defp add_password_hash(changeset), do: changeset
end
