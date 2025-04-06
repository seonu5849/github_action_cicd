package com.example.action.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
public class HealthController {

    @GetMapping("/health-check")
    public ResponseEntity<Map<String, Object>> checkHealthStatus(@RequestHeader(value = "X-Forwarded-For", required = false) String xForwardedFor,
                                                                 HttpServletRequest request) {
        Map<String, Object> response = new HashMap<>();

        String clientIp;

        if (xForwardedFor != null) {
            // X-Forwarded-For 헤더에 여러 개의 IP가 들어올 수도 있으므로 첫 번째 IP 추출
            clientIp = xForwardedFor.split(",")[0].trim();
        } else {
            // ALB를 거치지 않은 경우 기본 IP 확인
            clientIp = request.getRemoteAddr();
        }

        response.put("clientIp", clientIp);
        response.put("forwardedFor", xForwardedFor != null ? xForwardedFor : "N/A");
        response.put("remoteAddr", request.getRemoteAddr());

        return ResponseEntity.ok(response);
    }

}
