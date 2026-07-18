package com.gouyu.utils;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class RedisCachePayload {
    private LocalDateTime expireTime;
    private Object data;
}
