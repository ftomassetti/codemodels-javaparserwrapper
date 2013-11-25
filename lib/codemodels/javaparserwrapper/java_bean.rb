module CodeModels
module Javaparserwrapper

class RGenType
end

class JavaBeanMetaModel

private

    def getters
        properties = []
        java_class = @java_bean.java_class
        java_class.declared_instance_methods.select {|m| m.name.start_with?('get')||m.name.start_with?('is') }
    end

    def java_to_rgen_type(java_type,specific_mappings)
        if java_type==JavaString
            RGenType.single_attribute(String)
        elsif java_type==JavaBoolean
            RGenType.single_attribute(RGen::MetamodelBuilder::DataTypes::Boolean)
        elsif java_type==JavaInt
            RGenType.single_attribute(Integer)
        elsif specific_mappings.has_key?(java_type)
            specific_mappings[java_type]
        elsif java_type==JavaList
            type_name = CodeModels::Java.get_generic_param(m.to_generic_string)
            last = type_name.index '>'
            type_name = type_name[0..last-1]
            type_ast_class = MappedAstClasses.keys.find{|k| k.name==type_name}
            if type_ast_class
                contains_many_uni prop_name, MappedAstClasses[type_ast_class]
            else
                raise "#{ast_name}) Property (many) #{prop_name} is else: #{type_name}"
            end
        elsif m.return_type.enum?
            has_attr prop_name, String
        else
            raise "#{ast_name}) Property (single) #{prop_name} is else: #{m.return_type}"
        end
    end

    def property_name(java_method)
        return java_method.name.remove_prefix('get').proper_uncapitalize if java_method.name.start_with?('get')
        return java_method.name.remove_prefix('is').proper_uncapitalize if java_method.name.start_with?('is')
    end

    def get_generic_param(generic_str)
        return generic_str.remove_prefix('public java.util.List<') if generic_str.start_with?('public java.util.List<')
        return generic_str.remove_prefix('public final java.util.List<') if generic_str.start_with?('public final java.util.List<')
        nil
    end

end

class JavaBeanModel

    def initialize(java_bean)
        @java_bean = java_bean
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