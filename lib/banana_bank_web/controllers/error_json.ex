defmodule BananaBankWeb.ErrorJSON do
  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  def error(%{changeset: changeset}) do
    %{
      errors: Ecto.Changeset.traverse_errors(changeset, &translate_errors/1)
    }
  end

  def error(%{status: :not_found}) do
    %{
      status: :not_found,
      message: "Resource not found"
    }
  end

  def error(%{status: status}) do
    %{
      status: status
    }
  end

  def error(%{msg: msg}) do
    %{
      msg: msg
    }
  end

  defp translate_errors({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end
