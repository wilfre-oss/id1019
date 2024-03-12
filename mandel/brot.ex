defmodule Brot do
	import Cmplx

	def test(i, _, _, i), do: 0
	def test(i, z, c, m) do
		cond do
			Cmplx.abs(z) > 2 -> i
			true ->
				z_next = add(Cmplx.sqr(z), c)
				test(i + 1, z_next, c, m)
		end
	end

	def mandelbrot(c, m) do
		z0 = Cmplx.new(0, 0)
		i = 0
		test(i, z0, c, m)
	end

end
