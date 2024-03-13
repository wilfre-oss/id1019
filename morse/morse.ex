defmodule MorseCode do

  # The codes that you should decode:

  def base, do: '.- .-.. .-.. ..-- -.-- --- ..- .-. ..-- -... .- ... . ..-- .- .-. . ..-- -... . .-.. --- -. --. ..-- - --- ..-- ..- ...'

  def rolled, do: '.... - - .--. ... ---... .----- .----- .-- .-- .-- .-.-.- -.-- --- ..- - ..- -... . .-.-.- -.-. --- -- .----- .-- .- - -.-. .... ..--.. ...- .----. -.. .--.-- ..... .---- .-- ....- .-- ----. .--.-- ..... --... --. .--.-- ..... ---.. -.-. .--.-- ..... .----'

  # The decoding tree.
  #
  # The tree has the structure  {:node, char, long, short} | :nil
  #

  def tree do
    {:node, :na,
      {:node, 116,
        {:node, 109,
          {:node, 111,
            {:node, :na, {:node, 48, nil, nil}, {:node, 57, nil, nil}},
            {:node, :na, nil, {:node, 56, nil, {:node, 58, nil, nil}}}},
          {:node, 103,
            {:node, 113, nil, nil},
            {:node, 122,
              {:node, :na, {:node, 44, nil, nil}, nil},
              {:node, 55, nil, nil}}}},
        {:node, 110,
          {:node, 107, {:node, 121, nil, nil}, {:node, 99, nil, nil}},
          {:node, 100,
            {:node, 120, nil, nil},
            {:node, 98, nil, {:node, 54, {:node, 45, nil, nil}, nil}}}}},
      {:node, 101,
        {:node, 97,
          {:node, 119,
            {:node, 106,
              {:node, 49, {:node, 47, nil, nil}, {:node, 61, nil, nil}},
              nil},
            {:node, 112,
              {:node, :na, {:node, 37, nil, nil}, {:node, 64, nil, nil}},
              nil}},
          {:node, 114,
            {:node, :na, nil, {:node, :na, {:node, 46, nil, nil}, nil}},
            {:node, 108, nil, nil}}},
        {:node, 105,
          {:node, 117,
            {:node, 32,
              {:node, 50, nil, nil},
              {:node, :na, nil, {:node, 63, nil, nil}}},
            {:node, 102, nil, nil}},
          {:node, 115,
            {:node, 118, {:node, 51, nil, nil}, nil},
            {:node, 104, {:node, 52, nil, nil}, {:node, 53, nil, nil}}}}}}
  end

  def decode(code, tree) do
    decode(code, tree, tree, [])
  end
  def decode([], _tree, _pos, acc), do: Enum.reverse(acc)
  def decode(code, tree, pos, acc) do
    {:node, char, long, short} = pos
    case code do
      [?. | rest] -> decode(rest, tree, short, acc)
      [?- | rest] -> decode(rest, tree, long, acc)
      [?\s | rest] -> decode(rest, tree, tree, [char | acc])
    end
  end

  def encoding_table(tree) do
    encoding_table(tree, [], Map.new())
  end
  def encoding_table({:node, char, nil, nil}, acc, map), do: Map.put(map, char, acc)
  def encoding_table({:node, char, long, nil}, acc, map), do: encoding_table(long, [?- | acc], Map.put(map, char, acc))
  def encoding_table({:node, char, nil, short}, acc, map), do: encoding_table(short, [?. | acc], Map.put(map, char, acc))
  def encoding_table({:node, char, long, short}, acc, map) do
    map = Map.put(map, char, acc)
    map = encoding_table(long, [?- |acc], map)
    encoding_table(short, [?. | acc], map)
  end

  def encode_table(tree) do
    encode_table(tree, [], Map.new())
  end
  def encode_table(:nil, code, map), do: map
  def encode_table({:node, :na, long, short}, code, map) do
    map = encoding_table(long, [?- | code], map)
    encoding_table(short, [?. | code], map)
  end
  def encode_table({:node, char, long, short}, code, map) do
    map = Map.put(map, char, Enum.reverse(code))
    map = encoding_table(long, [?- | code], map)
    encoding_table(short, [?. | code], map)
  end

  def encode(text, table) do
    encode(text, table, [])
  end
  defp encode([char], table, acc) do
    [Map.get(table, char) | acc]
    |> List.flatten()
    |> Enum.reverse()
  end
  defp encode([?\s | rest], table, acc), do: encode(rest, table, [[?\s] | acc])
  defp encode([char | rest], table, acc) do
    case Map.get(table, char) do
      nil-> [?? | acc]
      found -> encode(rest, table, [[found | [?\s]] | acc])
    end
  end

  def test() do
    code = base()
    tree = tree()
    text = decode(code, tree)
    table = encoding_table(tree)
    encode(text, table)
  end

end
