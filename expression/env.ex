defmodule Env do

	def new(), do: []

	def add(id, str, env) do
		case List.keyfind(env, id) do
			nil -> [{id, str} | env]
			{^id, ^str} -> env
			{^id, _} -> List.keyreplace(env, id, 0, {id, str})
		end
	end

	def lookup(id, env) do
		List.keyfind(env, id, 0)
	end

	def remove(ids, env) do
		new_env = env
		Enum.each(ids, fn id ->
			new_env = List.keydelete(new_env, id, 0)
		end)
		new_env
	end

end
