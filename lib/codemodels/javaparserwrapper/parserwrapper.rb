require 'codemodels'

module CodeModels
module Javaparserwrapper

module TransformationFactory

	def instantiate_transformed(original)
		target_class = get_corresponding_class(original)
		instance = target_class.new
	end

end

# This class initialize an RGen object from a model,
# used as the source
class RGenInitializer



end

# They look in a specified Module for a class with 
# the same name as the class of the original object 
module BasicTransformationFactory
	include TransformationFactory

	attr_accessor :target_module

	protected

	def get_corresponding_class(original)
		original_class = original.class
		class_name = Utils.simple_java_class_name(original_class)
		raise "No corresponding class '#{class_name}' found in #{@target_module}" unless @target_module.const_defined?(class_name)
		@target_module.const_get(class_name)
	end

end

# A Parser built wrapping a base parser written in Java
class ParserJavaWrapper < CodeModels::Parser



end

class JavaObjectsToRgenTransformer

	attr_accessor :verbose

	def initialize
		@verbose = false
	end

	JavaCollection = ::Java::JavaClass.for_name("java.util.Collection")

	def log(msg)
		puts msg if verbose
	end

	def adapter_specific_class(model_class,ref)
		nil
	end
	
	def adapter(model_class,ref)
		if adapter_specific_class(model_class,ref)
			adapter_specific_class(model_class,ref)
		else
			if model_class.superclass!=Object
				adapter(model_class.superclass,ref) 
			else
				nil
			end
		end
	end

	def reference_to_method(model_class,ref)
		s = ref.name
		adapted = adapter(model_class,ref)
		s = adapted if adapted		
		s.to_sym
	end

	def attribute_to_method(model_class,att)
		s = att.name
		adapted = adapter(model_class,att)
		s = adapted if adapted		
		s.to_sym
	end

	def assign_ref_to_model(model,ref,value)
		return unless value==nil # we do not need to assign a nil...
		if ref.many
			adder_method = :"add#{ref.name.capitalize}"
			value.each {|el| model.send(adder_method,node_to_model(el))}
		else
			setter_method = :"#{ref.name}="
			raise "Trying to assign an array to a single property. Class #{model.class}, property #{ref.name}" if value.is_a?(::Array)
			model.send(setter_method,node_to_model(value))
		end
	rescue Object => e
		puts "Problem while assigning ref #{ref.name} (many? #{ref.many}) to #{model.class}. Value: #{value.class}"
		puts "\t<<#{e}>>"
		raise e
	end

	def assign_att_to_model(model,att,value)
		if att.many
			adder_method = :"add#{att.name.capitalize}"
			value.each {|el| model.send(adder_method,el)}
		else
			setter_method = :"#{att.name}="
			raise "Trying to assign an array to a single property. Class #{model.class}, property #{att.name}" if value.is_a?(::Array)
			model.send(setter_method,value)
		end
	end

	def populate_attr(node,att,model)	
		value = get_feature_value(node,att)
		model.send(:"#{att.name}=",value) if value!=nil
	rescue Object => e
		puts "Problem while populating attribute #{att.name} of #{model} from #{node}. Value: #{value}"
		raise e
	end

	def populate_ref(node,ref,model)
		log("populate ref #{ref.name}, node: #{node.class}, model: #{model.class}")
		value = get_feature_value(node,ref)
		log("\tvalue=#{value.class}")
		if value!=nil
			if value==node
				puts "avoiding loop... #{ref.name}, class #{node.class}" 
				return
			end
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

	def node_to_model(node)
		log("node_to_model #{node.class}")		
		instance = instantiate_transformed(node)
		metaclass = instance.class
		metaclass.ecore.eAllAttributes.each do |attr|
			populate_attr(node,attr,instance)
		end
		metaclass.ecore.eAllReferences.each do |ref|
			populate_ref(node,ref,instance)
		end
		instance
	end

	def transform_enum_values(value)
		if value.respond_to?(:java_class) && value.java_class.enum?
			value.name
		else
			value
		end
	end

	def get_feature_value_through_getter(node,feat_name)
		capitalized_name = feat_name.proper_capitalize
		methods = [:"get#{capitalized_name}",:"is#{capitalized_name}"]

		methods.each do |m|
			if node.respond_to?(m)
				begin
					return transform_enum_values(node.send(m))
				rescue Object => e
					raise "Problem invoking #{m} on #{node.class}: #{e}"
				end
			end
		end
		raise "how should I get this... #{feat_name} on #{node.class}. It does not respond to #{methods}"
	end

	def get_feature_value(node,feat)
		adapter = adapter(node.class,feat)		
		if adapter
			adapter[:adapter].call(node)
		else
			get_feature_value_through_getter(node,feat.name)
		end
	end

end

end
end
