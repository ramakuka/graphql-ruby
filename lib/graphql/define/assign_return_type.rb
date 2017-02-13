module GraphQL
  module Define
    module AssignReturnType
      def self.call(target, type = nil, &block)
        if type.nil?
          type = GraphQL::ObjectType.define(&block)
          type.name ||= "#{target.name}Result"
        end

        target.type = type
      end
    end
  end
end
