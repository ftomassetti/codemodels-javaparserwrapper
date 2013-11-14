package it.codemodels.javaparserwrapper.ast;

import java.util.List;
import java.util.LinkedList;

public class Todo {

    public enum Status {
        COMPLETED,
        WORKING_ON,
        NOT_STARTED
    };

    private String description;
    private Status status;
    private List<Comment> comments;

    public Todo(String description){
        this.description = description;
        this.status = Status.NOT_STARTED;
        this.comments = new LinkedList<Comment>();
    }

    public String getDescription(){
        return description;
    }

    public Status getStatus(){
        return status;
    }

    public List<Comment> getComments(){
        return comments;
    }

    public void addComment(Comment comment){
        this.comments.add(comment);
    }

    public void setStatus(Status status){
        this.status = status;
    }
}