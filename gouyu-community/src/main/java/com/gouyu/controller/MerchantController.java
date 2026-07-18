package com.gouyu.controller;


import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.gouyu.dto.ApiResult;
import com.gouyu.entity.Merchant;
import com.gouyu.service.IMerchantService;
import com.gouyu.utils.GouYuConstants;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;

/**
 * <p>
 * 前端控制器
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
@RestController
@RequestMapping("/merchant")
public class MerchantController {

    @Resource
    public IMerchantService merchantService;

    /**
     * 根据id查询商户信息
     * @param id 商户id
     * @return 商户详情数据
     */
    @GetMapping("/{id}")
    public ApiResult queryMerchantById(@PathVariable("id") Long id) {
        return merchantService.queryById(id);
    }

    /**
     * 新增商户信息
     * @param merchant 商户数据
     * @return 商户id
     */
    @PostMapping
    public ApiResult saveMerchant(@RequestBody Merchant merchant) {
        // 写入数据库
        merchantService.save(merchant);
        // 返回商户id
        return ApiResult.ok(merchant.getId());
    }

    /**
     * 更新商户信息
     * @param merchant 商户数据
     * @return 无
     */
    @PutMapping
    public ApiResult updateMerchant(@RequestBody Merchant merchant) {
        // 写入数据库
        return merchantService.update(merchant);
    }

    /**
     * 根据商户分类分页查询商户信息
     * @param categoryId 商户分类
     * @param current 页码
     * @return 商户列表
     */
    @GetMapping("/of/category")
    public ApiResult queryMerchantByCategory(
            @RequestParam("categoryId") Integer categoryId,
            @RequestParam(value = "current", defaultValue = "1") Integer current,
            @RequestParam(value = "x", required = false) Double x,
            @RequestParam(value = "y", required = false) Double y
    ) {
        return merchantService.queryMerchantByCategory(categoryId, current, x, y);
    }

    /**
     * 根据商户名称关键字分页查询商户信息
     * @param name 商户名称关键字
     * @param current 页码
     * @return 商户列表
     */
    @GetMapping("/of/name")
    public ApiResult queryMerchantByName(
            @RequestParam(value = "name", required = false) String name,
            @RequestParam(value = "current", defaultValue = "1") Integer current
    ) {
        // 根据分类分页查询
        Page<Merchant> page = merchantService.query()
                .like(StrUtil.isNotBlank(name), "name", name)
                .page(new Page<>(current, GouYuConstants.MAX_PAGE_SIZE));
        // 返回数据
        return ApiResult.ok(page.getRecords());
    }
}
