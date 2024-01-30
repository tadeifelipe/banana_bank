defmodule BananaBank.ViaCep.ClientTest do
  use ExUnit.Case, async: true

  alias BananaBank.ViaCep.Client

  setup do
    bypass = Bypass.open()

    {:ok, bypass: bypass}
  end

  describe "call/1" do
    test "success returns cep info", %{bypass: bypass} do
      body = ~s({
        "cep": "17700-000",
        "logradouro": "",
        "complemento": "",
        "bairro": "",
        "localidade": "Osvaldo Cruz",
        "uf": "SP",
        "ibge": "3534609",
        "gia": "4947",
        "ddd": "18",
        "siafi": "6793"})

      Bypass.expect(bypass, "GET", "17700000/json", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, body)
      end)

      cep = "17700000"

      expected_response =
        {
          :ok,
          %{
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
        }

      response =
        bypass.port
        |> endpoint_url()
        |> Client.call(cep)

      assert response == expected_response
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"
end
