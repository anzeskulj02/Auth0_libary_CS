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
    app_module = get_app_module_name(app_path)

    assigns = [app_module: app_module]

    content =
      render_template("priv/templates/auth_controller.ex", assigns)

    File.write!(Path.join(app_path, "lib/#{Macro.underscore(app_module)}/controllers/auth0_controller.ex"), content)
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

  defp get_app_module_name(app_path) do
    mix_file = Path.join(app_path, "mix.exs")
    content = File.read!(mix_file)

    # Match `mod: {YourAppName.Application, _}`
    case Regex.run(~r/mod:\s*\{\s*([A-Za-z0-9_.]+)\s*,/, content) do
      [_, app_module] -> app_module
      _ -> raise "Could not detect app module name"
    end
  end

  defp render_template(template_path, assigns) do
    template = File.read!(template_path)
    EEx.eval_string(template, assigns)
  end
end
