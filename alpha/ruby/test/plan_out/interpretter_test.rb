require 'test/unit'
require 'json'
require_relative '../test_helper'
require_relative '../../lib/plan_out/interpreter'

module PlanOut
  class MyTest < Minitest::Test
    def setup
      # Do nothing
      @compiled = JSON.parse('
{"op":"seq","seq":[{"op":"set","var":"group_size","value":{"choices":{"op":"array","values":[1,10]},"unit":{"op":"get","var":"userid"},"op":"uniformChoice"}},{"op":"set","var":"specific_goal","value":{"p":0.8,"unit":{"op":"get","var":"userid"},"op":"bernoulliTrial"}},{"op":"cond","cond":[{"if":{"op":"get","var":"specific_goal"},"then":{"op":"seq","seq":[{"op":"set","var":"ratings_per_user_goal","value":{"choices":{"op":"array","values":[8,16,32,64]},"unit":{"op":"get","var":"userid"},"op":"uniformChoice"}},{"op":"set","var":"ratings_goal","value":{"op":"product","values":[{"op":"get","var":"group_size"},{"op":"get","var":"ratings_per_user_goal"}]}}]}}]}]}
  ')
      @interpreter_salt = 'foo'
    end

    def test_interpreter

      @proc = Interpreter.new(@compiled, @interpreter_salt, {'userid'=> 123454})

      @params = @proc.get_params
      assert_equal(@proc.get_params.get('specific_goal'), 1)
      assert_equal(@proc.get_params.get('ratings_goal'), 320)
      # proc = Interpreter(
      #     self.compiled, self.interpreter_salt, {'userid': 123454})
      # params = proc.get_params()
      # self.assertEqual(proc.get_params().get('specific_goal'), 1)
      # self.assertEqual(proc.get_params().get('ratings_goal'), 320)
    end


    def teardown
      # Do nothing
    end

    # Fake test
    def test_fail

      fail('Not implemented')
    end
  end
end