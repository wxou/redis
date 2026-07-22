package com.gouyu.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "gouyu.benefit-order")
public class BenefitOrderProperties {

    private int statusTtlHours = 168;
    private int maxRetries = 5;
    private long claimMinIdleMillis = 30000L;
    private long claimIntervalMillis = 10000L;
    private int claimBatchSize = 20;
    private long lockWaitMillis = 200L;
    private long deadLetterReconcileIntervalMillis = 60000L;
    private boolean initializeSchema = true;
}
