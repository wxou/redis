package com.gouyu;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.EnableAspectJAutoProxy;


@EnableAspectJAutoProxy(exposeProxy = true)
@MapperScan("com.gouyu.mapper") // mapper包下都不需要加@Mapper注解
@SpringBootApplication
public class GouYuApplication {

    public static void main(String[] args) {
        SpringApplication.run(GouYuApplication.class, args);
    }

}
