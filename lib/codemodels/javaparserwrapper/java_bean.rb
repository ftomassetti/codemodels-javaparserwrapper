module CodeModels
module Javaparserwrapper

class JavaBeanModel

    def initialize(java_bean)
        @java_bean    = java_bean
    end

    def get_value(property_name)
        get_property_value_through_getter(property_name)
    end

    private

    def get_property_value_through_getter(prop_name)
        capitalized_name = prop_name.proper_capitalize
        methods = [:"get#{capitalized_name}",:"is#{capitalized_name}"]

        methods.each do |m|
            if @java_bean.respond_to?(m)
                begin
                    return transform_enum_values(@java_bean.send(m))
                rescue Object => e
                    raise "Problem invoking #{m} on #{@java_bean.class}: #{e}"
                end
            end
        end
        raise "how should I get this... #{prop_name} on #{@java_bean.class}. It does not respond to #{methods}"
    end

	def transform_enum_values(value)
		if value.respond_to?(:java_class) && value.java_class.enum?
			value.name
		else
			value
		end
	end    

end

end
end