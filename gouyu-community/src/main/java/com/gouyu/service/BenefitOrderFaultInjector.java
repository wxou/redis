package com.gouyu.service;

import com.gouyu.entity.BenefitOrder;
import org.springframework.stereotype.Component;

/**
 * Production no-op hooks. Tests can replace this bean with @MockBean to inject failures.
 */
@Component
public class BenefitOrderFaultInjector {

    public void beforeLock(BenefitOrder order) {
    }

    public void beforePersist(BenefitOrder order) {
    }

    public void beforeCompensate(BenefitOrder order) {
    }

    public void beforeFinalize(BenefitOrder order) {
    }
}
