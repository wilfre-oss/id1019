defmodule Ranges do

	def empty(), do: []

	def range(from, to) do
		[{from, to}]
	end

	def union(a, b) do
		u  = a ++ b

		Enum.sort(u, fn {a_start, _}, {b_start, _} ->
			a_start <= b_start
		end)
		|>  Enum.reduce([], fn {first, last}, acc ->
				case acc do
					[] -> [{first, last}]
					[{prev_first, prev_last} | rest] ->
						cond do
						  prev_last >= first ->
							[{prev_first, max(prev_last, last)} | rest]
						  (prev_last + 1) == first ->
							[{prev_first, last} | rest]
						  true ->
							[{first, last} | acc]
						end
				end
			end)
	end

	def intersection(a, b) do
		Enum.reduce(a, [], fn {a_start, a_end}, acc ->
			Enum.reduce(b, acc, fn {b_start, b_end}, acc ->
				cond do
					b_start > a_end -> acc
					b_end < a_start -> acc
					true ->
						[{max(a_start, b_start), min(a_end, b_end)} | acc]
				end
			end)
		end)
	end




	def difference(a, b) do
		difference(a, b, [])
	end

	def difference([], _, acc), do: acc
	def difference([a | rest], b, acc) do
		d = diff([a], b)
		difference(rest, b, union(d, acc))
	end

	def diff(acc, []), do: acc
	def diff([{a_start, a_end}], [b_head | b_tail]) do
		{b_start, b_end} = b_head
		cond do
			b_start > a_end -> diff([{a_start, a_end}], b_tail)
			b_end < a_start -> diff([{a_start, a_end}], b_tail)
			b_start > a_start and b_end < a_end ->
				union(range(a_start, b_start - 1), range(b_end + 1, a_end))
				|> diff(b_tail)
			b_start > a_start ->
				range(a_start, b_start - 1)
				|> diff(b_tail)
			b_end < a_end ->
				range(b_end + 1, a_end)
				|> diff(b_tail)
			true -> []
		end
	end

	defp merge_adjacent_ranges([]), do: []
	defp merge_adjacent_ranges([range]), do: [range]
	defp merge_adjacent_ranges([{start1, end1}, {start2, end2} | tail]) when end1 + 1 >= start2 do
		merge_adjacent_ranges([{start1, max(end1, end2)} | tail])
	end
	defp merge_adjacent_ranges([range | tail]) do
		[range | merge_adjacent_ranges(tail)]
	end

	def add(a, n) do
	  	Enum.map(a, fn {first, last} ->
			{first + n, last + n}
	  	end)
	end

	def range_min() do

	end


end
