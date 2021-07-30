defmodule AcqdatCore.Model.RoleManagement.UserSettingTest do
  use ExUnit.Case, async: true
  use AcqdatCore.DataCase
  use AcqdatApiWeb.ConnCase
  import AcqdatCore.Support.Factory
  alias AcqdatCore.Model.RoleManagement.UserSetting, as: UserSettingModel
  alias AcqdatCore.Schema.RoleManagement.UserSetting

  describe "create/1" do
    test "creates a user_setting with supplied params" do
      user_credentials = insert(:user_credentials)

      params = %{
        user_credentials_id: user_credentials.id,
        visual_settings: %{
          recently_visited_apps: ["data_cruncher", "support", "settings", "dashboard"],
          taskbar_pos: "left",
          desktop_wallpaper: "default.png"
        },
        data_settings: %{
          latitude: 11.2,
          longitude: 20.22
        }
      }

      assert {:ok, _usersetting} = UserSettingModel.create(params)
    end

    test "fails if user_id is not present" do
      params = %{
        visual_settings: %{
          recently_visited_apps: ["data_cruncher", "support", "settings", "dashboard"],
          taskbar_pos: "left",
          desktop_wallpaper: "default.png"
        },
        data_settings: %{
          latitude: 11.2,
          longitude: 20.22
        }
      }

      assert {:error, changeset} = UserSettingModel.create(params)
      assert %{user_credentials_id: ["can't be blank"]} == errors_on(changeset)
    end
  end

  describe "update" do
    test "updates successfully for valid params" do
      user_credentials = insert(:user_credentials)

      params = %{
        user_credentials_id: user_credentials.id,
        visual_settings: %{
          recently_visited_apps: ["data_cruncher", "support", "settings", "dashboard"],
          taskbar_pos: "left",
          desktop_wallpaper: "default.png"
        },
        data_settings: %{
          latitude: 11.2,
          longitude: 20.22
        }
      }

      assert {:ok, usersetting} = UserSettingModel.create(params)

      new_params = %{
        data_settings: %{
          latitude: 14.2,
          longitude: 21.22
        }
      }

      assert {:ok, new_user_setting} = UserSettingModel.update(usersetting, new_params)
      assert new_user_setting.data_settings.latitude == 14.2
      assert new_user_setting.data_settings.longitude == 21.22
    end

    test "raises errors for bad input" do
      assert {:error, _} =
               UserSettingModel.update(%UserSetting{id: -1, user_credentials_id: -1}, %{})
    end
  end

  describe "get/1" do
    test "returns a particular user_setting" do
      user_setting = insert(:user_setting)

      {:ok, result} = UserSettingModel.get(user_setting.id)
      assert not is_nil(result)
      assert result.id == user_setting.id
    end

    test "returns error not found, if setting is not present" do
      {:error, result} = UserSettingModel.get(-1)
      assert result == "not found"
    end
  end

  describe "delete/1" do
    test "deletes successfully for valid values" do
      user_credentials = insert(:user_credentials)

      params = %{
        user_credentials_id: user_credentials.id,
        visual_settings: %{
          recently_visited_apps: ["data_cruncher", "support", "settings", "dashboard"],
          taskbar_pos: "left",
          desktop_wallpaper: "default.png"
        },
        data_settings: %{
          latitude: 11.2,
          longitude: 20.22
        }
      }

      assert {:ok, setting} = UserSettingModel.create(params)

      assert {:ok, _} = UserSettingModel.get(setting.id)

      assert {:ok, _} = UserSettingModel.delete(setting.id)

      assert {:error, _} = UserSettingModel.get(setting.id)
    end

    test "raises error for invalid values" do
      assert {:error, _} = UserSettingModel.delete(-1)
    end
  end

  describe "fetch_user_credentials" do
    test "succeeds for valid input" do
      user_credentials = insert(:user_credentials)

      params = %{
        user_credentials_id: user_credentials.id,
        visual_settings: %{
          recently_visited_apps: ["data_cruncher", "support", "settings", "dashboard"],
          taskbar_pos: "left",
          desktop_wallpaper: "default.png"
        },
        data_settings: %{
          latitude: 11.2,
          longitude: 20.22
        }
      }

      assert {:ok, setting} = UserSettingModel.create(params)

      result = UserSettingModel.fetch_user_credentials()
      assert false
    end
  end
end
