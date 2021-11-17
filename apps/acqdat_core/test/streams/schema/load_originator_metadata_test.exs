defmodule AcqdatCore.Schema.Streams.LoadOriginatorMetadataTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  import AcqdatCore.Support.Factory

  alias AcqdatCore.Schema.Streams.Action

  describe "create changeset/2" do
    setup do
      [pipeline: insert(:pipeline)]
    end

    test "valid changeset", %{pipeline: pipeline} do
      params = %{
        pipeline_id: pipeline.id,
        name: "my-load-originator-metadata",
        type: :originator_metadata,
        config: %{destination: "foo.bar"}
      }

      %{valid?: validity} = Action.create_changeset(%Action{}, params)

      assert validity
    end

    test "invalid destination", %{pipeline: pipeline} do
      params = %{
        pipeline_id: pipeline.id,
        name: "my-load-originator-metadata",
        type: :originator_metadata,
        config: %{
          destination: "f oo-bar"
        }
      }

      %{valid?: validity} = changeset = Action.create_changeset(%Action{}, params)
      refute validity

      assert %{
               config: %{destination: ["has invalid format"]}
             } = poly_embed_errors_on(changeset)
    end

    test "missing destination", %{pipeline: pipeline} do
      params = %{
        pipeline_id: pipeline.id,
        name: "my-load-originator-metadata",
        type: :originator_metadata,
        config: %{}
      }

      %{valid?: validity} = changeset = Action.create_changeset(%Action{}, params)
      refute validity

      assert %{
               config: %{destination: ["can't be blank"]}
             } = poly_embed_errors_on(changeset)
    end
  end

  describe "update changeset/2" do
    setup do
      params = %{
        type: :originator_metadata,
        pipeline_id: insert(:pipeline).id,
        name: "my-lom",
        config: %{
          destination: "foo.bar"
        }
      }

      {:ok, action} = Repo.insert(Action.create_changeset(%Action{}, params))
      [action: action]
    end

    test "valid changeset", %{action: action} do
      params = %{
        type: :foo,
        name: "null",
        config: %{
          destination: "foo.baz"
        }
      }

      %{valid?: validity} = Action.update_changeset(action, params)
      assert validity
    end

    test "invalid changeset", %{action: action} do
      params = %{
        config: %{
          destination: "foo baz"
        }
      }

      %{valid?: validity} = Action.update_changeset(action, params)
      refute validity
    end
  end
end
