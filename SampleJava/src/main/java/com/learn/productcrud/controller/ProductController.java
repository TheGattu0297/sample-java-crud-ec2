package com.learn.productcrud.controller;

import com.learn.productcrud.dto.ProductDTO;
import com.learn.productcrud.model.Product;
import com.learn.productcrud.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// Controller = the front door of your app
// It receives HTTP requests and returns HTTP responses
@RestController
@RequestMapping("/api/products")  // All endpoints start with /api/products
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;

    // ── 1. CREATE a product ──────────────────────────────
    // POST /api/products
    // Body: { "name": "iPhone", "description": "...", "price": 999.99, "quantity": 10 }
    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody ProductDTO dto) {
        Product created = productService.createProduct(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);  // 201
    }

    // ── 2. GET all products ──────────────────────────────
    // GET /api/products
    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() {
        return ResponseEntity.ok(productService.getAllProducts());  // 200
    }

    // ── 3. GET one product by ID ─────────────────────────
    // GET /api/products/1
    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        return ResponseEntity.ok(productService.getProductById(id));  // 200
    }

    // ── 4. UPDATE a product ──────────────────────────────
    // PUT /api/products/1
    // Body: { "name": "iPhone 15", "description": "...", "price": 1099.99, "quantity": 5 }
    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(@PathVariable Long id,
                                                  @RequestBody ProductDTO dto) {
        return ResponseEntity.ok(productService.updateProduct(id, dto));  // 200
    }

    // ── 5. DELETE a product ──────────────────────────────
    // DELETE /api/products/1
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();  // 204
    }
}
