module ScreenRecorder
  # @since 1.0.0.beta10
  #
  # @api private
  module TypeChecker
    #
    # Compares the given object's type (class) to the desired object type.
    # Raises an ArgumentError if the object is not of desired type.
    #
    def self.check(obj, klass)
      raise ArgumentError, "Expected #{klass}, given: #{obj.class}" unless obj.is_a? klass
    end
  end
end