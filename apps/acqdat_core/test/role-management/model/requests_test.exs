defmodule AcqdatCore.Model.RoleManagement.RequestsTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.Requests, as: RequestsModel
  alias AcqdatCore.Schema.RoleManagement.Requests

  describe "create/1" do
    test "creates a request with supplied params" do
      params = %{
        "first_name" => "Arthur",
        "last_name" => "Dent",
        "email" => "arthurdent@siriuscyber.com",
        "phone_number" => "2267709",
        "org_name" => "Sirius Cybernetics",
        "org_url" => "siriuscyber@mads.com"
      }

      assert {:ok, _} = RequestsModel.create(params)
    end

    test "fails if params missing", context do
      params = %{
        "first_name" => "Arthur",
        "last_name" => "Dent",
        "email" => "arthurdent@siriuscyber.com",
        "org_name" => "Sirius Cybernetics",
        "org_url" => "siriuscyber@mads.com"
      }

      assert {:error, _} = RequestsModel.create(params)
    end
  end

  describe "delete/1" do
    test "deletes a particular request record" do
      params = %{
        "first_name" => "Arthur",
        "last_name" => "Dent",
        "email" => "arthurdent@siriuscyber.com",
        "phone_number" => "2267709",
        "org_name" => "Sirius Cybernetics",
        "org_url" => "siriuscyber@mads.com"
      }

      assert {:ok, request} = RequestsModel.create(params)

      result = hd(RequestsModel.get_all(%{page_size: 10, page_number: 1}).entries)
      assert not is_nil(result)

      {:ok, result} = RequestsModel.delete(request.id)
      assert result
      result = RequestsModel.get_all(%{page_size: 10, page_number: 1})
      assert result.total_entries == 0
    end
  end

  describe "get_all" do
    test "returns requests data" do
      params = %{
        "first_name" => "Arthur",
        "last_name" => "Dent",
        "email" => "arthurdent@siriuscyber.com",
        "phone_number" => "2267709",
        "org_name" => "Sirius Cybernetics",
        "org_url" => "siriuscyber@mads.com"
      }

      assert {:ok, request} = RequestsModel.create(params)

      params = %{page_size: 10, page_number: 1}
      result = RequestsModel.get_all(params)

      assert not is_nil(result)
      assert result.total_entries == 1
    end

    test "returns error not found, if teams are not present" do
      params = %{page_size: 10, page_number: 1}
      result = RequestsModel.get_all(params)

      assert result.entries == []
      assert result.total_entries == 0
    end
  end

  describe "update/2" do
    test "updates an request with supplied params" do
      params = %{
        "first_name" => "Arthur",
        "last_name" => "Dent",
        "email" => "arthurdent@siriuscyber.com",
        "phone_number" => "2267709",
        "org_name" => "Sirius Cybernetics",
        "org_url" => "siriuscyber@mads.com"
      }

      assert {:ok, request} = RequestsModel.create(params)

      params = %{
        "first_name" => "Ford",
        "last_name" => "Prefect",
        "email" => "fordprefect@siriuscyber.com",
        "phone_number" => "2267709",
        "org_name" => "Sirius Cybernetics",
        "org_url" => "siriuscyber@mads.com"
      }

      assert {:ok, new_request} = RequestsModel.update(request, params)
      assert Map.fetch(new_request, :first_name) == {:ok, "Ford"}
      assert Map.fetch(new_request, :last_name) == {:ok, "Prefect"}
    end

    test "fails if request is not present" do
      params = %{
        "first_name" => "Arthur",
        "last_name" => "Dent",
        "email" => "arthurdent@siriuscyber.com",
        "phone_number" => "2267709",
        "org_name" => "Sirius Cybernetics",
        "org_url" => "siriuscyber@mads.com"
      }

      assert {:ok, request} = RequestsModel.create(params)

      request = %Requests{
        id: -1,
        first_name: "Ford",
        last_name: "Prefect",
        email: "fordprefect@siriuscyber.com",
        phone_number: "2267709",
        org_name: "Sirius Cybernetics",
        org_url: "siriuscyber@mads.com"
      }

      assert {:error, _} = RequestsModel.update(request, params)
    end
  end

  describe "get/1" do
    test "returns a particular request record" do
      params = %{
        "first_name" => "Arthur",
        "last_name" => "Dent",
        "email" => "arthurdent@siriuscyber.com",
        "phone_number" => "2267709",
        "org_name" => "Sirius Cybernetics",
        "org_url" => "siriuscyber@mads.com"
      }

      assert {:ok, request} = RequestsModel.create(params)

      {:ok, result} = RequestsModel.get(request.id)
      assert not is_nil(result)
      assert result.id == request.id
    end

    test "returns error not found, if setting is not present" do
      assert {:error, "not found"} = RequestsModel.get(-1)
    end
  end
end
