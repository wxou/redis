package com.gouyu.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
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
@TableName("gy_merchant")
public class Merchant implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 商户名称
     */
    private String name;

    /**
     * 商户分类的id
     */
    private Long categoryId;

    /**
     * 商户图片，多个图片以','隔开
     */
    private String imageUrls;

    /**
     * 服务区域，例如陆家嘴
     */
    private String area;

    /**
     * 地址
     */
    private String address;

    /**
     * 经度
     */
    private Double x;

    /**
     * 维度
     */
    private Double y;

    /**
     * 均价，取整数
     */
    private Long averagePrice;

    /**
     * 销量
     */
    private Integer serviceCount;

    /**
     * 评论数量
     */
    private Integer commentCount;

    /**
     * 评分，1~5分，乘10保存，避免小数
     */
    private Integer score;

    /**
     * 营业时间，例如 10:00-22:00
     */
    private String businessHours;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;


    @TableField(exist = false)
    private Double distance;
}
