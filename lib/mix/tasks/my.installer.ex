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

    # Modify existing files
    modify_router(app_path)

    Mix.shell().info("✅ MyInstaller installed successfully.")
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

    File.write!(Path.join(app_path, "lib/#{Macro.underscore(app_module)}_web/controllers/auth0_controller.ex"), content_auth0_controller)

    case File.mkdir_p("lib/#{Macro.underscore(app_module)}_web/plugs") do
      :ok ->
        File.write!(Path.join(app_path, "lib/#{Macro.underscore(app_module)}_web/plugs/ensure_authenticated.ex"), content_ensure_authenticated)
        File.write!(Path.join(app_path, "lib/#{Macro.underscore(app_module)}_web/plugs/load_tenant.ex"), content_load_tenant)
      {:error, reason} ->
        Mix.shell().info("Failed to create plugs folder.#{inspect(reason)}")
    end

    File.write!(Path.join(app_path, "lib/#{Macro.underscore(app_module)}_web/guardian.ex"), content_guardian)
  end

  defp modify_router(app_path) do
    router_path = Path.join(app_path, "lib/my_app_web/router.ex")

    content = File.read!(router_path)

    unless String.contains?(content, "MyInstallerPlug") do
      modified =
        content
        |> String.replace("use Phoenix.Router", "use Phoenix.Router\n  import MyInstallerPlug")

      File.write!(router_path, modified)
      Mix.shell().info("✏️  Modified router.ex to include MyInstallerPlug")
    else
      Mix.shell().info("⚠️  router.ex already contains MyInstallerPlug")
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
