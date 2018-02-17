module Reruby
  class ExtractMethod::ExtractedMethod

    def initialize(name:, code_region:, keyword_arguments:)
      @name = name
      @code_region = code_region
      @keyword_arguments = keyword_arguments
    end

    def invocation
      "#{name}(#{args.invocation})"
    end

    def source
      scope_modifier = code_region.scope_type == "class" ? "self." : ""
      "def #{scope_modifier}#{name}(#{args.arguments})\n  #{code_region.source}\nend"
    end

    private

    attr_reader :name, :code_region, :keyword_arguments

    def args
      undefined_vars = code_region.undefined_variables
      if keyword_arguments
        KeywordArgs.new(undefined_vars)
      else
        PositionalArgs.new(undefined_vars)
      end
    end

    Args = Struct.new(:vars)

    class KeywordArgs < Args
      def invocation
        vars.map { |var| "#{var}: #{var}" }.join(", ")
      end

      def arguments
        vars.map { |var| "#{var}: " }.join(", ")
      end
    end

    class PositionalArgs < Args
      def invocation
        vars.join(", ")
      end

      def arguments
        invocation
      end
    end

  end
end
