package com.gouyu.config;

import com.gouyu.dto.ApiResult;
import com.gouyu.exception.RateLimitException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(RateLimitException.class)
    public ResponseEntity<ApiResult> handleRateLimitException(RateLimitException e) {
        return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS)
                .header("Retry-After", Long.toString(e.getRetryAfterSeconds()))
                .body(ApiResult.fail(e.getMessage()));
    }

    @ExceptionHandler(RuntimeException.class)
    public ApiResult handleRuntimeException(RuntimeException e) {
        log.error(e.toString(), e);
        return ApiResult.fail("服务器异常");
    }
}
