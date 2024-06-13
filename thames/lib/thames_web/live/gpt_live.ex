# TODO: clean up code
defmodule ThamesWeb.GPTLive do
  use Phoenix.LiveView
  import ThamesWeb.CoreComponents
  require Logger

  def make_form(query) do
    to_form(%{"query" => query})
  end


  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:form, make_form("")) |> assign(:conversation, [])}
  end

  def handle_event("change", params, socket) do
    {:noreply, socket |> assign(:form, make_form(params["query"]))}
  end

  def handle_event("send", params, socket) do
    query = params["query"]

    # TODO: persist messages in a database
    conversation = socket.assigns.conversation ++ [%{"content" => query, "role" => "user"}]
    Logger.info("current conversation = #{inspect(conversation)}")

    # TODO: use streaming
    response =
      Req.post!("https://api.openai.com/v1/chat/completions",
        json: %{model: "gpt-4o", messages: conversation},
        auth: {:bearer, System.get_env("OPENAI_API_KEY")}
      )

    # TODO: add tests
    answer = List.first(response.body["choices"])["message"]["content"]
    conversation = conversation ++ [%{"role" => "assistant", "content" => answer}]
    {:noreply, socket |> assign(:conversation, conversation) |> assign(:form, make_form(""))}
  end
end
