defmodule Rag do
	require Integer
	import Ranges
	def test() do
		maps = File.read!("day5.csv")
		{seeds, maps} = parse_samples(maps)

		transform(seeds, maps)
	end

	def parse_samples(maps) do
		[seeds | maps] = String.split(maps, "\n\n", trim: true)

		seeds = parse_seeds(seeds)
		maps = parse_maps(maps)

		{seeds, maps}
	end

	def parse_seeds(seeds) do
		seeds
		|>  String.split(" ",trim: true)
		|>  Enum.drop(1)
		|>  Enum.map(&String.to_integer(&1))
		|>  Enum.chunk_every(2)
		|>  Enum.map(fn [s, e] -> range(s, s + e - 1) end)
	end

	def parse_maps(maps) do
		maps
		|>  Enum.map(fn map ->
			map
			|> String.split("\n", trim: true)
			|> Enum.drop(1)
			|> Enum.map(fn row ->
			  row
			  |> String.split()
			  |> Enum.map(&String.to_integer(&1))
			  |> parse_range()
			end)
		end)
	end

	def parse_range({x, s, e}), do: {x - s, range(s, s + e - 1)}
	def parse_range([x, s, e]), do: {x - s, range(s, s + e - 1)}

	def set_maps(maps) do
		maps
		|> Enum.map(&set_map(&1, %{}))
	end

	def set_map([head | tail], acc) do
		{x, range} = head
		{_, new_map} = Enum.reduce(range, {x, acc}, fn key, acc ->
			{value, map} = acc
			map = Map.put(map, key, value)
			{value + 1, map}
		end)
		set_map(tail, new_map)
	end

	def set_map([], acc) do
		acc
	end

	def transform(seeds, maps) do

		transform(seeds, maps, [])
	end

	def transform([], _, acc), do: Enum.reverse(acc)
	def transform([seed | rest], maps, acc) do
		locations = trans_maps(seed, maps)
		transform(rest, maps, [locations | acc])
	end

	def trans_maps(values, []), do: values
	def trans_maps(values, [map | rest]) do
		values = trans_seed(values, map, [])
		trans_maps(values, rest)
	end

	def trans_seed([], _, acc), do: acc
	def trans_seed(rest, [], acc), do: union(rest, acc)
	def trans_seed(seed, [m_head | m_rest], acc) do
		{n, m_range} = m_head

		case intersection(seed, m_range) do
			[] -> trans_seed(seed, m_rest, acc)
			inter ->
				acc = union(add(inter, n), acc)
				diff = difference(seed, inter)
				trans_seed(diff, m_rest, acc)
		end
	end

end
