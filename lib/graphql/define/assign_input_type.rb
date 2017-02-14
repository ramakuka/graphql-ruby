module GraphQL
  module Define
    module AssignInputType
      def self.call(target, type = nil, &block)
        if type.nil?
          type = GraphQL::InputObjectType.define(&block)
          type.name ||= "#{target.name}Input"
        end
        target.type = type
      end
    end
  end
end
