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
@TableName("gy_post")
public class Post implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 主键
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;
    /**
     * 商户id
     */
    private Long merchantId;
    /**
     * 成员id
     */
    private Long memberId;
    /**
     * 动态作者头像
     */
    @TableField(exist = false)
    private String authorAvatarUrl;
    /**
     * 动态作者名称
     */
    @TableField(exist = false)
    private String authorName;
    /**
     * 是否点赞过了
     */
    @TableField(exist = false)
    private Boolean likedByCurrentMember;

    /**
     * 标题
     */
    private String title;

    /**
     * 社区动态的照片，最多9张，多张以","隔开
     */
    private String imageUrls;

    /**
     * 社区动态的文字描述
     */
    private String content;

    /**
     * 点赞数量
     */
    private Integer likeCount;

    /**
     * 评论数量
     */
    private Integer commentCount;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 更新时间
     */
    private LocalDateTime updatedAt;


}
