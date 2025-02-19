package com.example.action.controller;

import com.example.action.domain.TestEntity;
import com.example.action.repository.TestRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

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

    @PutMapping("/{id}")
    public String testUpdate(@PathVariable Long id, String name) {
        TestEntity findTest = testRepository.findById(id)
                .orElseThrow(EntityNotFoundException::new);
        findTest.setName(name);

        return "success";
    }


}
