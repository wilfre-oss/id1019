defmodule Seeds do
	require Integer
	def test() do
		maps = File.read!("samples.txt")
		{seeds, maps} = parse_samples(maps)
		maps = set_maps(maps)

		res = transform(seeds, maps)
		IO.inspect(res, charlists: :as_list)
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
		|>  Enum.map(&String.to_integer(&1))
	end

	def parse_maps(maps) do
		maps
		|>  Enum.map(fn map ->
			map
			|> String.split("\n")
			|> Enum.map(fn row ->
			  row
			  |> String.split()
			  |> Enum.map(&String.to_integer(&1))
			  |> parse_range()
			end)
		end)
	end

	def parse_range({x, s, e}), do: {x, (s..(s + e - 1))}
	def parse_range([x, s, e]), do: {x, (s..(s + e - 1))}

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
		{locations, _} = Enum.map_reduce(seeds, maps, fn seed, maps ->
			seed = Enum.reduce(maps, seed, fn map, s ->
				case Map.get(map, s) do
					nil -> s
					found -> found
				end
			end)
			{seed, maps}
		end)
		locations
	end


end
