package com.gouyu.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.experimental.Accessors;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * <p>
 * 
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@TableName("gy_benefit_order")
public class BenefitOrder implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键
     */
    @TableId(value = "id", type = IdType.INPUT)
    private Long id;

    /**
     * 领取的成员id
     */
    private Long memberId;

    /**
     * 领取的权益id
     */
    private Long benefitId;

    /**
     * 支付方式 1：余额支付；2：支付宝；3：微信
     */
    private Integer payType;

    /**
     * 权益记录状态，1：未支付；2：已支付；3：已核销；4：已取消；5：退款中；6：已退款
     */
    private Integer status;

    /**
     * 领取时间
     */
    private LocalDateTime createdAt;

    /**
     * 支付时间
     */
    private LocalDateTime payTime;

    /**
     * 核销时间
     */
    private LocalDateTime useTime;

    /**
     * 退款时间
     */
    private LocalDateTime refundTime;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;


}
