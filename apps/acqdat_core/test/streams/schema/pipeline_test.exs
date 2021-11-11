defmodule AcqdatCore.Schema.Streams.PipelineTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.Streams.Pipeline

  describe "changeset/2" do
    setup do
      [project: insert(:project)]
    end

    test "returns a valid changeset", context do
      %{project: project} =
        context

      params = %{
        name: "Root pipeline",
        project_id: project.id,
        description: "for the project"
      }

      %{valid?: validity} = Pipeline.changeset(%Pipeline{}, params)
      assert validity
    end

    test "returns invalid if params empty" do
      %{valid?: validity} = changeset = Pipeline.changeset(%Pipeline{}, %{})
      refute validity

      assert %{
               name: ["can't be blank"],
             } = errors_on(changeset)
    end

    test "returns error if project assoc constraint not satisfied" do
      params = %{
        name: "Root pipeline",
        project_id: 0,
      }

      changeset = Pipeline.changeset(%Pipeline{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{project: ["does not exist"]} == errors_on(result_changeset)
    end
  end
end
