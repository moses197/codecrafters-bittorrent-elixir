defmodule Bittorrent.CLI do
  def main(argv) do
    case argv do
      ["decode" | [encoded_str | _]] ->
        decoded = Bencode.decode(encoded_str)
        IO.puts(Jason.encode!(decoded))
      [command | _] ->
        IO.puts("Unknown command: #{command}")
        System.halt(1)
      [] ->
        IO.puts("Usage: your_bittorrent.sh <command> <args>")
        System.halt(1)
    end
  end
end

defmodule Bencode do
  def decode(encoded_value) when is_binary(encoded_value) do
    case encoded_value do
      <<?i, rest::binary>> ->
        decode_integer(rest)
      _ ->
        decode_string(encoded_value)
    end
  end

  defp decode_integer(binary_data) do
    {integer_part, "e" <> _} = String.split_at(binary_data, -1)
    case Integer.parse(integer_part) do
      {int, ""} -> int
      :error -> "Invalid integer format"
    end
  end

  defp decode_string(binary_data) do
    {length_str, ":" <> rest} = String.split_at(binary_data, Enum.find_index(binary_data, fn char -> char == ?: end))
    {length, ""} = Integer.parse(length_str)
    String.slice(rest, 0, length)
  end

  # def decode(_), do: "Invalid encoded value: not binary"
end
