package com.supermarket.supermarket;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class BCryptGenerator {
    public static void main(String[] args) {
        if (args.length == 0) {
            System.out.println("Usage: java BCryptGenerator <password>");
            return;
        }
        String password = args[0];
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String hash = encoder.encode(password);
        System.out.println("BCrypt Hash for '" + password + "': " + hash);
    }
}