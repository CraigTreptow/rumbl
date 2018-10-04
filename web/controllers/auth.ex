defmodule Rumbl.Auth do
  import Phoenix.Controller
  import Plug.Conn

  alias Rumbl.Router.Helpers

  # compile time
  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  # run time
  def call(conn, repo) do
    user_id = get_session(conn, :user_id)

    cond do
      user = conn.assigns[:current_user] ->
        conn
      user = user_id && repo.get(Rumbl.User, user_id) ->
        assign(conn, :current_user, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)

    # The last step is extremely important and it protects us from session fixation attacks.
    # It tells Plug to send the session cookie back to the client with a different identifier,
    # in case an attacker knew, by any chance, the previous one.
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  def login_by_username_and_pass(conn, username, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Rumbl.User, username: username)
    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
        |> put_flash(:error, "You must be logged in to access that page")
        |> redirect(to: Helpers.page_path(conn, :index))
        |> halt()
    end
  end
end
