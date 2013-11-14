package it.codemodels.javaparserwrapper.ast;

import java.util.List;
import java.util.LinkedList;

public class Project {

    private String name;
    private List<Todo> todos;

    public Project(String name){
        this.name = name;
        this.todos = new LinkedList<Todo>();
    }

    public void addTodo(Todo todo){
        this.todos.add(todo);
    }

    public List<Todo> getTodos(){
        return todos;
    }

    public String getName(){
        return this.name;
    }
}