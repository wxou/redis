package com.gouyu.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("gy_benefit_order_process")
public class BenefitOrderProcess {

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    private String streamRecordId;
    private Long orderId;
    private Long memberId;
    private Long benefitId;
    private String status;
    private Integer retryCount;
    private String errorCode;
    private String errorMessage;
    private String payloadJson;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime finishedAt;
}
