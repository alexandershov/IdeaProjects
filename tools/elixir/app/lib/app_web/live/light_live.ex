defmodule AppWeb.LightLive do
    use AppWeb, :live_view

    # mount/3 is called to initialize the state of liveview process
    # state is stored socket
    def mount(_params, _session, socket) do
        # we can update state with assign
        socket = assign(socket, :brightness, 10)
        {:ok, socket}
    end

    # render/1 is called to, ahem, render state of the liveview process
    def render(assigns) do
        # phx-click events are sent to handle_event/3
        ~H"""
        <h1>Front Porch Light</h1>
        <%= @brightness %>%
        <button phx-click="down">Down</button>
        <button phx-click="up">Up</button>
        """
    end

    # Phoenix sends events (e.g. defined with phx-click) to this function
    # when we change state, then Phoenix rerenders changed parts of the page
    def handle_event("up", _, socket) do
        brightness = socket.assigns.brightness + 10
        socket = assign(socket, :brightness, brightness)
        {:noreply, socket}
    end

    def handle_event("down", _, socket) do
        # we can use lambda to update a value
        socket = update(socket, :brightness, fn b -> b - 10 end)
        {:noreply, socket}
    end
end