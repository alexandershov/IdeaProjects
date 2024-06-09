defmodule ThamesWeb.GPTController do
  use ThamesWeb, :controller

  def chat(conn, params) do
    answer = if params["query"] do
         response = Req.post!("https://api.openai.com/v1/chat/completions",
                              json: %{model: "gpt-4o",
                                      messages: [%{role: "user", content: params["query"]}]},
                              auth: {:bearer, System.get_env("OPENAI_API_KEY")})
         List.first(response.body["choices"])["message"]["content"]
    else
      ""
    end
    render(conn, :chat, answer: answer, query: params["query"], layout: false)
  end
end
