defmodule <%= app_module %>Web.Plugs.LoadTenant do
  @moduledoc """
  Plug to load tenant data for the current user.
  """
  import Plug.Conn

  alias <%= app_module %>.Tenants

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = get_session(conn, :current_user)

    if current_user && current_user.tenant_id do
      tenant_with_data = Tenants.get_tenant_with_data(current_user.tenant_id)

      conn
      |> assign(:current_tenant, tenant_with_data)
      |> assign(:tenant_data, tenant_with_data.tenant_data)
    else
      conn
    end
  end
end
