defmodule Rec do
require Integer

	def even([]), do: []
	def even([head | tail]) when Integer.is_even(head) do
		[head | even(tail)]
	end
	def even([_ | tail]), do: even(tail)

	def odd([]), do: []
	def odd([head | tail]) when Integer.is_odd(head), do: [head | odd(tail)]
	def odd([_ | tail]), do: odd(tail)

	def inc([], _), do: []
	def inc([head | tail], i), do: [head + i | inc(tail, i)]

	def dec([], _), do: []
	def dec([head | tail], i), do: [head - i | dec(tail, i)]

	def mul([], _), do: []
	def mul([head | tail], i), do: [head * i | mul(tail, i)]

	def div([], _), do: []
	def div([head | tail], i), do: [Kernel.div(head, i) | Rec.div(tail, i)]

	def rem([], _), do: []
	def rem([head | tail], i), do: [Kernel.rem(head, i) | Rec.rem(tail, i)]

	def length([]), do: 0
	def length([_ | tail]), do: Rec.length(tail) + 1

	def sum([]), do: 0
	def sum([head | tail]), do: head + sum(tail)

	def prod([]), do: 1
	def prod([head | tail]), do: head * prod(tail)

end
