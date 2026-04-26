package com.learn.productcrud.repository;

import com.learn.productcrud.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

// JpaRepository gives you all DB operations for FREE:
// save(), findById(), findAll(), deleteById(), existsById() etc.
// No SQL needed!
@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    // That's it! Spring generates the implementation automatically.
}
