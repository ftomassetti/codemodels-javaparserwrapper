module CodeModels
module Javaparserwrapper

# Given a java bean
# - map to a RGen metaclass
# - each feature is filled either using an adapter or a source model access
# - things obtained through source model have to be converted to rgen objects 

# This class map a source to a specific RGenMetaclass
class RGenMetaclassMapper

    def rgen_metaclass(java_class)
    end

end

class ValueGetter
end

class RGenValueFiller

    def fill(rgen_obj,property,value)
        if property.many
            set_multiple_value(rgen_obj,property,value)
        else
            set_single_value(rgen_obj,property,value)
        end
    end

    private

    def set_single_value(rgen_obj,property,value)
        rgen_obj.send(:"#{property.name}=",value)
    end

    def set_multiple_value(rgen_obj,property,value)
        capitalized_name = property.name.proper_capitalize              
        value.each do |el|
            model.send(:"add#{capitalized_name}",node_to_model(el))
        end
    end

end

# It builds RGen objects from some source
class RGenObjectMapper

    def initialize(metaclass_mapper)
        @metaclass_mapper = metaclass_mapper
    end

    def rgen_object(source)
        rgen_obj = instantiate(source)
        initialize_obj(rgen_obj,source)
        rgen_obj
    end

    private

    def instantiate(source)
        metaclass = @metaclass_mapper.rgen_metaclass(source.java_class)
        metaclass.new
    end

    def initialize_obj(rgen_obj,source_model)
        metaclass = rgen_obj.class
        metaclass.ecore.eAllAttributes.each do |att|
            initialize_attr(rgen_obj,source_model,att)
        end
        metaclass.ecore.eAllReferences.each do |ref|
            initialize_ref(rgen_obj,source_model,ref)
        end     
    end

    def initialize_attr(rgen_obj,source_model,att)
        value = source_model.get_value(node,att)
        set_value(rgen_obj,att,value) if value!=nil
    rescue Object => e
        puts "Problem while populating attribute #{att.name} of #{rgen_obj} from #{source_model}. Value: #{value}"
        raise e     
    end

    def initialize_ref(rgen_obj,source_model,ref)
        value = source_model.get_value(node,ref)
        if value!=nil
            if JavaCollection.assignable_from?(value.java_class)
                log("\tvalue is a collection")
                capitalized_name = ref.name.proper_capitalize               
                value.each do |el|
                    unless el.respond_to?(:parent)
                        el.class.__persistent__ = true
                        class << el
                            attr_accessor :parent                       
                        end
                    end
                    el.parent = node
                    model.send(:"add#{capitalized_name}",node_to_model(el))
                end
            else
                log("\tvalue is not a collection")
                unless value.respond_to?(:parent)
                    value.class.__persistent__ = true
                    class << value
                        attr_accessor :parent
                    end
                end
                value.parent = node
                model.send(:"#{ref.name}=",node_to_model(value))
            end
        end     
    end

    private

    def single_value?(value)
    end

    def set_value(rgen_obj,property,value)
        if single_value?(value)
            set_single_value(rgen_obj,property,value)
        else
            set_multiple_value(rgen_obj,property,value)
        end
    end 

    def set_single_value(rgen_obj,property,value)
        rgen_obj.send(:"#{property.name}=",value)
    end

    def set_multiple_value(rgen_obj,property,value)
        capitalized_name = property.name.proper_capitalize              
        value.each do |el|
            model.send(:"add#{capitalized_name}",node_to_model(el))
        end
    end

    def set_parent(obj,parent)
        unless obj.respond_to?(:parent)
            obj.class.__persistent__ = true
            class << obj
                attr_accessor :parent                       
            end
        end
        obj.parent = parent             
    end

end

end