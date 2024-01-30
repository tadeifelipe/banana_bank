defmodule BananaBank.Accounts.Transaction do
  alias Ecto.Multi
  alias BananaBank.Accounts
  alias Accounts.Account
  alias BananaBank.Repo

  def call(%{
        "from_account_id" => from_account_id,
        "to_account_id" => to_account_id,
        "value" => value
      }) do
    with {%Account{} = from_account} <- Repo.get(Account, from_account_id),
         {%Account{} = to_account} <- Repo.get(Account, to_account_id),
         {:ok, value} <- Decimal.cast(value) do
      Multi.new()
      |> withdraw(from_account, value)
      |> deposit(to_account, value)
      |> Repo.transaction()
      |> handle_transaction()
    else
      nil -> {:error, :not_found}
      :error -> {:error, "Invalid value"}
    end
  end

  def call(_), do: {:error, "Invalid params"}

  defp withdraw(multi, from_account, value) do
    new_balance = Decimal.sub(from_account.balance, value)
    changeset = Account.changeset(from_account, %{balance: new_balance})
    Multi.update(multi, :withdraw, changeset)
  end

  defp deposit(multi, to_account, value) do
    new_balance = Decimal.add(to_account.balance, value)
    changeset = Account.changeset(to_account, %{balance: new_balance})
    Multi.update(multi, :withdraw, changeset)
  end

  def handle_transaction({:ok, _result} = result), do: result
  def handle_transaction({:error, _op, reason, _}), do: {:error, reason}
end
