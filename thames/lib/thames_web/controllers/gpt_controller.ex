defmodule ThamesWeb.GPTController do
  use ThamesWeb, :controller

  def chat(conn, _params) do
    render(conn, :chat, layout: false)
  end
end
