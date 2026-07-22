package com.gouyu.service;

public enum BenefitOrderStatus {
    PENDING,
    PROCESSING,
    RETRYING,
    SUCCESS,
    FAILED,
    COMPENSATED,
    DEAD_LETTER
}
