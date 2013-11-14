package it.codemodels.javaparserwrapper.ast;

import java.util.List;
import java.util.LinkedList;
import java.util.Date;

public class Comment {

    private Date insertionDate;
    private String content;

    public Comment(Date insertionDate, String content){
        this.insertionDate = insertionDate;
        this.content = content;
    }

    public String getContent(){
        return content;
    }

    public Date getInsertionDate(){
        return insertionDate;
    }
}