defmodule BananaBankWeb.UserControllerTest do
  use BananaBankWeb.ConnCase

  alias BananaBank.Users
  alias Users.User

  import Mox

  setup do
    params = %{
      "name" => "Felipe",
      "cep" => "17700000",
      "email" => "felipe@email.com",
      "password" => "12345"
    }

    body = %{
      "bairro" => "",
      "cep" => "17700-000",
      "complemento" => "",
      "ddd" => "18",
      "gia" => "4947",
      "ibge" => "3534609",
      "localidade" => "Osvaldo Cruz",
      "logradouro" => "",
      "siafi" => "6793",
      "uf" => "SP"
    }

    {:ok, user_params: params, body: body}
  end

  describe "create/2" do
    test "POST / create user successfully", %{conn: conn, user_params: user_params, body: body} do
      expect(BananaBank.ViaCep.ClientMock, :call, fn "17700000" ->
        {:ok, body}
      end)

      response =
        conn
        |> post(~p"/api/users", user_params)
        |> json_response(201)

      assert %{
               "message" => "User created successfully!",
               "user" => %{
                 "cep" => "17700000",
                 "id" => _id,
                 "name" => "Felipe"
               }
             } = response
    end

    test "POST / should return erro when try create invalid user", %{conn: conn} do
      params = %{
        "name" => "Felipe",
        "cep" => "17700",
        "email" => "felipeemail.com",
        "password" => "12345"
      }

      expect(BananaBank.ViaCep.ClientMock, :call, fn "17700" ->
        {:ok, ""}
      end)

      response =
        conn
        |> post(~p"/api/users", params)
        |> json_response(400)

      expected_response = %{
        "errors" => %{
          "cep" => ["should be at least 8 character(s)"],
          "email" => ["has invalid format"]
        }
      }

      assert expected_response == response
    end
  end

  describe "delete/1" do
    test "DELETE / delete an user successfully", %{
      conn: conn,
      user_params: user_params,
      body: body
    } do
      expect(BananaBank.ViaCep.ClientMock, :call, fn "17700000" ->
        {:ok, body}
      end)

      {:ok, %User{id: id}} = Users.create(user_params)

      response =
        conn
        |> delete(~p"/api/users/#{id}")
        |> json_response(200)

      assert %{"cep" => "17700000", "id" => ^id, "name" => "Felipe"} = response
    end
  end
end
