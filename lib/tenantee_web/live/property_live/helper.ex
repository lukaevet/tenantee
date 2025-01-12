defmodule TenanteeWeb.PropertyLive.Helper do
  @moduledoc """
  Helper functions for properties
  """
  alias Tenantee.Config
  alias Tenantee.Entity.Property
  import Phoenix.Component, only: [assign: 3]

  @doc """
  Check if the submit button should be disabled
  """
  @spec is_submit_disabled?(map()) :: boolean
  def is_submit_disabled?(assigns) do
    case Float.parse(assigns.price) do
      {price, ""} when price > 0 ->
        [
          assigns.name,
          assigns.address,
          assigns.price
        ]
        |> Enum.any?(&(String.length(&1) == 0)) or price <= 0

      _ ->
        true
    end
  end

  @doc """
  Assigns the default properties to the socket
  """
  @spec default(term) :: term
  def default(socket) do
    with currency <- Config.get(:currency, "") do
      socket
      |> assign(:name, "")
      |> assign(:address, "")
      |> assign(:description, "")
      |> assign(:price, "")
      |> assign(:currency, currency)
    end
  end

  @doc """
  Assigns the properties to the socket from the property
  """
  @spec default(term, map()) :: term
  def default(socket, %{"id" => id}) do
    with {:ok, property} <- Property.get(id),
         currency <- Config.get(:currency, "") do
      socket
      |> assign(:name, property.name)
      |> assign(:address, property.address)
      |> assign(:description, property.description)
      |> assign(:price, property.price.amount |> to_string())
      |> assign(:id, id)
      |> assign(:currency, currency)
    end
  end

  @doc """
  Handles the price that we pass to the socket
  """
  @spec handle_price(String.t() | float(), String.t() | atom()) :: Money.t()
  def handle_price(price, currency) when is_bitstring(price) do
    Decimal.new(price)
    |> Decimal.to_float()
    |> handle_price(currency)
  end

  def handle_price(price, currency) when is_float(price) do
    Money.from_float(price, currency)
  end
end
