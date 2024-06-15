# TODO: clean up code
defmodule ThamesWeb.GPTLive do
  require Ecto.Query
  alias Thames.Message
  alias Thames.Chat
  alias Thames.Repo
  use Phoenix.LiveView
  import ThamesWeb.CoreComponents
  require JSON
  require Logger
  require UUID

  def make_form(query) do
    to_form(%{"query" => query})
  end

  def mount(params, _session, socket) do
    if not Map.has_key?(params, "chat_id") do
      chat_id = UUID.uuid4()
      changeset = Chat.changeset(%Chat{}, %{chat_id: chat_id})
      {:ok, _} = Repo.insert(changeset)
      {:ok, socket |> Phoenix.LiveView.push_navigate(to: "/gpt/?chat_id=#{chat_id}")}
    else
      chat_id = params["chat_id"]
      query = Ecto.Query.from m in Message,
        where: m.chat_id == ^chat_id,
        order_by: m.id
      messages = Repo.all(query)
      conversation = for m <- messages, do: %{"role" => m.role, "content" => m.content}
      {:ok,
       socket
       |> assign(:form, make_form(""))
       |> assign(:conversation, conversation)
       |> assign(:chat_id, chat_id)}
    end
  end

  def handle_event("change", params, socket) do
    {:noreply, socket |> assign(:form, make_form(params["query"]))}
  end

  def handle_event("send", params, socket) do
    query = params["query"]

    changeset =
      Message.changeset(%Message{}, %{
        content: query,
        role: "user",
        chat_id: socket.assigns.chat_id,
        order: 0
      })
    Logger.info("changeset is valid #{changeset.valid?}")
    {:ok, _} = Repo.insert(changeset)
    conversation = socket.assigns.conversation ++ [%{"content" => query, "role" => "user"}]
    Logger.info("current conversation = #{inspect(conversation)}")

    pid = spawn(fn -> reader(conversation) end)
    changeset = Message.changeset(%Message{}, %{
      content: "x",
      role: "assistant",
      chat_id: socket.assigns.chat_id,
      order: 0
    })
    {:ok, res} = Repo.insert(changeset)
    Logger.info("insert result = #{inspect(res)}")
    socket =
      assign(socket, :conversation, conversation ++ [%{"role" => "assistant", "content" => ""}])

    {:noreply,
     socket
     |> assign(:form, make_form(""))
     |> start_async(:stream_reply, fn -> stream_reply(pid, res.id) end)}

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
        to_send =
          receive do
            {_, {:data, data}} -> data
          end

        send(pid, {:your_next, to_send})
    end

    reader_loop(response)
  end

  def stream_reply(pid, message_id) do
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
        {token, pid, message_id}
    end
  end

  @spec handle_async(:stream_reply, {:ok, {nil, any()}}, any()) :: {:noreply, any()}
  def handle_async(:stream_reply, {:ok, {token, pid, message_id}}, socket) do
    if token == nil do
      Logger.info("finished reply")
      {:noreply, socket}
    else
      done = Enum.slice(socket.assigns.conversation, 0, length(socket.assigns.conversation) - 1)
      current = List.last(socket.assigns.conversation)
      new = %{"role" => current["role"], "content" => current["content"] <> token}
      message = Repo.get!(Message, message_id)
      Logger.info("message = #{inspect(message)}")
      changeset = Message.changeset(message, %{content: new["content"]})
      {:ok, _} = Repo.update(changeset)
      {:noreply,
       socket
       |> assign(:conversation, done ++ [new])
       |> start_async(:stream_reply, fn -> stream_reply(pid, message_id) end)}
    end
  end
end
