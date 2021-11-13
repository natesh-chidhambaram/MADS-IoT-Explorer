defmodule AcqdatCore.Schema.Streams.ActionTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.Streams.Action

  describe "changeset/2" do
    setup do
      [pipeline: insert(:pipeline)]
    end

    test "valid changeset", %{pipeline: pipeline} do
      params = %{
        pipeline_id: pipeline.id,
        type: :init
      }

      %{valid?: validity} = Action.create_changeset(%Action{}, params)
      assert validity
    end

    test "invalid if params empty" do
      %{valid?: validity} = changeset = Action.create_changeset(%Action{}, %{})
      refute validity

      assert %{
               type: ["can't be blank"],
               pipeline_id: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "invalid if type is wrong", %{pipeline: pipeline} do
      %{valid?: validity} =
        changeset = Action.create_changeset(%Action{}, %{type: :fake, pipeline_id: pipeline.id})

      refute validity

      assert %{
               type: ["is invalid"]
             } = errors_on(changeset)
    end

    test "error if pipeline assoc constraint not satisfied" do
      params = %{
        pipeline_id: UUID.uuid4(),
        type: :init,
        config: %{}
      }

      changeset = Action.create_changeset(%Action{}, params)

      {:error, result_changeset} = Repo.insert(changeset)
      assert %{pipeline: ["does not exist"]} == errors_on(result_changeset)
    end
  end
end
