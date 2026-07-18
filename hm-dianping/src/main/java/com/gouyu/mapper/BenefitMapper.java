package com.gouyu.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.gouyu.entity.Benefit;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * <p>
 *  Mapper 接口
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
public interface BenefitMapper extends BaseMapper<Benefit> {

    List<Benefit> queryBenefitsOfMerchant(@Param("merchantId") Long merchantId);
}
