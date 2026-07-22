package com.gouyu.config;

import org.springframework.beans.factory.InitializingBean;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;

@Component
public class BenefitOrderSchemaInitializer implements InitializingBean {

    private final DataSource dataSource;
    private final BenefitOrderProperties properties;

    public BenefitOrderSchemaInitializer(DataSource dataSource, BenefitOrderProperties properties) {
        this.dataSource = dataSource;
        this.properties = properties;
    }

    @Override
    public void afterPropertiesSet() {
        if (!properties.isInitializeSchema()) {
            return;
        }
        ResourceDatabasePopulator populator = new ResourceDatabasePopulator(
                new ClassPathResource("db/migration/20260722_benefit_order_reliability.sql")
        );
        populator.setContinueOnError(false);
        populator.execute(dataSource);
    }
}
