require 'helper'

$CLASSPATH << 'test/dummyjavaparser/classes'

java_import 'it.codemodels.javaparserwrapper.ast.Project'

class TestParser < Test::Unit::TestCase

    def setup
        @poli = Project.new('Poli')
    end

    def test_alpha
        assert_equal 'Poli',@poli.name
    end

end