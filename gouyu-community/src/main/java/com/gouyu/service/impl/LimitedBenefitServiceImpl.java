package com.gouyu.service.impl;

import com.gouyu.entity.LimitedBenefit;
import com.gouyu.mapper.LimitedBenefitMapper;
import com.gouyu.service.ILimitedBenefitService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

/**
 * <p>
 * 限时权益权益表，与权益是一对一关系 服务实现类
 * </p>
 *
 * @author 构域项目组
 * @since 2022-01-04
 */
@Service
public class LimitedBenefitServiceImpl extends ServiceImpl<LimitedBenefitMapper, LimitedBenefit> implements ILimitedBenefitService {

}
