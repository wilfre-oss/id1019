defmodule Bench do
require Integer
require Huffman

  def read(file) do
    {:ok, file} = File.open(file, [:read, :utf8])
    binary = IO.read(file, :all)
    File.close(file)

    case :unicode.characters_to_list(binary, :utf8) do
      {:incomplete, list, _} -> list
      list -> list
    end
  end

  def bench(l) do
    {:ok, file} = File.open("huffman.dat", [:write, :list])

    seq =
      Enum.to_list(2..512)
      |> Enum.filter(&Integer.is_even/1)

    Enum.each(seq, fn n ->
      bench(l, n, file)
    end)
    File.close(file)
  end

  defp bench(l, n, file) do
    {te, td} = bench(l, n)
    :io.format(file, "~w\t~.2f\t~.2f\n", [n, te/l, td/l])
  end

  defp bench(l, n) do
    sample = read("loremipsum.txt")
    {text, _} =
      read("text.txt")
      |> Enum.split(n)

    encode_table =
      Huffman.tree(sample)
      |> Huffman.encode_table()
    decode_table =
      Huffman.tree(sample)
      |> Huffman.decode_table()

    {encode, _} =
      :timer.tc(fn ->
        Enum.each(1..l, fn _ ->
          Huffman.encode(text, encode_table)
        end)
      end)

    seq = Huffman.encode(text, encode_table)
    {decode, _} =
      :timer.tc(fn ->
        Enum.each(1..l, fn _ ->
          Huffman.decode(seq, decode_table)
        end)
      end)

    {encode, decode}
  end

  def bench_encode(l) do
    {:ok, file} = File.open("encode.dat", [:write, :list])

    seq =
      Enum.to_list(2..512)
      |> Enum.filter(&Integer.is_even/1)

    Enum.each(seq, fn n ->
      bench_encode(l, n, file)
    end)
    File.close(file)
  end

  defp bench_encode(l, n, file) do
    te = bench_encode(l, n)
    :io.format(file, "~w\t~.2f\n", [n, te/l])
  end

  defp bench_encode(l, n) do
    sample = read("loremipsum.txt")
    {text, _} =
      read("text.txt")
      |> Enum.split(n)

    encode_table =
      Huffman.tree(sample)
      |> Huffman.encode_table()

    {encode, _} =
      :timer.tc(fn ->
        Enum.each(1..l, fn _ ->
          Huffman.encode(text, encode_table)
        end)
      end)
    encode
  end

end
