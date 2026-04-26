package com.learn.productcrud.dto;

import lombok.Data;

// DTO = Data Transfer Object
// This is what the API receives (request body) and sends back (response)
// Keeps your internal model separate from what's exposed to the outside world
@Data
public class ProductDTO {
    private String name;
    private String description;
    private Double price;
    private Integer quantity;
}
