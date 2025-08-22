from mcp.server.fastmcp import FastMCP

mcp = FastMCP("frobnicator")


# with this tool you can ask LLM to "frobnicate 9 & 18"
@mcp.tool()
def frobnicator(x: int, y: int) -> int:
    """Frobnicate two number x & y using a very complicated algorithm"""
    return x + y + 1


if __name__ == '__main__':
    # there are different transports for MCP
    # * stdio runs a process and MCP client communicates with its stdin & stdou
    # * HTTP + sse: hacky attempt to implement bi-directional stream (you use sse for reads)
    #   and do HTTP requests on another endpoint for writes
    # * Streamable HTTP: another attempt to implement bi-directional stream
    mcp.run(transport="stdio")
