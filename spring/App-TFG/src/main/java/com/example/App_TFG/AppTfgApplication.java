package com.example.App_TFG;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.MultipartConfigFactory;
import org.springframework.context.annotation.Bean;

import jakarta.servlet.MultipartConfigElement;

@SpringBootApplication
public class AppTfgApplication {

	public static void main(String[] args) {
		SpringApplication.run(AppTfgApplication.class, args);
	}
//backend podrá aceptar archivos 
	 @Bean
	    public MultipartConfigElement multipartConfigElement() {
	        MultipartConfigFactory factory = new MultipartConfigFactory();
	        return factory.createMultipartConfig();
	    }
}
