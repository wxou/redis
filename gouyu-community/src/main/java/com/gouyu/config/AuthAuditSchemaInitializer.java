package com.gouyu.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

/**
 * 为已有数据库非破坏性补齐认证审计表。生产环境可关闭并改由迁移系统执行。
 */
@Slf4j
@Component
public class AuthAuditSchemaInitializer implements InitializingBean {

    private final DataSource dataSource;

    @Value("${gouyu.auth.initialize-audit-schema:true}")
    private boolean initializeAuditSchema;

    public AuthAuditSchemaInitializer(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public void afterPropertiesSet() {
        if (!initializeAuditSchema) {
            return;
        }
        ResourceDatabasePopulator populator = new ResourceDatabasePopulator(
                new ClassPathResource("db/migration/20260718_auth_hardening.sql")
        );
        populator.setContinueOnError(false);
        populator.execute(dataSource);
        log.info("认证审计表结构检查完成");
    }
}
