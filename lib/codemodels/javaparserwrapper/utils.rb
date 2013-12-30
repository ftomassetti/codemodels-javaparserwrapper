module CodeModels
module Javaparserwrapper

module Utils	

	def self.simple_java_class_name(java_class)
        if java_class.is_a?(::Java::JavaClass)
            return Utils.simple_java_class_name(java_class.ruby_class)
        end
		name = java_class.name
    	if (i = (r = name).rindex(':')) then r[0..i] = '' end
    	r
  	end

end

end
end