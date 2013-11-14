require 'helper'

$CLASSPATH << 'test/dummyjavaparser/classes'

java_import 'it.codemodels.javaparserwrapper.ast.Project'
java_import 'it.codemodels.javaparserwrapper.ast.Todo'
java_import 'it.codemodels.javaparserwrapper.ast.Comment'
java_import 'it.codemodels.javaparserwrapper.DummyJavaParser'

class TestParser < Test::Unit::TestCase

    include CodeModels::Javaparserwrapper

    def setup
        @poli = Project.new('Poli')
    end

    def test_simple_java_class_name
        assert_equal 'Collection',Utils.simple_java_class_name(::Java::JavaClass.for_name("java.util.Collection"))
        assert_equal 'Collection',Utils.simple_java_class_name(::Java::JavaClass.for_name("java.util.Collection").ruby_class)
        assert_equal 'Project',Utils.simple_java_class_name(Project.java_class)
        assert_equal 'Todo',Utils.simple_java_class_name(Todo)
        assert_equal 'Comment',Utils.simple_java_class_name(Comment)
        assert_equal 'DummyJavaParser',Utils.simple_java_class_name(DummyJavaParser)
    end

end