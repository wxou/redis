package com.heima.test;

import com.heima.jedis.utils.JedisConnectionFactory;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import redis.clients.jedis.Jedis;

import java.util.Map;

public class JedisTest {

    private Jedis jedis;

    @BeforeEach
    void setUp(){
        //1.建立连接
//        jedis = new Jedis("192.168.100.128", 6379);
        jedis = JedisConnectionFactory.getJedis();
        //2.设置密码
        jedis.auth("123321");
        //3.选择数据库
        jedis.select(0);
    }


    @Test
    void testString(){
        //1.保存数据
        String result = jedis.set("name", "胡歌");
        System.out.println("result = "+result);

        //2.取数据
        String name = jedis.get("name");
        System.out.println("name = "+name);
    }

    @Test
    void testHash(){
        //1.保存数据
        jedis.hset("user:1","name","Jack");
        jedis.hset("user:1","age","18");

        //2.取数据
        Map<String, String> map = jedis.hgetAll("user:1");
        System.out.println(map);
    }

    @AfterEach
    void tearDown(){
        if(jedis != null){
            jedis.close();
        }
    }

}
