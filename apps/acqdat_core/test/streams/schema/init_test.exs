defmodule AcqdatCore.Schema.Streams.InitTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.Streams.{Init, Action}

  describe "create changeset/2" do
    setup do
      [pipeline: insert(:pipeline)]
    end

    test "valid changeset", %{pipeline: pipeline} do
      params = %{
        pipeline_id: pipeline.id,
        name: "my-init",
        type: :init
      }

      %{valid?: validity} = Action.create_changeset(%Action{}, params)
      assert validity
    end

    test "only one init per pipeline", %{pipeline: pipeline} do
      params = %{
        pipeline_id: pipeline.id,
        name: "my-init",
        type: :init,
        config: %{foo: :bar}
      }

      {:ok, init} = Repo.insert(Action.create_changeset(%Action{}, params))
      assert init.config == %Init{}
      {:error, changeset} = Repo.insert(Action.create_changeset(%Action{}, params))

      assert %{
               type: ["pipeline already has `init` action"]
             } = errors_on(changeset)
    end
  end
end
