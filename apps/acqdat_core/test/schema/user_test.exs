defmodule AcqdatCore.Schema.UserTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase

  alias AcqdatCore.Schema.User

  describe "changeset/2" do
    test "returns error changeset on empty params" do
      changeset = User.changeset(%User{}, %{})

      assert %{
               email: ["can't be blank"],
               first_name: ["can't be blank"],
               password: ["can't be blank"],
               password_confirmation: ["can't be blank"]
             } == errors_on(changeset)
    end

    test "returns error if password and confirm do not match" do
      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "tony@starkindustries.com",
        password: "marvel_connect",
        password_confirmation: "marvel"
      }

      changeset = User.changeset(%User{}, params)

      assert %{
               password_confirmation: ["does not match confirmation"]
             } == errors_on(changeset)
    end

    test "returns error if email regex not matched" do
      params = %{
        first_name: "Tony",
        last_name: "Stark",
        email: "tonystarkindustries.com",
        password: "marvel_connect",
        password_confirmation: "marvel_connect"
      }

      changeset = User.changeset(%User{}, params)

      assert %{
               email: ["has invalid format"]
             } == errors_on(changeset)
    end
  end
end
