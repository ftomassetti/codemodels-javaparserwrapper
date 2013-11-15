module CodeModels
module Javaparserwrapper

class JavaBeanModel

    def initialize(java_bean,adapters_map)
        @java_bean    = java_bean
        @adapters_map = adapters_map
    end

    def get_value(property)
        adapter = @adapters_map[property]       
        if adapter
            adapter.call(@java_bean)
        else
            get_property_value_through_getter(node,property.name)
        end     
    end

    private

    def get_property_value_through_getter(node,prop_name)
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

end

class JavaBeanMetamodel

    def initialize
        @adapters = Hash.new {|h,k| h[k]={} }
    end

    # Gives back instances of JavaBeanModel
    def get_model(java_bean)
        JavaBeanModel.new(java_bean,adapters_map(java_bean))
    end

    def record_property_getter_adapter(java_class,prop_name,&adapter)
        class_name = Utils.simple_java_class_name(java_class)
        @adapters[class_name.to_sym][prop_name.to_sym]= adapter
    end

    private

    def adapters_map(java_bean)
        java_class = java_bean.java_class
        adapters_map_for_class(java_class) 
    end

    def adapters_map_for_class(java_class)
        if java_class.superclass
            base_adapters_map = adapters_map_for_class(java_class.superclass)
        else
            base_adapters_map = {}
        end
        class_name = Utils.simple_java_class_name( java_class)
        class_adapters_map = @adapters[class_name.to_sym]
        class_adaptersmap.merge(base_adapters_map)
    end
    
end

end
end