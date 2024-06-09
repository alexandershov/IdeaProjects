defmodule ThamesWeb.GPTHTML do
  @moduledoc """
  This module contains pages rendered by GPTController.

  See the `gpt_html` directory for all templates available.
  """
  use ThamesWeb, :html

  embed_templates "gpt_html/*"
end
