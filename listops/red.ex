defmodule Red do
	import Rec

	def map(list, fun), do: map(list, fun, [])
	def map([], _fun, acc), do: Enum.reverse(acc)
	def map([head | tail], fun, acc), do: map(tail, fun, [fun.(head) | acc])

	def reduce([], acc, _fun), do: acc
	def reduce([head | tail], acc, fun), do: reduce(tail, fun.(head, acc), fun)

	def reducer([], i, _fun), do: i
	def reducer([head | tail], i, fun), do:  fun.(head, reduce(tail, i, fun))

	def filter(list, fun), do: filter(list, fun, [])
	def filter([], _fun, acc), do: Enum.reverse(acc)
	def filter([head | tail], fun, acc) do
		case fun.(head) do
			true -> filter(tail, fun, [head | acc])
			false -> filter(tail, fun, acc)
		end
	end

	def filterl(list, fun), do: filterl(list, fun, [])
	def filterl([], _fun, acc), do: Enum.reverse(acc)
	def filterl([head | tail], fun, acc) when fun.(head) do
		filterl(tail, fun, [head | acc])
	end
	def filterl([head | tail], fun, acc), do: filterl(tail, fun, acc)

	def test(list, x) do
		list |>
			odd() 	|>
			mul(x)	|>
			sum()
	end
end
