package com.example.action.controller;

import com.example.action.domain.TestEntity;
import com.example.action.repository.TestRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/test")
@RequiredArgsConstructor
public class TestController {

    private final TestRepository testRepository;

    @GetMapping
    public List<TestEntity> test() {
        return testRepository.findAll();
    }

    @PostMapping
    public String testInsert(String name) {
        TestEntity test = TestEntity.builder().name(name).build();
        testRepository.save(test);

        return "success";
    }


}
