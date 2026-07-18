package com.gouyu.controller;


import com.gouyu.dto.ApiResult;
import com.gouyu.entity.MerchantCategory;
import com.gouyu.service.IMerchantCategoryService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.List;

/**
 * <p>
 * 前端控制器
 * </p>
 *
 * @author 构域项目组
 * @since 2021-12-22
 */
@RestController
@RequestMapping("/merchant-category")
public class MerchantCategoryController {
    @Resource
    private IMerchantCategoryService categoryService;

    @GetMapping("list")
    public ApiResult queryCategoryList() {
        return categoryService.queryCategoryList();
    }
}
