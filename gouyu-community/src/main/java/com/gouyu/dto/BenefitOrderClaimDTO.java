package com.gouyu.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class BenefitOrderClaimDTO {
    private Long orderId;
    private String status;
    private String message;
}
