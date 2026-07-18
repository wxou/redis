package com.gouyu.dto;

import lombok.Data;

@Data
public class PasswordResetRequest {
    private String phone;
    private String code;
    private String newPassword;
}
