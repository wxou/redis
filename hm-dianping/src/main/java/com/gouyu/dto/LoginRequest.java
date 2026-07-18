package com.gouyu.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String phone;
    private String code;
    private String password;
}
