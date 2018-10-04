defmodule Rumbl.UserTest do
  # these are pure (side-effect free), so we can run in parallal with async: true
  use Rumbl.ModelCase, async: true
  alias Rumbl.User

  @valid_attrs %{name: "A User", username: "eva", password: "secret"}
  @invalid_attrs %{}

  #test "changeset with valid attributes" do
    #changeset = User.changeset(%User{}, @valid_attrs)
    #assert changeset.valid?
  #end

  #test "changeset with invalid attributes" do
    #changeset = User.changeset(%User{}, @invalid_attrs)
    #refute changeset.valid?
  #end

  #test "changeset does not accept long usernames" do
    #attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))
    #changeset = User.registration_changeset(%User{}, attrs)
    #assert [ username: {"should be at most %{count} character(s)", [count: 30, validation: :length, max: 20]} ] in changeset.errors
  #end
end
