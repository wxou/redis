package com.gouyu.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("gy_auth_audit_log")
public class AuthAuditLog {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private String eventType;
    private Long memberId;
    private String phoneMasked;
    private String ipAddress;
    private String userAgent;
    private String outcome;
    private String reason;
    private String tokenFingerprint;
    private LocalDateTime createdAt;
}
