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

    pid = spawn(fn -> reader(conversation) end)

    socket =
      assign(socket, :conversation, conversation ++ [%{"role" => "assistant", "content" => ""}])

    {:noreply,
     socket
     |> assign(:form, make_form(""))
     |> start_async(:stream_reply, fn -> stream_reply(pid) end)}

    # TODO: add tests
  end

  def reader(conversation) do
    response =
      Req.post!("https://api.openai.com/v1/chat/completions",
        json: %{model: "gpt-4o", messages: conversation, stream: true},
        auth: {:bearer, System.get_env("OPENAI_API_KEY")},
        into: :self
      )

    reader_loop(response)
  end

  def reader_loop(response) do
    receive do
      {:next, pid} ->
        to_send = receive do {_, {:data, data}} -> data end
        send(pid, {:your_next, to_send})
    end

    reader_loop(response)
  end

  def stream_reply(pid) do
    send(pid, {:next, self()})

    receive do
      {:your_next, message} ->
        split = String.split(message, "\n\n")
        jsons =
          split
          |> Enum.map(fn s -> String.slice(s, 6, String.length(s)) end)
          |> Enum.map(&JSON.decode/1)

        words = for {:ok, item} <- jsons, do: List.first(item["choices"])["delta"]["content"]
        token = Enum.join(words, "")
        {token, pid}
    end
  end

  @spec handle_async(:stream_reply, {:ok, {nil, any()}}, any()) :: {:noreply, any()}
  def handle_async(:stream_reply, {:ok, {token, pid}}, socket) do
    if token == nil do
      {:noreply, socket}
    else
      done = Enum.slice(socket.assigns.conversation, 0, length(socket.assigns.conversation) - 1)
      current = List.last(socket.assigns.conversation)
      new = %{"role" => current["role"], "content" => current["content"] <> token}

      {:noreply,
       socket
       |> assign(:conversation, done ++ [new])
       |> start_async(:stream_reply, fn -> stream_reply(pid) end)}
    end
  end
end
