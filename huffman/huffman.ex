defmodule Huffman do

  def sample do
    'the quick brown fox jumps over the lazy dog
    this is a sample text that we will use when we build
    up a table we will only handle lower case letters and
    no punctuation symbols the frequency will of course not
    represent english but it is probably not that far off'
  end

  def text() do
    'this is something that we should encode'
  end

  def test do
    sample = sample()
    tree = tree(sample)
    encode = encode_table(tree)
    decode = decode_table(tree)
    text = text()
    seq = encode(text, encode)
    decode(seq, decode)
  end

  def tree(sample) do
    freq = freq(sample)
    huffman(freq)
  end

  def huffman([]), do: nil
  def huffman([root]), do: root
  def huffman([{c1, f1} | freq]) do
    {{c2, f2}, rest} = List.pop_at(freq, 0)
    freq =
      [{{c1, c2}, f1 + f2} | rest]
      |> List.keysort(1)

    huffman(freq)
  end

  def encode_table({tree, _}) do
    encode_table(tree, [])
  end

  def encode_table({left, right}, path) do
    encode_table(left, [0 | path])
    ++ encode_table(right, [1 | path])
  end
  def encode_table(char, path), do: [{char, path}]

  def decode_table({tree, _}) do
    decode_table(tree, [])
  end

  def decode_table({left, right}, path) do
    decode_table(left, [0 | path])
    ++ decode_table(right, [1 | path])
  end
  def decode_table(char, path), do: [{char, Enum.reverse(path)}]

  def encode(text, table) do
    encode(text, table, [])
  end
  def encode([], _, bit_list), do: List.flatten(bit_list) |> Enum.reverse()
  def encode([char | rest], table, bit_list) do
    {_, bits} = List.keyfind(table, char, 0)
    encode(rest, table, [bits | bit_list])
  end

  def decode([], _), do: []
  def decode(seq, table) do
    decode(seq, table, [])
  end
  def decode([], table, text), do: Enum.reverse(text)
  def decode(seq, table, text) do
    {char, rest} = decode_char(seq, 1, table)
    decode(rest, table, [char | text])
  end

  def decode_char(seq, n, table) do
    {bits, rest} = Enum.split(seq, n)
    IO.inspect(bits)
    case List.keyfind(table, bits, 1) do
      {char, _} -> {char, rest}
      nil -> decode_char(seq, n + 1, table)
    end
  end

  def freq(sample) do
    freq(sample, [])
  end
  def freq([], freq_list), do: List.keysort(freq_list, 1)
  def freq([char | rest], freq_list) do
    freq_list =
      case List.keyfind(freq_list, char, 0) do
        nil -> [{char, 1} | freq_list]
        {char, count} -> List.keyreplace(freq_list, char, 0, {char, count + 1})
      end
    freq(rest, freq_list)
  end

end
