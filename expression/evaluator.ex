defmodule Evaluator do
	import Env

	@type literal() ::
	{:var, atom()} |
	{:num, number()} |
	{:q, number(), number()}

	@type expr() ::
	{:add, expr(), expr()} |
	{:sub, expr(), expr()} |
	{:div, expr(), expr()} |
	{:mul, expr(), expr()} |
	literal()



	def test() do
		map = Env.new(%{:x => 10})


		#e = {:mul, {:num, 2}, {:q, 3, 4}}
		#e = {:add, {:add, {:mul, {:num, 2}, {:var, :x}}, {:num, 3}}, {:q, 1,2}}
		#e = {:div, {:q, 1 , 2}, {:q, 3, 2}}

		e = {:sub,
			{:add,
			{:div,
			{:mul,
				{:num, 3},
				{:q, 3, 4}},
			{:q, 1, 2}},
			{:num, 3}},
			{:q, 5, 6}}


		eval(e, map)
	end

	def eval({:num, n}, _), do: {:num ,n}
	def eval({:q, n, m}, _), do: simplify({:q, n, m})
	def eval({:var, x}, map), do: Env.find(map, x)
	def eval({:add, e1, e2}, map) do
		add(eval(e1, map) , eval(e2, map))
	end
	def eval({:sub, e1 , e2}, map) do
		sub(eval(e1, map), eval(e2, map))
	end
	def eval({:mul, e1, e2}, map) do
		mul(eval(e1, map), eval(e2, map))
	end
	def eval({:div, e1, e2}, map) do
		eval_div(eval(e1, map), eval(e2, map))
	end


	def add({:num, n1}, {:num, n2}), do: {:num, n1 + n2}
	def add(e1 ,{:q, n, m}), do: eval_div(add(mul(e1 , {:num, m}), {:num, n}), {:num, m})
	def add({:q, n, m}, e1), do: eval_div(add(mul(e1 , {:num, m}), {:num, n}), {:num, m})

	def sub({:num, n1},  {:num, n2}), do: {:num, n1 - n2}
	def sub({:q, n, m}, e1), do: eval_div(sub(mul(e1 , {:num, m}), {:num, n}),{:num, m})
	def sub(e1 ,{:q, n, m}), do: eval_div(sub(mul(e1 , {:num, m}), {:num, n}),{:num, m})

	def eval_div({:num, n1}, {:num, n2}) when rem(n1, n2) == 0 do
		{:num, div(n1 , n2)}
	end
	def eval_div({:num, n1}, {:num, n2}), do: simplify({:q, n1, n2})
	def eval_div(e1, {:q, n, m}), do: eval_div(mul(e1, {:num, m}), {:num, n})
	def eval_div({:q, n, m}, e1), do: eval_div({:num, n}, mul(e1, {:num, m}))

	def mul({:num, n1}, {:num, n2}), do: {:num, n1 * n2}
	def mul(e1, {:q, n, m}), do: eval_div(mul(e1, {:num, n}), {:num, m})
	def mul({:q, n, m}, e1), do: eval_div(mul(e1, {:num, n}), {:num, m})

	def simplify({:q, n, m}) do
		gcd = Integer.gcd(n, m)
		{:q, div(n, gcd), div(m, gcd)}
	end

	def pprint({:q, n, m}), do: "#{n}/#{m}"
	def pprint({:num, n}), do: "#{n}"

end
