defmodule AcqdatCore.ReleaseTasks do
  def seed do
    :ok = Application.load(:acqdat_core)

    [:postgrex, :ecto, :logger, :ecto_sql]
    |> Enum.each(&Application.ensure_all_started/1)

    AcqdatCore.Repo.start_link

    path = Application.app_dir(:acqdat_core, "priv/repo/seeds.exs")

    if File.regular?(path) do
      Code.require_file(path)
    end

    :init.stop()
  end
end
