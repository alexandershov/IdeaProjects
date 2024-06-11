defmodule ThamesWeb.GPTLive do
  use Phoenix.LiveView
  import ThamesWeb.CoreComponents

  def mount(_params, _session, socket) do
    {:ok, socket |> assign(:form, to_form(%{"query" => ""})) |> assign(:conversation, [])}
  end

  def handle_event("send", params, socket) do
    query = params["query"]
    conversation = socket.assigns.conversation ++ [%{"content" => query, "role" => "user"}]
    IO.inspect(conversation)

    response =
      Req.post!("https://api.openai.com/v1/chat/completions",
        json: %{model: "gpt-4o", messages: conversation},
        auth: {:bearer, System.get_env("OPENAI_API_KEY")}
      )

    answer = List.first(response.body["choices"])["message"]["content"]
    conversation = conversation ++ [%{"role" => "assistant", "content" => answer}]
    {:noreply, socket |> assign(:conversation, conversation)}
  end
end
