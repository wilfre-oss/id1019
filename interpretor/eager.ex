defmodule Eager do
	require Env
	require Prgm

	def test() do

		seq = [{:match, {:var, :x}, {:atm,:a}},
				{:match, {:var, :y}, {:cons, {:var, :x}, {:atm, :b}}},
				{:match, {:cons, :ignore, {:var, :z}}, {:var, :y}},
				{:var, :y}]

		eval_seq(seq, [])
	end


	def eval_expr({:atm, id}, _), do: {:ok, id}
	def eval_expr({:var, id}, env) do
		case Env.lookup(id, env) do
			nil -> :error
			{_, str} -> {:ok, str}
		end
	end
	def eval_expr({:cons, e1, e2}, env) do
		case eval_expr(e1, env) do
			:error -> :error
			{:ok, hs} ->
				case eval_expr(e2, env) do
					:error -> :error
					{:ok, ts} -> {:ok, {hs, ts}}
				end
		end
	end
	def eval_expr({:apply, expr, args}, env) do
		case eval_expr(expr, env) do
			:error -> :error
			{:ok, {:closure, par, seq, scope}} ->
				case eval_args(args, env) do
					:error -> :error
					{:ok, strs} ->
						env = Env.args(par, strs, scope)
						eval_seq(seq, env)
				end
		end
	end
	def eval_expr({:fun, fun}, _env) do
		{par, seq} = apply(Prgm, fun, [])
		{:ok, {:closure, par, seq, Env.new()}}
	end
	def eval_expr({:case, expr, cls}, env) do
		case eval_expr(expr, env) do
			:error -> :error
			{:ok, str} -> eval_cls(cls, str, env)
		end
	end
	def eval_expr({:lambda, par, free, seq}, env) do
		case Env.closure(free, env) do
			:error -> :error
			closure -> {:ok, closure}
		end
	end

	def eval_match(:ignore, _, env), do: {:ok, env}
	def eval_match({:atm, id}, id, env), do: {:ok, env}
	def eval_match({:var, id}, str, env) do
		case Env.lookup(id, env) do
			nil -> {:ok, Env.add(id, str, env)}
			{_, ^str} -> {:ok, Env.add(id, str, env)}
			_other -> :fail
		end
	end
	def eval_match({:cons, e1, e2}, {v1, v2}, env) do
		case eval_match(e1, v1, env) do
			:fail -> :fail
			{:ok, new_env} -> eval_match(e2, v2, new_env)
		end
	end
	def eval_match(_,_,_), do: :fail

	def eval_scope(expr, env) do
		Env.remove(extract_vars(expr), env)
	end

	def eval_seq([exp], env) do
		eval_expr(exp, env)
	end
	def eval_seq([{:match, e1, e2} | tail], env) do
		case eval_expr(e2, env) do
			:error -> :error
			{:ok, str} ->
				scope = eval_scope(e1, env)
				case eval_match(e1, str, scope) do
					:fail -> :error
					{:ok, env} -> eval_seq(tail, env)
				end
		end
	end

	def eval_cls([], _,_), do: :error
	def eval_cls([{:clause, ptr, seq} | cls], str, env) do
		scope = eval_scope(ptr, env)
		case eval_match(ptr, str, scope) do
			:fail -> eval_cls(cls, str, env)
			{:ok, env} -> eval_seq(seq, env)
		end
	end

	def eval_args([], _env) do {:ok, []} end
	def eval_args([arg | args], env) do
		case eval_expr(arg, env) do
			:error -> :error
			{:ok, str} ->
				case eval_args(args, env) do
				:error -> :error
				{:ok, strs} ->
				{:ok, [str | strs]}
			end
		end
	end

	def extract_vars({:var, id}), do: [id]
	def extract_vars({:atm, _}), do: []
	def extract_vars(:ignore), do: []
	def extract_vars({:cons, e1, e2}) do
		extract_vars(e1) ++ extract_vars(e2)
	end

end
