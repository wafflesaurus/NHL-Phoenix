defmodule NhlPhoenix.PageController do
  use NhlPhoenix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
