defmodule Color do

  def convert(d, m) do
    f = d / m
    a = f * 4
    x = trunc(a)
    y = trunc(255 * (a - x))

    case x do
      0 -> {:rgb, y, 0, y}
      1 -> {:rgb, 255 - y, 0, 255}
      2 -> {:rgb, 0, y, 255}
      3 -> {:rgb, y, 255, 255 - y}
      4 -> {:rgb, 255, 255 - y, 0}
    end
  end

end
