## MCP

### What is it?

MCP is a Model Context Protocol. It's a way to tell LLM about available resources, tools, and prompts.
It's kinda like self-discoverable API. LLM can figure out what tools are available with MCP introspection and
then call these tools with MCP. Sales pitch is: MCP is usb type-c for GenAI.
Underlying transport is json-rpc.

See [mcp_tutorial.py](./mcp_tutorial.py) for an example of MCP server.

You implement a MCP server and point LLM (Claude Desktop or Codex) to it.

### Usage
Install Codex (coding agent from OpenAI):
```shell
brew install codex``
```

Add `~/.codex/config.toml`:
```toml
[mcp_servers.server-name]
command = "/Users/aershov/IdeaProjects/sog-python/venv/bin/python"
args = ["/Users/aershov/IdeaProjects/sog-python/mcp_tutorial.py"]
```

Codex will start MCP server given `command` & `args`.

Now you can start codex and ask it to use your tool. Here's a session transcript:
```text
user
frobnicate 8 and 9

codex
Running the frobnicator on 8 and 9 now.

tool running...
server-name.frobnicator({"x":8,"y":9})

tool success, duration: 5ms
server-name.frobnicator({"x":8,"y":9})

18

codex
Result: 18
```

Frobnicate was defined as `x + y + 1` so it works!
