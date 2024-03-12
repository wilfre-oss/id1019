defmodule Env do

	def new(), do: []

	def add(id, str, env) do
		case List.keyfind(env, id, 0) do
			nil -> [{id, str} | env]
			{^id, ^str} -> env
			{^id, _} -> List.keyreplace(env, id, 0, {id, str})
		end
	end

	def lookup(id, env) do
		List.keyfind(env, id, 0)
	end

	def remove(ids, env) do
		Enum.filter(env, fn {id, _} ->
			id not in ids
		end)
	end

	def closure([], _env), do: []
	def closure([id | free], env) do
		{_, str} = lookup(id, env)
		add(id, str, closure(free, env))
	end

	def args([],[], closure), do: closure
	def args([id | par], [str | strs], closure) do
		add(id, str, args(par, strs, closure))
	end


end
