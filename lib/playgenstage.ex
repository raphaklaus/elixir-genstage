defmodule Playgenstage do
  @moduledoc """
  Documentation for Playgenstage.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Playgenstage.hello()
      :world

  """
  def add_items(items) do
    Playgenstage.Producer.add_item(items)
  end
end
