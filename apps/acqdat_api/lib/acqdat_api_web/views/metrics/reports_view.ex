defmodule AcqdatApiWeb.Metrics.ReportsView do
  use AcqdatApiWeb, :view

  def render("report_data.json", %{reports: data}) do
    %{report: data}
  end

  def render("headers_data.json", %{headers: data}) do
    %{headers: data}
  end
end
