defmodule AcqdatApi.Metrics.Reports do
  alias AcqdatApi.Utils.Helper
  alias AcqdatCore.Metrics.Reports
  alias AcqdatCore.Schema.Metrics.Meta
  alias AcqdatCore.Model.EntityManagement.Organisation
  alias AcqdatCore.Notifications.Service.Notification
  alias Elixlsx.{Workbook, Sheet}

  def fetch_metrics_headers() do
    apps = Map.from_struct(Meta) |> Map.drop([:id])

    Enum.reduce(apps, %{}, fn {key, _value}, acc ->
      module = key |> Atom.to_string() |> Macro.camelize()

      sections =
        ["AcqdatCore.Schema.Metrics.#{module}"]
        |> Module.safe_concat()
        |> Map.from_struct()
        |> Map.drop([:id])
        |> Map.keys()

      Map.put(acc, key, sections)
    end)
  end

  def get_presigned_url(name) do
    file_path = "uploads/org_metrics/reports/#{name}.xlsx"

    {:ok, url} =
      ExAws.Config.new(:s3, region: System.get_env("AWS_REGION"))
      |> ExAws.S3.presigned_url(:get, System.get_env("AWS_S3_BUCKET_FILE"), file_path)

    url
  end

  def gen_report(%{
        "org_id" => org_id,
        "start_date" => start_date,
        "end_date" => end_date,
        "type" => type,
        "app" => app,
        "entity" => entity,
        "group_action" => group_action
      }) do
    start_date = Helper.string_to_date(start_date)
    end_date = Helper.string_to_date(end_date)
    Reports.range_report(org_id, start_date, end_date, type, app, entity, group_action)
  end

  def gen_report(%{
        "org_id" => org_id,
        "start_date" => start_date,
        "end_date" => end_date,
        "type" => type,
        "group_action" => group_action
      }) do
    start_date = Helper.string_to_date(start_date)
    end_date = Helper.string_to_date(end_date)
    Reports.range_report(org_id, start_date, end_date, type, group_action)
  end

  def download_report(
        %{
          "org_id" => org_id,
          "start_date" => start_date,
          "end_date" => end_date,
          "filter_metadata" => filter_metadata
        },
        %{id: user_id}
      ) do
    {:ok, workbook} = {:ok, %Workbook{}}

    res = Reports.fetch_data(org_id, start_date, end_date, filter_metadata)
    {:ok, org} = Organisation.get(org_id)
    sheet_name = "report_#{org.name}:#{user_id}_#{start_date}_to_#{end_date}"
    sheet_name = String.slice(sheet_name, 0..30)

    path =
      gen_xls_sheet(res.rows, res.columns, sheet_name, workbook)
      |> write_to_xls(sheet_name)

    upload_to_s3(path, sheet_name)

    delete_temp_file(path)

    payload = %{
      name: "Report of #{org.name} from #{start_date}_to_#{end_date}: #{Timex.now()}",
      org_uuid: org.uuid,
      payload: %{data: sheet_name},
      user_id: user_id,
      app: "tenant_mgmt",
      content_type: "file"
    }

    Notification.process(payload)
  end

  def gen_xls_sheet(data, headers, sheet_name, workbook) do
    sheet = %Sheet{name: sheet_name, rows: [headers] ++ data}

    Workbook.append_sheet(workbook, sheet)
  end

  def write_to_xls(workbook, name) do
    path =
      Application.app_dir(
        :acqdat_api,
        "priv/static/reports/metrics/#{name}.xlsx"
      )

    workbook |> Elixlsx.write_to(path)
    path
  end

  def upload_to_s3(path, sheet_name) do
    s3_path = "/uploads/org_metrics/reports/#{sheet_name}.xlsx"

    path
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(System.get_env("AWS_S3_BUCKET_FILE"), s3_path,
      opts: [{:content_type, "application/vnd.ms-excel"}]
    )
    |> ExAws.request(region: System.get_env("AWS_REGION"))
  end

  def delete_temp_file(path) do
    File.rm(path)
  end
end
