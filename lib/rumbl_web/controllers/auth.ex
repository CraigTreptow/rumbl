defmodule RumblWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias Rumbl.Accounts
  alias RumblWeb.Router.Helpers, as: Routes

  # compile time
  def init(opts), do: opts

  # run time
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    cond do
      user = conn.assigns[:current_user] ->
        conn

      user = user_id && Accounts.get_user(user_id) ->
        assign(conn, :current_user, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)

    # This last step is extremely important and it protects us from session fixation attacks.
    # It tells Plug to send the session cookie back to the client with a different identifier,
    # in case an attacker knew, by any chance, the previous one.
    |> configure_session(renew: true)
  end

  def login_by_email_and_pass(conn, email, given_pass) do
    case Accounts.authenticate_by_email_and_pass(email, given_pass) do
      {:ok, user} ->
        {:ok, login(conn, user)}
      {:error, :unauthorized} ->
        {:error, :unauthorized, conn}
      {:error, :not_found} ->
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    # This will drop the whole session at the end of the request.
    # If you want to keep the session around, you could also delete only the user ID information
    # by calling delete_session(conn, :user_id)

    configure_session(conn, drop: true)
  end
end
