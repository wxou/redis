package com.gouyu.utils;

public class RedisKeys {
    public static final String AUTH_CODE_KEY = "gy:auth:code:";
    public static final Long AUTH_CODE_TTL = 2L;
    public static final String AUTH_SESSION_KEY = "gy:auth:session:";
    public static final Long AUTH_SESSION_TTL = 36000L;

    public static final Long CACHE_NULL_TTL = 2L;

    public static final Long CACHE_MERCHANT_TTL = 30L;
    public static final String CACHE_MERCHANT_KEY = "gy:cache:merchant:";

    public static final String LOCK_MERCHANT_KEY = "gy:lock:merchant:";
    public static final Long LOCK_MERCHANT_TTL = 10L;

    public static final String LIMITED_BENEFIT_STOCK_KEY = "gy:limited-benefit:stock:";
    public static final String POST_LIKED_KEY = "gy:post:liked:";
    public static final String FEED_KEY = "gy:feed:";
    public static final String FOLLOWING_KEY = "gy:following:";
    public static final String FOLLOWING_LOADED_KEY = "gy:following:loaded:";
    public static final String MERCHANT_GEO_KEY = "gy:merchant:geo:";
    public static final String MEMBER_CHECK_IN_KEY = "gy:check-in:";
    public static final String CACHE_MERCHANT_CATEGORY_KEY = "gy:cache:merchant-category:list";
    public static final long CACHE_MERCHANT_CATEGORY_TTL = 3600L;
}
