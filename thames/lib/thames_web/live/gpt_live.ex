# TODO: clean up code
defmodule ThamesWeb.GPTLive do
  use Phoenix.LiveView
  import ThamesWeb.CoreComponents

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:form, to_form(%{"query" => ""})) |> assign(:conversation, [])}
  end

  def handle_event("send", params, socket) do
    # TODO: clean form query
    query = params["query"]

    # TODO: persist messages in a database
    conversation = socket.assigns.conversation ++ [%{"content" => query, "role" => "user"}]
    IO.puts("current conversation = #{inspect(conversation)}")

    # TODO: use streaming
    response =
      Req.post!("https://api.openai.com/v1/chat/completions",
        json: %{model: "gpt-4o", messages: conversation},
        auth: {:bearer, System.get_env("OPENAI_API_KEY")}
      )

    # TODO: add tests
    answer = List.first(response.body["choices"])["message"]["content"]
    conversation = conversation ++ [%{"role" => "assistant", "content" => answer}]
    {:noreply, socket |> assign(:conversation, conversation)}
  end
end
