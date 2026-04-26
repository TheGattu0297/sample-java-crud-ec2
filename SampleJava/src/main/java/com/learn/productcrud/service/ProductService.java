package com.learn.productcrud.service;

import com.learn.productcrud.dto.ProductDTO;
import com.learn.productcrud.exception.ProductNotFoundException;
import com.learn.productcrud.model.Product;
import com.learn.productcrud.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

// Service layer = business logic lives here
// Controller calls Service, Service calls Repository
@Service
@RequiredArgsConstructor  // Lombok: injects dependencies via constructor
public class ProductService {

    private final ProductRepository productRepository;

    // ── CREATE ──────────────────────────────────────────
    public Product createProduct(ProductDTO dto) {
        Product product = new Product();
        product.setName(dto.getName());
        product.setDescription(dto.getDescription());
        product.setPrice(dto.getPrice());
        product.setQuantity(dto.getQuantity());
        return productRepository.save(product);
    }

    // ── READ ALL ─────────────────────────────────────────
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    // ── READ ONE ─────────────────────────────────────────
    public Product getProductById(Long id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new ProductNotFoundException(id));
    }

    // ── UPDATE ───────────────────────────────────────────
    public Product updateProduct(Long id, ProductDTO dto) {
        Product existing = getProductById(id);  // throws 404 if not found
        existing.setName(dto.getName());
        existing.setDescription(dto.getDescription());
        existing.setPrice(dto.getPrice());
        existing.setQuantity(dto.getQuantity());
        return productRepository.save(existing);
    }

    // ── DELETE ───────────────────────────────────────────
    public void deleteProduct(Long id) {
        if (!productRepository.existsById(id)) {
            throw new ProductNotFoundException(id);
        }
        productRepository.deleteById(id);
    }
}
