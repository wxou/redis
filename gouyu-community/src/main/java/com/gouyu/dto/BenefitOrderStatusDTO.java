package com.gouyu.dto;

import com.gouyu.entity.BenefitOrder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class BenefitOrderStatusDTO {
    private Long orderId;
    private String status;
    private String message;
    private Integer retryCount;
    private LocalDateTime updatedAt;
    private BenefitOrder order;
}
