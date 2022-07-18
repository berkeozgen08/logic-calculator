defmodule LogicCalculator do
  @and_token "*"
  @or_token "+"
  @not_token "'"
  @notp_token "!"
  @open_token "("
  @close_token ")"

  def tokenize(str) when is_binary(str) do
    str
    |> String.trim()
    |> String.split(~r/ +/)
    |> Enum.join()
    |> String.replace("||", @or_token)
    |> String.replace("&&", @and_token)
    |> String.replace(
      ~r/(?<=[\w#{@close_token}#{@not_token}])([\w#{@open_token}#{@notp_token}])/,
      "#{@and_token}\\1"
    )
    |> IO.inspect()
    |> String.split("", trim: true)
  end

  def parse([head | tail], vars) when is_map(vars) do
    [
      case head do
        @and_token -> :and
        @or_token -> :or
        @open_token -> :open
        @close_token -> :close
        @not_token -> :not
        @notp_token -> :notp
        x -> vars[x]
      end
      | parse(tail, vars)
    ]
  end

  def parse([], _) do
    []
  end

  def evaluate(parsed, vals \\ [], ops \\ [])

  def evaluate(parsed, [head | tail], [:not | optail]) do
    evaluate(parsed, [not head | tail], optail)
  end

  def evaluate(parsed, vals, [:close, :open | tail]) do
    evaluate(parsed, vals, tail)
  end

  def evaluate(parsed, [head | tail], [op, :notp | optail])
      when op != :open do
    evaluate(parsed, [not head | tail], [op | optail])
  end

  def evaluate(parsed, [a, b | tail], [op, :and | optail])
      when op != :open and op != :notp do
    evaluate(parsed, [a and b | tail], [op | optail])
  end

  def evaluate(parsed, [a, b | tail], [op, :or | optail])
      when op != :open and op != :and and op != :notp do
    evaluate(parsed, [a or b | tail], [op | optail])
  end

  def evaluate(_, [head], [:noop]) do
    head
  end

  def evaluate([], vals, [op | tail]) do
    evaluate([], vals, [:noop, op | tail])
  end

  def evaluate([head | tail], vals, ops) do
    if is_boolean(head) do
      evaluate(tail, [head | vals], ops)
    else
      evaluate(tail, vals, [head | ops])
    end
  end

  def truth_table(expr) when is_binary(expr) do
    expr = tokenize(expr)

    symbols =
      expr
      |> Enum.filter(fn x -> String.match?(x, ~r/\w/) end)
      |> Enum.uniq()
      |> Enum.sort()

    for sym <- symbols do
      IO.write("#{sym} ")
    end

    IO.puts("| f")
    len = length(symbols)

    for _ <- 1..len do
      IO.write("--")
    end

    IO.puts("|---")

    for row <- 0..trunc(:math.pow(2, len) - 1) do
      chars =
        row
        |> Integer.digits(2)
        |> Enum.join()
        |> String.pad_leading(len, "0")
        |> String.split("", trim: true)

      chars |> Enum.join(" ") |> IO.write()
      IO.write(" | ")

      values =
        chars
        |> Enum.map(fn
          "0" -> false
          "1" -> true
        end)

      variables = Enum.zip(symbols, values) |> Enum.into(%{})

      result =
        expr
        |> parse(variables)
        |> evaluate()

      IO.puts(if result, do: 1, else: 0)

      result
    end
  end

  def test(expr, vars) when is_binary(expr) and is_map(vars) do
    expr
    |> tokenize()
    |> parse(vars)
    |> evaluate()
  end

  def test(expr, vars) when is_binary(expr) and is_list(vars) do
    expr = expr |> tokenize()

    expr
    |> parse(
      expr
      |> Enum.filter(fn x -> String.match?(x, ~r/\w/) end)
      |> Enum.uniq()
      |> Enum.sort()
      |> Enum.zip(vars)
      |> Enum.into(%{})
    )
    |> evaluate()
  end
end
