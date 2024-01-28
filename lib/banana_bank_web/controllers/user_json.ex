defmodule BananaBankWeb.UserJSON do
  alias BananaBank.Users.User

  def create(%{user: user}) do
    %{
      message: "User created successfully!",
      user: data(user)
    }
  end

  def delete(%{user: user}), do: data(user)

  def get(%{user: user}), do: data(user)

  def update(%{user: user}) do
    %{
      message: "User updated successfully!",
      user: data(user)
    }
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      cep: user.cep,
      name: user.name
    }
  end
end
