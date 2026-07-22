package com.gouyu.service;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.gouyu.entity.BenefitOrderProcess;
import com.gouyu.mapper.BenefitOrderProcessMapper;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class BenefitOrderProcessService extends ServiceImpl<BenefitOrderProcessMapper, BenefitOrderProcess> {

    public BenefitOrderProcess findByOrderId(Long orderId) {
        return orderId == null ? null : query().eq("order_id", orderId).one();
    }

    public void record(String streamRecordId, Long orderId, Long memberId, Long benefitId,
                       BenefitOrderStatus status, int retryCount, String errorCode,
                       String errorMessage, String payloadJson, boolean terminal) {
        BenefitOrderProcess process = query().eq("stream_record_id", streamRecordId).one();
        if (process == null) {
            process = new BenefitOrderProcess();
            process.setStreamRecordId(streamRecordId);
            process.setCreatedAt(LocalDateTime.now());
        } else if (!terminal && isTerminal(process.getStatus())) {
            return;
        }
        process.setOrderId(orderId);
        process.setMemberId(memberId);
        process.setBenefitId(benefitId);
        process.setStatus(status.name());
        process.setRetryCount(retryCount);
        process.setErrorCode(errorCode);
        process.setErrorMessage(StrUtil.sub(errorMessage, 0, 255));
        process.setPayloadJson(payloadJson);
        process.setUpdatedAt(LocalDateTime.now());
        process.setFinishedAt(terminal ? LocalDateTime.now() : null);
        saveOrUpdate(process);
    }

    private boolean isTerminal(String status) {
        return BenefitOrderStatus.SUCCESS.name().equals(status)
                || BenefitOrderStatus.COMPENSATED.name().equals(status)
                || BenefitOrderStatus.DEAD_LETTER.name().equals(status);
    }
}
