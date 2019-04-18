require_relative './op_random'
require_relative './assignment'
require_relative './simple_experiment'
require_relative './version'
require_relative './operator'

module PlanOut
  class Interpreter
    attr_accessor :serialization, :env, :experiment_salt, :inputs, :evaluated, :in_experiment

    def self.operators
      {
        "randomFloat": 'RandomFloat',
        "randomInteger": 'RandomInteger',
        "bernoulliTrial": 'BernoulliTrial',
        "weightedChoice": 'WeightedChoice',
        "uniformChoice": 'UniformChoice',
      }
    end

    def initialize(serialization, experiment_salt='global_salt', inputs={}, environment=nil)
      @serialization = serialization
      if environment.nil?
        @env = Assignment.new(experiment_salt)
      else
        @env = environment
      end
      @experiment_salt = @experiment_salt = experiment_salt
      @evaluated = false
      @in_experiment = true
      @inputs = inputs
    end
    

    # TODO: Raise StopPlanOutException and handle it
    def get_params
      # Get all assigned parameter values from an executed interpreter script
      # evaluate code if it hasn't already been evaluated
      if !self.evaluated
        begin
          self.evaluate(self.serialization)
        rescue => e
          # StopPlanOutException is raised when script calls "return", which
          # short circuits execution and sets in_experiment
          self.in_experiment = e.in_experiment
        end 
        self.evaluated = true
      end
      return self.env
    end

    def evaluate(planout_code)
      # """Recursively evaluate PlanOut interpreter code"""
      # if the object is a PlanOut operator, execute it it.
      if planout_code.is_a?(Hash) and planout_code.key?("op")
        Kernel.const_get(planout_code["op"].capitalize).new(planout_code).execute
        # return Operators.operatorInstance(planout_code).execute(self)
      # if the object is a list, iterate over the list and evaluate each
      # element
      elsif planout_code.is_a?(Array)
        return planout_code.map{|i| self.evaluate(i) }
      else
        return planout_code  # data is a literal
      end
    end

  end

  # def register_operators(self, operators):
  #  Operators.registerOperators(operators)
  #  return self
  # end

end