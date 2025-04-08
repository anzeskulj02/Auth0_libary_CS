defmodule <%= app_module %>Web.Plugs.EnsureAuthenticated do
  @moduledoc """
  Plug to ensure user is authenticated.
  """
  import Plug.Conn
  import Phoenix.Controller

  alias <%= app_module %>Web.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    case Guardian.check_sign(get_session(conn, :auth_token)) do
      {:ok, _user} -> conn
      {:error, _} ->
        conn
          |> redirect(to: "/auth/auth0")
          |> halt()
    end
  end
end
