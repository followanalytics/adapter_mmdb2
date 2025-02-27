defmodule Geolix.Adapter.MMDB2.Database do
  @moduledoc false

  alias Geolix.Adapter.MMDB2.Result
  alias Geolix.Adapter.MMDB2.Storage

  @doc """
  Performs a lookup in a loaded database.
  """
  @spec lookup(tuple, Keyword.t(), map) :: map | nil
  def lookup(ip, opts, %{id: id}) do
    case Storage.get(id) do
      {meta, tree, data} when is_map(meta) and is_binary(tree) and is_binary(data) ->
        lookup(ip, meta, tree, data, opts)

      _ ->
        nil
    end
  end

  defp lookup(ip, meta, tree, data, opts) do
    case MMDB2Decoder.lookup(ip, meta, tree, data) do
      {:ok, result} when is_map(result) ->
        result_as = Keyword.get(opts, :as, :struct)

        result
        |> Map.put(:ip_address, ip)
        |> maybe_to_struct(result_as, meta, opts)

      _ ->
        nil
    end
  end

  defp maybe_to_struct(result, :raw, _, _), do: result

  defp maybe_to_struct(result, :struct, %{database_type: type}, opts) do
    locale = Keyword.get(opts, :locale, :en)

    Result.to_struct(type, result, locale)
  end
end
