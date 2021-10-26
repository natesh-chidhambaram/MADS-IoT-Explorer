defmodule AcqdatCore.Reports.Model.Template do
  import Ecto.Query
  alias AcqdatCore.Repo
  alias AcqdatCore.Reports.Schema.Template

  def get_all() do
    from(template in Template)
    |> Repo.all()
  end
end
