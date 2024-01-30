defmodule BananaBankWeb.Plugs.Auth do
  import Plug.Conn

  def init(ops), do: ops

  def call(conn, _opts) do
    IO.inspect(conn)
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, data} <- BananaBankWeb.Token.verify(token) do
      assign(conn, :user_id, data.user_id)
    else
      _error ->
        conn
        |> put_status(:unauthorized)
        |> Phoenix.Controller.put_view(json: BananaBankWeb.ErrorJSON)
        |> Phoenix.Controller.render(:error, status: "unauthorized")
        |> halt()
    end
  end
end
