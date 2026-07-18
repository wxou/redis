package com.gouyu;

import com.gouyu.config.AuthProperties;
import com.gouyu.utils.GouYuPasswordEncoder;
import org.junit.jupiter.api.Test;
import org.springframework.util.DigestUtils;

import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.*;

class GouYuPasswordEncoderTest {

    private final GouYuPasswordEncoder passwordEncoder = new GouYuPasswordEncoder(new AuthProperties());

    @Test
    void shouldEncodeAndMatchBcryptPassword() {
        String encoded = passwordEncoder.encode("securePass8");

        assertTrue(encoded.startsWith("$2"));
        assertTrue(passwordEncoder.matches("securePass8", encoded));
        assertFalse(passwordEncoder.matches("wrongPass8", encoded));
        assertFalse(passwordEncoder.needsUpgrade(encoded));
    }

    @Test
    void shouldMatchLegacyMd5AndRequireUpgrade() {
        String salt = "legacySalt1234567890";
        String rawPassword = "legacyPass8";
        String digest = DigestUtils.md5DigestAsHex((rawPassword + salt).getBytes(StandardCharsets.UTF_8));
        String encoded = salt + "@" + digest;

        assertTrue(passwordEncoder.matches(rawPassword, encoded));
        assertFalse(passwordEncoder.matches("wrongPass8", encoded));
        assertTrue(passwordEncoder.needsUpgrade(encoded));
    }

    @Test
    void shouldRejectBlankAndMalformedHashes() {
        assertFalse(passwordEncoder.matches("securePass8", null));
        assertFalse(passwordEncoder.matches("securePass8", ""));
        assertFalse(passwordEncoder.matches("securePass8", "not-a-hash"));
    }
}
