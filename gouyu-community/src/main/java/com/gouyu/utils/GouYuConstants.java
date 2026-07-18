package com.gouyu.utils;

import java.io.File;

public class GouYuConstants {
    public static final String IMAGE_UPLOAD_DIR = System.getenv().getOrDefault(
            "GOUYU_IMAGE_UPLOAD_DIR",
            new File("web", "assets").getAbsolutePath()
    );
    public static final String MEMBER_NAME_PREFIX = "member_";
    public static final int DEFAULT_PAGE_SIZE = 5;
    public static final int MAX_PAGE_SIZE = 10;
}
