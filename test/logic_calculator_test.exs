defmodule LogicCalculatorTest do
  use ExUnit.Case
  doctest LogicCalculator

  test "abc + c'a * b + b'ac" do
    assert LogicCalculator.truth_table("abc + c'a * b + b'ac")
    == [false, false, false, false, false, true, true, true]
  end

  test "a(b + c'a)'" do
    assert LogicCalculator.truth_table("a(b + c'a)'")
    == [false, false, false, false, false, true, false, false]
  end

  test "a(((b)(c) + c'(a))')'" do
    assert LogicCalculator.truth_table("a(((b)(c) + c'(a))')'")
    == [false, false, false, false, true, false, true, true]
  end

  test "a && bc||!c& &a&&b || !bac" do
    assert LogicCalculator.truth_table("a && bc||!c& &a&&b || !bac")
    == LogicCalculator.truth_table("abc + c'a * b + b'ac")
  end

  test "a!(!((b)(c) + !c(a)))" do
    assert LogicCalculator.truth_table("a(((b)(c) + c'(a))')'")
    == LogicCalculator.truth_table("a!(!((b)(c) + !c(a)))")
  end
end
