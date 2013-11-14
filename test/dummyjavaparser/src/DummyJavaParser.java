package it.codemodels.javaparserwrapper;

import it.codemodels.javaparserwrapper.ast.Project;

public class DummyJavaParser {

    private Project root = null;

    public void setRoot(Project root){
        this.root = root;
    }

    public Project parse(){
        return this.root;
    }

}