package com.gouyu.exception;

public class RetryableBenefitOrderException extends RuntimeException {

    private final String errorCode;

    public RetryableBenefitOrderException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    public RetryableBenefitOrderException(String errorCode, String message, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
    }

    public String getErrorCode() {
        return errorCode;
    }
}
