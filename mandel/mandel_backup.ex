defmodule Mandel do
  require Cmplx
  require Brot
  require Color

  def demo() do
    #small(-0.7664, 0.0963, -0.7623)
    #medium(-1.8, 0.1, -1.1)
    #medium(0.25, 0.15, 0.6)
    big(-0.7664, 0.0963, -0.7623)
    #huge(0.25, 0.15, 0.6)
    #huge(-1.8, 0.1, -1.1)
  end

  def small(x0, y0, xn) do
    width = 960
    height = 540
    depth = 250
    k = (xn - x0) / width
    image = Mandel.mandelbrot(width, height, x0, y0, k, depth)
    PPM.write("small.ppm", image)
  end

  def medium(x0, y0, xn) do
    width = 1280
    height = 720
    depth = 64
    k = (xn - x0) / width
    image = Mandel.mandelbrot(width, height, x0, y0, k, depth)
    PPM.write("medium.ppm", image)
  end

  def big(x0, y0, xn) do
    width = 3840
    height = 2160
    depth = 250
    k = (xn - x0) / width
    image = Mandel.mandelbrot(width, height, x0, y0, k, depth)
    PPM.write("big.ppm", image)
  end

  def huge(x0, y0, xn) do
    width = 7680
    height = 4320
    depth = 64
    k = (xn - x0) / width
    image = Mandel.mandelbrot(width, height, x0, y0, k, depth)
    PPM.write("huge.ppm", image)
  end

  def mandelbrot(width, height, x, y, k, depth) do
    trans = fn w, h ->
      Cmplx.new(x + k * (w - 1), y - k * (h - 1))
    end

    rows(width, height, trans, depth, [])
  end

  defp rows(_, 0, _, _, acc), do: Enum.reverse(acc)
  defp rows(width, height, trans, depth, acc) do

    row = row(width, height, trans, depth, [])
    rows(width, height-1, trans, depth, [row | acc])

  end

  defp row(0, _, _, _, acc), do: acc
  defp row(w, h, trans, depth, acc) do
    pixel =
      trans.(w, h)
      |> Brot.mandelbrot(depth)
      |> Color.convert(depth)

    row(w-1, h, trans, depth, [pixel | acc])
  end
end
