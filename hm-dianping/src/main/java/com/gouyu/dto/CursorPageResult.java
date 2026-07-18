package com.gouyu.dto;

import lombok.Data;

import java.util.List;

@Data
public class CursorPageResult {
    private List<?> list;
    private Long minTime;
    private Integer offset;
}
