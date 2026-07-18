package com.gouyu.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApiResult {
    private Boolean success;
    private String errorMsg;
    private Object data;
    private Long total;

    public static ApiResult ok(){
        return new ApiResult(true, null, null, null);
    }
    public static ApiResult ok(Object data){
        return new ApiResult(true, null, data, null);
    }
    public static ApiResult ok(List<?> data, Long total){
        return new ApiResult(true, null, data, total);
    }
    public static ApiResult fail(String errorMsg){
        return new ApiResult(false, errorMsg, null, null);
    }
}
