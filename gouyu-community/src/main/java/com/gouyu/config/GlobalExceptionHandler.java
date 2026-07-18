package com.gouyu.config;

import com.gouyu.dto.ApiResult;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RuntimeException.class)
    public ApiResult handleRuntimeException(RuntimeException e) {
        log.error(e.toString(), e);
        return ApiResult.fail("服务器异常");
    }
}
