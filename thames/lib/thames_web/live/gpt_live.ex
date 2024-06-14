# TODO: clean up code
defmodule ThamesWeb.GPTLive do
  use Phoenix.LiveView
  import ThamesWeb.CoreComponents
  require JSON
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
        json: %{model: "gpt-4o", messages: conversation, stream: true},
        auth: {:bearer, System.get_env("OPENAI_API_KEY")}
      )

    split = String.split(response.body, "\n\n")
    jsons = split
      |> Enum.map(fn (s) -> String.slice(s, 6, String.length(s)) end)
      |> Enum.map(&JSON.decode/1)
    words = for {:ok, item} <- jsons, do: List.first(item["choices"])["delta"]["content"]
    answer = Enum.join(words, "")

    # TODO: add tests
    conversation = conversation ++ [%{"role" => "assistant", "content" => answer}]
    {:noreply, socket |> assign(:conversation, conversation) |> assign(:form, make_form(""))}
  end
end
