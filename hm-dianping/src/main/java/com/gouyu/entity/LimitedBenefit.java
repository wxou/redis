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
 * 限时权益表，与权益是一对一关系
 * </p>
 *
 * @author 构域项目组
 * @since 2022-01-04
 */
@Data
@EqualsAndHashCode(callSuper = false)
@Accessors(chain = true)
@TableName("gy_limited_benefit")
public class LimitedBenefit implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 关联的权益的id
     */
    @TableId(value = "benefit_id", type = IdType.INPUT)
    private Long benefitId;

    /**
     * 库存
     */
    private Integer stock;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 生效时间
     */
    private LocalDateTime startsAt;

    /**
     * 失效时间
     */
    private LocalDateTime endsAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;


}
