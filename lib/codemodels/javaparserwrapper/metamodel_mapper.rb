module CodeModels
module Javaparserwrapper

# This should map a Java class to an RGen metaclass
class MetamodelMapper

    JavaString  = ::Java::JavaClass.for_name("java.lang.String")
    JavaList    = ::Java::JavaClass.for_name("java.util.List")
    JavaBoolean = ::Java::boolean.java_class
    JavaInt     = ::Java::int.java_class

    def initialize(base_java_class,base_rgen_metaclass)
        @base_java_class     = base_java_class
        @base_rgen_metaclass = base_rgen_metaclass
        @mapped_ast_classes  = {}
        @props_to_ignore     = []
    end

    def self.wrap(java_classes_names,metamodel_module)        
        # first create all the classes
        java_classes_names.each do |ast_name|
            java_class       = ::Java::JavaClass.for_name(ast_name)
            java_super_class = java_class.superclass
            
            raise "Already mapped! #{ast_name}" if @mapped_ast_classes[java_class]

            if java_super_class.name == @base_java_class
                rgen_super_metaclass = @base_rgen_metaclass
            else
                raise "Super class #{java_super_class.name} of #{java_class.name} should have been wrapped before!" unless @mapped_ast_classes[java_super_class]
                rgen_super_metaclass = @mapped_ast_classes[java_super_class]
            end
            new_metaclass = Class.new(rgen_super_metaclass)            
            @mapped_ast_classes[java_class] = new_metaclass
            metamodel_module.const_set CodeModels::Javaparserwrapper::Utils.simple_java_class_name(ast_class.ruby_class), new_metaclass
        end

        # then add all the properties and attributes
        java_classes_names.each do |ast_name|
            java_class = ::Java::JavaClass.for_name(ast_name)
            ruby_class = java_class.ruby_class
            metaclass = @mapped_ast_classes[java_class]
                
            metaclass.class_eval do
                ast_class.java_class.declared_instance_methods.select {|m| m.name.start_with?('get')||m.name.start_with?('is') }.each do |m|
                    prop_name = CodeModels::Java.property_name(m)
                    unless @props_to_ignore.include?(prop_name)
                        if m.return_type==JavaString
                            has_attr prop_name, String
                        elsif m.return_type==JavaBoolean
                            has_attr prop_name, RGen::MetamodelBuilder::DataTypes::Boolean
                        elsif m.return_type==JavaInt
                            has_attr prop_name, Integer
                        elsif MappedAstClasses.has_key?(m.return_type)
                            contains_one_uni prop_name, MappedAstClasses[m.return_type]
                        elsif m.return_type==JavaList
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
                end
            end
        end
    end

    private

    def self.property_name(java_method)
        return java_method.name.remove_prefix('get').proper_uncapitalize if java_method.name.start_with?('get')
        return java_method.name.remove_prefix('is').proper_uncapitalize if java_method.name.start_with?('is')
    end

    def self.get_generic_param(generic_str)
        return generic_str.remove_prefix('public java.util.List<') if generic_str.start_with?('public java.util.List<')
        return generic_str.remove_prefix('public final java.util.List<') if generic_str.start_with?('public final java.util.List<')
        nil
    end
end

end
end