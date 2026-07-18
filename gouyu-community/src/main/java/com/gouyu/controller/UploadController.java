package com.gouyu.controller;

import com.gouyu.dto.ApiResult;
import com.gouyu.utils.GouYuConstants;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("upload")
public class UploadController {

    private static final long MAX_IMAGE_SIZE = 5L * 1024 * 1024;
    private static final Map<String, String> IMAGE_EXTENSIONS;

    static {
        Map<String, String> extensions = new HashMap<>();
        extensions.put("image/jpeg", "jpg");
        extensions.put("image/png", "png");
        extensions.put("image/webp", "webp");
        extensions.put("image/gif", "gif");
        IMAGE_EXTENSIONS = Collections.unmodifiableMap(extensions);
    }

    @PostMapping("post")
    public ApiResult uploadImage(@RequestParam("file") MultipartFile image) {
        if (image == null || image.isEmpty()) {
            return ApiResult.fail("请选择要上传的图片");
        }
        if (image.getSize() > MAX_IMAGE_SIZE) {
            return ApiResult.fail("图片不能超过5MB");
        }
        String suffix = IMAGE_EXTENSIONS.get(image.getContentType());
        if (suffix == null) {
            return ApiResult.fail("仅支持 JPG、PNG、WEBP 和 GIF 图片");
        }
        try {
            String relativeName = createNewFileName(suffix);
            Path root = uploadRoot();
            Path target = root.resolve(relativeName).normalize();
            if (!target.startsWith(root)) {
                return ApiResult.fail("错误的文件名称");
            }
            Files.createDirectories(target.getParent());
            image.transferTo(target.toFile());
            String publicPath = "/assets/" + relativeName.replace('\\', '/');
            log.debug("文件上传成功，{}", publicPath);
            return ApiResult.ok(publicPath);
        } catch (IOException e) {
            throw new RuntimeException("文件上传失败", e);
        }
    }

    @GetMapping("/post/delete")
    public ApiResult deletePostImage(@RequestParam("name") String filename) {
        String relativeName = filename == null ? "" : filename.replace('\\', '/');
        if (relativeName.startsWith("/assets/")) {
            relativeName = relativeName.substring("/assets/".length());
        } else if (relativeName.startsWith("/")) {
            relativeName = relativeName.substring(1);
        }
        Path root = uploadRoot();
        Path target = root.resolve(relativeName).normalize();
        if (relativeName.isEmpty() || !relativeName.startsWith("posts/") || !target.startsWith(root)) {
            return ApiResult.fail("错误的文件名称");
        }
        try {
            return Files.deleteIfExists(target) ? ApiResult.ok() : ApiResult.fail("图片不存在");
        } catch (IOException e) {
            throw new RuntimeException("图片删除失败", e);
        }
    }

    private String createNewFileName(String suffix) {
        String name = UUID.randomUUID().toString();
        int hash = name.hashCode();
        int d1 = hash & 0xF;
        int d2 = (hash >> 4) & 0xF;
        return String.format("posts/%d/%d/%s.%s", d1, d2, name, suffix);
    }

    private Path uploadRoot() {
        return Paths.get(GouYuConstants.IMAGE_UPLOAD_DIR).toAbsolutePath().normalize();
    }
}
