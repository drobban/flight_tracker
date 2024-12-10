defmodule FlightTrackerWeb.AircraftLive.FormComponent do
  use FlightTrackerWeb, :live_component

  alias FlightTracker.Skymap

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage aircraft records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="aircraft-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input
          field={@form[:type]}
          type="select"
          label="Type"
          prompt="Choose a value"
          options={Ecto.Enum.values(FlightTracker.Skymap.Aircraft, :type)}
        />
        <.input field={@form[:pos_lat]} type="number" label="Pos lat" step="any" />
        <.input field={@form[:pos_long]} type="number" label="Pos long" step="any" />
        <.input field={@form[:destination_lat]} type="number" label="Destination lat" step="any" />
        <.input field={@form[:destination_long]} type="number" label="Destination long" step="any" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          prompt="Choose a value"
          options={Ecto.Enum.values(FlightTracker.Skymap.Aircraft, :status)}
        />
        <.input field={@form[:speed_kmh]} type="number" label="Speed kmh" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Aircraft</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{aircraft: aircraft} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Skymap.change_aircraft(aircraft))
     end)}
  end

  @impl true
  def handle_event("validate", %{"aircraft" => aircraft_params}, socket) do
    changeset = Skymap.change_aircraft(socket.assigns.aircraft, aircraft_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"aircraft" => aircraft_params}, socket) do
    save_aircraft(socket, socket.assigns.action, aircraft_params)
  end

  defp save_aircraft(socket, :edit, aircraft_params) do
    case Skymap.update_aircraft(socket.assigns.aircraft, aircraft_params) do
      {:ok, aircraft} ->
        notify_parent({:saved, aircraft})

        {:noreply,
         socket
         |> put_flash(:info, "Aircraft updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_aircraft(socket, :new, aircraft_params) do
    case Skymap.create_aircraft(aircraft_params) do
      {:ok, aircraft} ->
        notify_parent({:saved, aircraft})

        {:noreply,
         socket
         |> put_flash(:info, "Aircraft created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
