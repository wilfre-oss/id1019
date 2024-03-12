defmodule Memo do
	require Integer
	def test() do
		springs = "???.### 1,3"
		run(springs)
	end

	def bench(n) do
		#{:ok, file} = File.open("springs.dat", [:write, :list])
		seq = gen_seq(n)
		n = 1
		l = 5
		Enum.each(seq, fn spring ->
			{t, _} = :timer.tc( fn ->
				Enum.each(0..l, fn _ ->
					solutions(spring)
				end)
			end)
			:io.format("~6.w~12.1f\n", [n, t/l])
		end)
		#File.close(file)
	end

	def gen_seq(n) do
		springs = parse_springs("?.### 1,3")
		gen_seq(n, springs)

	end
	def gen_seq(1, springs), do: Enum.reverse(springs)
	def gen_seq(n, springs) do
		[head | _] = springs
		new_spring = extend_spring(head)
		gen_seq(n - 1,[new_spring | springs])
	end

	def extend_spring(spring) do
		[charlist | seq] = spring
		charlist = charlist ++  ~c"????.###"
		seq = [1,1,3] ++ seq
		[charlist | seq]
	end


	def run(springs) do
		desc = parse_springs(springs)
		total_solutions(desc)

	end

	def parse_springs([], acc), do: Enum.reverse(acc)
	def parse_springs([springs | rest], acc) do
		[status | damaged] = String.split(springs)
		status_charlist = String.to_charlist(status)
		damaged = String.split(Enum.at(damaged, 0), ",")
		damaged = Enum.map(damaged, fn i ->
			String.to_integer(i)
		end)
		parsed = [status_charlist | damaged]
		parse_springs(rest, [parsed | acc])
	end
	def parse_springs(springs) do
		springs = String.split(springs, ["\n", "\t"], trim: true)
		parse_springs(springs, [])
	end

	def is_desc_complete([[]]), do: true
	def is_desc_complete([[] | _]), do: false
	def is_desc_complete([status]) do
		case count_damaged(status) do
			{0, rest} -> is_desc_complete([rest])
			_ -> false
		end
	end
	def is_desc_complete([status | [dh | dt]]) do
		case count_damaged(status) do
			{^dh, rest} -> is_desc_complete([rest | dt])
			{0, rest} -> is_desc_complete([rest | [dh | dt]])
			_ -> false
		end
	end

	def count_damaged([], acc), do: {acc, []}
	def count_damaged([head | tail], acc) do
		case head do
			46 -> {acc, tail}
			63 -> {acc, tail}
			_ -> count_damaged(tail, acc + 1)
		end
	end
	def count_damaged(list), do: count_damaged(list, 0)

	def solutions(desc) do
		memory = Map.new()
		[status | damaged] = desc
		case is_desc_complete(desc) do
			true -> 1
			false ->
				{memo, count} = solve(status, damaged, [[]], memory)

				count
		end
	end

	def solve([], [], _acc, memo) do
		{memo, 1}
	end

	def solve([], _d_seq, _acc, memo) do
		{memo, 0}
	end

	def solve(_status, [], acc, memo) do

		case is_desc_complete(acc) do
			true -> {memo, 1}
			false -> {memo, 0}
		end
	end

	def solve([63 | st], d_seq, acc, memo) do

		[acc_status | acc_seq] = acc

		{d, a2} = update_d_seq(d_seq, [[46 | acc_status] | acc_seq])
		{memo, count2} = check(st, d, a2, memo)
		IO.inspect(memo)

		{d, a1} = update_d_seq(d_seq, [[35 | acc_status] | acc_seq])
		{memo, count1} = check(st, d, a1, memo)


		case is_desc_complete(a1) do
			true ->
				case is_desc_complete(a2) do
					true -> {memo, count1 + count2}
					false -> {memo, count1}
				end
			false ->
				case is_desc_complete(a2) do
					true -> {memo, count2}
					false -> {memo, 0}
				end
		end
	end

	def solve(status, d_seq, acc, memo) do

		[sh | st] = status
		[acc_status | acc_seq] = acc
		acc = [[sh | acc_status] | acc_seq]
		{d_seq, acc} = update_d_seq(d_seq, acc)

		{memo, count} = check(st, d_seq, acc, memo)

		case is_desc_complete(acc) do
			true -> {memo, count}
			false -> {memo, 0}
		end
	end

	def check(status, d_seq, acc, memo) do

		case Map.get(memo, {status, d_seq}) do
			nil ->
				{memo, count} = solve(status, d_seq, acc, memo)
				{Map.put(memo, {status, d_seq}, count), count}
			found -> {memo, found}
		end
	end

	def update_d_seq(d_seq, acc) do
		[dh | dt] = d_seq
		[status | desc] = acc
		case count_damaged(status) do
			{^dh, _} -> {dt, [status | [dh | desc]]}
			_ -> {d_seq, acc}
		end
	end

	def total_solutions(springs), do: total_solutions(springs, 0)
	def total_solutions([], acc), do: acc
	def total_solutions([current | rest], acc) do
		total_solutions(rest, acc + solutions(current))
	end

end
