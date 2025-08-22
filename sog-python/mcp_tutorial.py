from mcp.server.fastmcp import FastMCP

mcp = FastMCP("frobnicator")


@mcp.tool()
def frobnicator(x: int, y: int) -> int:
    return x + y + 1


if __name__ == '__main__':
    # there are different transports for MCP
    # * stdio runs a process and MCP client communicates with its stdin & stdou
    # * HTTP + sse: hacky attempt to implement bi-directional stream (you use sse for reads)
    #   and do HTTP requests on another endpoint for writes
    # * Streamable HTTP: another attempt to implement bi-directional stream
    mcp.run(transport="stdio")
