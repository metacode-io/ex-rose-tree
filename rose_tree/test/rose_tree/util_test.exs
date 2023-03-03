defmodule RoseTree.UtilTest do
  use ExUnit.Case

  alias RoseTree.Util

  doctest RoseTree.Util

  setup_all do
    # pass functions
    ok_tuple_fn = fn _ -> {:ok, :success_1} end
    result_fn = fn _ -> :success_2 end

    pass_fns = [ok_tuple_fn, result_fn]

    # fail functions
    error_tuple_fn = fn _ -> {:error, :failure} end
    error_fn = fn _ -> :error end
    nil_fn = fn _ -> nil end
    false_fn = fn _ -> false end

    fail_fns = [error_tuple_fn, error_fn, nil_fn, false_fn]

    all_fns = pass_fns ++ fail_fns

    # pass functions with opts
    ok_tuple_opts_fn = fn _, opts -> {:ok, {:success_1, opts}} end
    result_opts_fn = fn _, opts -> {:success_2, opts} end

    pass_opts_fns = [ok_tuple_opts_fn, result_opts_fn]

    # fail functions with opts
    error_tuple_opts_fn = fn _, _ -> {:error, :failure} end
    error_opts_fn = fn _, _ -> :error end
    nil_opts_fn = fn _, _ -> nil end
    false_opts_fn = fn _, _ -> false end

    fail_opts_fns = [error_tuple_opts_fn, error_opts_fn, nil_opts_fn, false_opts_fn]

    all_opts_fns = pass_opts_fns ++ fail_opts_fns

    # pass functions with args
    ok_tuple_args_fn = fn _, arg1, arg2 -> {:ok, {:success_1, arg1, arg2}} end
    result_args_fn = fn _, arg1, arg2 -> {:success_2, arg1, arg2} end

    pass_args_fns = [ok_tuple_args_fn, result_args_fn]

    # fail functions with args
    error_tuple_args_fn = fn _, _, _ -> {:error, :failure} end
    error_args_fn = fn _, _, _ -> :error end
    nil_args_fn = fn _, _, _ -> nil end
    false_args_fn = fn _, _, _ -> false end

    fail_args_fns = [error_tuple_args_fn, error_args_fn, nil_args_fn, false_args_fn]

    all_args_fns = pass_args_fns ++ fail_args_fns

    %{
      # regular fns
      pass_fns: pass_fns,
      fail_fns: fail_fns,
      all_fns: all_fns,
      ok_tuple_fn: ok_tuple_fn,
      result_fn: result_fn,
      error_tuple_fn: error_tuple_fn,
      error_fn: error_fn,
      nil_fn: nil_fn,
      false_fn: false_fn,
      # fns with keyword opts
      pass_opts_fns: pass_opts_fns,
      fail_opts_fns: fail_opts_fns,
      all_opts_fns: all_opts_fns,
      ok_tuple_opts_fn: ok_tuple_opts_fn,
      result_opts_fn: result_opts_fn,
      error_tuple_opts_fn: error_tuple_opts_fn,
      error_opts_fn: error_opts_fn,
      nil_opts_fn: nil_opts_fn,
      false_opts_fn: false_opts_fn,
      # fns with args list
      pass_args_fns: pass_args_fns,
      fail_args_fns: fail_args_fns,
      all_args_fns: all_args_fns,
      ok_tuple_args_fn: ok_tuple_args_fn,
      result_args_fn: result_args_fn,
      error_tuple_args_fn: error_tuple_args_fn,
      error_args_fn: error_args_fn,
      nil_args_fn: nil_args_fn,
      false_args_fn: false_args_fn
    }
  end

  describe "first_of/2" do
    test "should return nil if given an empty list for second parameter" do
      assert nil == Util.first_of(:anything, [])
    end

    test "should return nil if single function provided and returns {:error, error}", %{
      error_tuple_fn: function
    } do
      assert nil == Util.first_of(:anything, [function])
    end

    test "should return nil if single function provided and returns :error", %{error_fn: function} do
      assert nil == Util.first_of(:anything, [function])
    end

    test "should return nil if single function provided and returns nil", %{nil_fn: function} do
      assert nil == Util.first_of(:anything, [function])
    end

    test "should return nil if single function provided and returns false", %{false_fn: function} do
      assert nil == Util.first_of(:anything, [function])
    end

    test "should return nil if all provided functions fail", %{fail_fns: functions} do
      assert nil == Util.first_of(:anything, functions)
    end

    test "should return successful result if single function provided that returns {:ok, value}",
         %{ok_tuple_fn: function} do
      assert :success_1 == Util.first_of(:anything, [function])
    end

    test "should return successful result if single function provided that returns a truthy result",
         %{result_fn: function} do
      assert :success_2 == Util.first_of(:anything, [function])
    end

    test "should return a successful result for a randomly mixed list of functions as long as at least one passes",
         %{all_fns: functions} do
      result = Util.first_of(:anything, Enum.shuffle(functions))
      assert result in [:success_1, :success_2]
    end

    test "should return the first successful result", %{
      ok_tuple_fn: fn_1,
      result_fn: fn_2,
      error_fn: fn_3
    } do
      functions_1 = [fn_3, fn_1, fn_2]
      functions_2 = [fn_3, fn_2, fn_1]

      assert :success_1 == Util.first_of(:anything, functions_1)
      assert :success_2 == Util.first_of(:anything, functions_2)
    end
  end

  @options [option_1: true, option_2: 5]

  describe "first_of_with_opts/2" do
    test "should return nil if given an empty list for second parameter" do
      assert nil == Util.first_of_with_opts(:anything, [], @options)
    end

    test "should return nil if single function provided and returns {:error, error}", %{
      error_tuple_opts_fn: function
    } do
      assert nil == Util.first_of_with_opts(:anything, [function], @options)
    end

    test "should return nil if single function provided and returns :error", %{
      error_opts_fn: function
    } do
      assert nil == Util.first_of_with_opts(:anything, [function], @options)
    end

    test "should return nil if single function provided and returns nil", %{nil_opts_fn: function} do
      assert nil == Util.first_of_with_opts(:anything, [function], @options)
    end

    test "should return nil if single function provided and returns false", %{
      false_opts_fn: function
    } do
      assert nil == Util.first_of_with_opts(:anything, [function], @options)
    end

    test "should return nil if all provided functions fail", %{fail_opts_fns: functions} do
      assert nil == Util.first_of_with_opts(:anything, functions, @options)
    end

    test "should return successful result if single function provided that returns {:ok, value}",
         %{ok_tuple_opts_fn: function} do
      assert {:success_1, @options} == Util.first_of_with_opts(:anything, [function], @options)
    end

    test "should return successful result if single function provided that returns a truthy result",
         %{result_opts_fn: function} do
      assert {:success_2, @options} == Util.first_of_with_opts(:anything, [function], @options)
    end

    test "should return a successful result for a randomly mixed list of functions as long as at least one passes",
         %{all_opts_fns: functions} do
      assert {result, @options} =
               Util.first_of_with_opts(:anything, Enum.shuffle(functions), @options)

      assert result in [:success_1, :success_2]
    end

    test "should return the first successful result", %{
      ok_tuple_opts_fn: fn_1,
      result_opts_fn: fn_2,
      error_opts_fn: fn_3
    } do
      functions_1 = [fn_3, fn_1, fn_2]
      functions_2 = [fn_3, fn_2, fn_1]

      assert {:success_1, @options} == Util.first_of_with_opts(:anything, functions_1, @options)
      assert {:success_2, @options} == Util.first_of_with_opts(:anything, functions_2, @options)
    end
  end

  @arg1 true
  @arg2 5
  @args [@arg1, @arg2]

  describe "first_of_with_args/2" do
    test "should return nil if given an empty list for second parameter" do
      assert nil == Util.first_of_with_args(:anything, [], @args)
    end

    test "should return nil if single function provided and returns {:error, error}", %{
      error_tuple_args_fn: function
    } do
      assert nil == Util.first_of_with_args(:anything, [function], @args)
    end

    test "should return nil if single function provided and returns :error", %{
      error_args_fn: function
    } do
      assert nil == Util.first_of_with_args(:anything, [function], @args)
    end

    test "should return nil if single function provided and returns nil", %{nil_args_fn: function} do
      assert nil == Util.first_of_with_args(:anything, [function], @args)
    end

    test "should return nil if single function provided and returns false", %{
      false_args_fn: function
    } do
      assert nil == Util.first_of_with_args(:anything, [function], @args)
    end

    test "should return nil if all provided functions fail", %{fail_args_fns: functions} do
      assert nil == Util.first_of_with_args(:anything, functions, @args)
    end

    test "should return successful result if single function provided that returns {:ok, value}",
         %{ok_tuple_args_fn: function} do
      assert {:success_1, @arg1, @arg2} == Util.first_of_with_args(:anything, [function], @args)
    end

    test "should return successful result if single function provided that returns a truthy result",
         %{result_args_fn: function} do
      assert {:success_2, @arg1, @arg2} == Util.first_of_with_args(:anything, [function], @args)
    end

    test "should return a successful result for a randomly mixed list of functions as long as at least one passes",
         %{all_args_fns: functions} do
      assert {result, @arg1, @arg2} =
               Util.first_of_with_args(:anything, Enum.shuffle(functions), @args)

      assert result in [:success_1, :success_2]
    end

    test "should return the first successful result", %{
      ok_tuple_args_fn: fn_1,
      result_args_fn: fn_2,
      error_args_fn: fn_3
    } do
      functions_1 = [fn_3, fn_1, fn_2]
      functions_2 = [fn_3, fn_2, fn_1]

      assert {:success_1, @arg1, @arg2} == Util.first_of_with_args(:anything, functions_1, @args)
      assert {:success_2, @arg1, @arg2} == Util.first_of_with_args(:anything, functions_2, @args)
    end
  end

  describe "split_at/2" do
    test "should return two empty lists if given an empty list" do
      random_idx = Enum.random(1..100)
      assert {[], []} = Util.split_at([], random_idx)
    end

    test "should return two empty lists if given index greater than list count" do
      assert {[], []} = Util.split_at([1,2,3,4,5], 10)
    end

    test "should return two empty lists if given index equal to the list count" do
      assert {[], []} = Util.split_at([1,2,3,4,5], 5)
    end

    test "should return two empty lists if given a negative index" do
      random_idx = Enum.random(-1..-100)
      assert {[], []} = Util.split_at([1,2,3,4,5], random_idx)
    end

    test "should return empty list and in-order list when index = 0" do
      list = [1,2,3,4,5]
      assert{[], ^list} = Util.split_at(list, 0)
    end

    test "should return reverse partition and in-order partition when index is in-bounds and not at border" do
      list = [1,2,3,4,5,6,7,8,9,10]
      expected_1 = [5,4,3,2,1]
      expected_2 = [6,7,8,9,10]
      assert {^expected_1, ^expected_2} = Util.split_at(list, 5)
    end
  end
end
