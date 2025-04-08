defmodule Mix.Tasks.My.Installer do
  use Mix.Task
  @shortdoc "Installs MyInstaller into your project"

  @moduledoc """
  Adds necessary files and modifies existing ones in a Phoenix project.
  """

  def run(_args) do
    Mix.shell().info("🔧 Installing MyInstaller...")

    app_path = File.cwd!()

    # Add new files
    copy_templates(app_path)

    # Modify router
    modify_router(app_path)

    # Modify config
    modify_config(app_path)

    Mix.shell().info(
      """
      ✅ Auth0 installed successfully.

      1. Run `mix ecto.migrate` to create the necessary database tables.

      2. Add the following environment variables to your `.env` file:
        ```
        export AUTH0_DOMAIN=your_auth0_domain
        export AUTH0_CLIENT_ID=your_auth0_client_id
        export AUTH0_CLIENT_SECRET=your_auth0_client_secret
        export GUARDIAN_SECRET_KEY=your_guardian_secret_key
        export AUTH0_MANAGEMENT_API=your_auth0_management_api
        export AUTH0_MANAGEMENT_GRANT_ID=your_auth0_management_grant_id
        ```

      3. Source your `.env` file:
        `source .env`

      4. Start your Phoenix server:
        `iex -S mix phx.server`
      """)
  end

  defp copy_templates(app_path) do
    app_module = get_app_module_name()
    assigns = [app_module: app_module]

    template_path =
      :my_installer
      |> :code.priv_dir()

    content_auth0_controller = render_template(Path.join(template_path, "auth_controller.ex"), assigns)
    content_ensure_authenticated = render_template(Path.join(template_path, "ensure_authenticated.ex"), assigns)
    content_load_tenant = render_template(Path.join(template_path, "load_tenant.ex"), assigns)
    content_guardian = render_template(Path.join(template_path, "guardian.ex"), assigns)

    content_users = render_template(Path.join(template_path, "user.ex"), assigns)
    content_tenant_data = render_template(Path.join(template_path, "tenant_data.ex"), assigns)
    content_tenant = render_template(Path.join(template_path, "tenant.ex"), assigns)

    content_users_migration = render_template(Path.join(template_path, "20250311090001_create_users.exs"), assigns)
    content_tenants_migration = render_template(Path.join(template_path, "20250311090000_create_tenants.exs"), assigns)
    content_tenant_data_migrations = render_template(Path.join(template_path, "20250311090002_create_tenant_data.exs"), assigns)

    File.write!(Path.join(app_path, "lib/#{Macro.underscore(app_module)}_web/controllers/auth0_controller.ex"), content_auth0_controller)

    case File.mkdir_p("lib/#{Macro.underscore(app_module)}_web/plugs") do
      :ok ->
        File.write!(Path.join(app_path, "lib/#{Macro.underscore(app_module)}_web/plugs/ensure_authenticated.ex"), content_ensure_authenticated)
        File.write!(Path.join(app_path, "lib/#{Macro.underscore(app_module)}_web/plugs/load_tenant.ex"), content_load_tenant)
      {:error, reason} ->
        Mix.shell().info("⚠️ Failed to create plugs folder.#{inspect(reason)}")
    end

    File.write!(Path.join(app_path, "lib/#{Macro.underscore(app_module)}_web/guardian.ex"), content_guardian)

    case File.mkdir_p("lib/#{Macro.underscore(app_module)}/accounts") do
      :ok ->
        File.write!(Path.join(app_path, "lib/#{Macro.underscore(app_module)}/accounts/user.ex"), content_users)
      {:error, reason} ->
        Mix.shell().info("⚠️ Failed to create accounts folder.#{inspect(reason)}")
    end

    case File.mkdir_p("lib/#{Macro.underscore(app_module)}/tenants") do
      :ok ->
        File.write!(Path.join(app_path, "lib/#{Macro.underscore(app_module)}/tenants/tenant_data.ex"), content_tenant_data)
        File.write!(Path.join(app_path, "lib/#{Macro.underscore(app_module)}/tenants/tenant.ex"), content_tenant)
      {:error, reason} ->
        Mix.shell().info("⚠️ Failed to create tenants folder.#{inspect(reason)}")
    end

    case File.mkdir_p("priv/repo/migrations") do
      :ok ->
        File.write!(Path.join(app_path, "priv/repo/migrations/20250311090001_create_users.exs"), content_users_migration)
        File.write!(Path.join(app_path, "priv/repo/migrations/20250311090000_create_tenants.exs"), content_tenants_migration)
        File.write!(Path.join(app_path, "priv/repo/migrations/20250311090002_create_tenant_data.exs"), content_tenant_data_migrations)
      {:error, reason} ->
        Mix.shell().info("⚠️ Failed to create migrations folder.#{inspect(reason)}")
    end

    Mix.shell().info("✅ lib/#{Macro.underscore(app_module)}_web/controllers/auth0_controller.ex created")
    Mix.shell().info("✅ lib/#{Macro.underscore(app_module)}_web/plugs/ensure_authenticated.ex created")
    Mix.shell().info("✅ lib/#{Macro.underscore(app_module)}_web/plugs/load_tenant.ex created")
    Mix.shell().info("✅ lib/#{Macro.underscore(app_module)}_web/guardian.ex created")
    Mix.shell().info("✅ lib/#{Macro.underscore(app_module)}/accounts/user.ex created")
    Mix.shell().info("✅ lib/#{Macro.underscore(app_module)}/tenants/tenant_data.ex created")
    Mix.shell().info("✅ lib/#{Macro.underscore(app_module)}/tenants/tenant.ex created")
    Mix.shell().info("✅ priv/repo/migrations/20250311090001_create_users.ex created")
    Mix.shell().info("✅ priv/repo/migrations/20250311090000_create_tenants.ex created")
    Mix.shell().info("✅ priv/repo/migrations/20250311090000_create_tenant_data.ex created")
    Mix.shell().info("\n")
  end

  defp modify_router(app_path) do
    app_module = get_app_module_name()

    router_path = Path.join(app_path, "lib/#{Macro.underscore(app_module)}_web/router.ex")

    content = File.read!(router_path)

    unless String.contains?(content, "/auth") do
      modified =
        content
        |> String.replace(
          """
          pipeline :api do
            plug :accepts, ["json"]
          end
          """,
          """
          # Auth0 authentication routes
          scope "/auth", #{app_module} do
            pipe_through :browser

            get "/:provider", AuthController, :request
            get "/:provider/callback", AuthController, :callback
            post "/:provider/callback", AuthController, :callback
            get "/:provider/logout", AuthController, :logout
          end

          # Authenticated routes
          pipeline :authenticated do
            plug #{app_module}.Plugs.EnsureAuthenticated
            plug #{app_module}.Plugs.LoadTenant
          end
          """)

      File.write!(router_path, modified)
      Mix.shell().info("✏️  Modified router.ex to include Auth0 routes and authentication pipeline")
      Mix.shell().info("\n")
    else
      Mix.shell().info("⚠️  router.ex already contains Auth0")
      Mix.shell().info("\n")
    end
  end

  def modify_config(app_path) do
    app_module = get_app_module_name()

    config_path = Path.join(app_path, "config/config.exs")

    content = File.read!(config_path)

    unless String.contains?(content, "# Auth0 configuration") do
      modified =
        content
        |> String.replace("import Config",
          """
          import Config

          # Auth0 configuration
          config :ueberauth, Ueberauth,
            providers: [
              auth0:
                {Ueberauth.Strategy.Auth0,
                [
                  default_scope: "openid email profile",
                  organization: {&#{app_module}Web.AuthController.get_organization/1, []},
                  organization_parameter_type: :param
                ]}
            ]

          config :ueberauth, Ueberauth.Strategy.Auth0.OAuth,
            domain: System.get_env("AUTH0_DOMAIN"),
            client_id: System.get_env("AUTH0_CLIENT_ID"),
            client_secret: System.get_env("AUTH0_CLIENT_SECRET")

          # Configure Guardian for JWT handling
          config :#{Macro.underscore(app_module)}, #{app_module}Web.Guardian,
            issuer: "auth0poc",
            secret_key: System.get_env("GUARDIAN_SECRET_KEY", "your_dev_secret")

          # Configure API token for Auth0 Management API
          config :#{Macro.underscore(app_module)}, #{app_module}.Auth0API,
            domain: System.get_env("AUTH0_DOMAIN"),
            client_id: System.get_env("AUTH0_CLIENT_ID"),
            client_secret: System.get_env("AUTH0_CLIENT_SECRET")
        """)

      File.write!(config_path, modified)
      Mix.shell().info("✏️  Modified config.exs to include MyInstaller configuration")
      Mix.shell().info("\n")
    else
      Mix.shell().info("⚠️  config.exs already contains MyInstaller configuration")
      Mix.shell().info("\n")
    end
  end

  defp get_app_module_name do
    Mix.Project.get!()
      |> Module.split()
      |> Enum.at(0)
  end

  defp render_template(template_path, assigns) do
    template = File.read!(template_path)
    EEx.eval_string(template, assigns)
  end
end
