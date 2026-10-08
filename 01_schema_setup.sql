CREATE DATABASE sneaker_economics;
use sneaker_economics;

CREATE TABLE IF NOT EXISTS brands (
									id INT PRIMARY KEY AUTO_INCREMENT,
                                    name VARCHAR(50) NOT NULL UNIQUE,
                                    headquarters VARCHAR(100))
                                    ;
                                    
CREATE TABLE IF NOT EXISTS collaborators (
									id INT PRIMARY KEY AUTO_INCREMENT,
                                    name VARCHAR(100) NOT NULL UNIQUE,
                                    primary_genre VARCHAR(50))
                                    ;
                                    
                                    
CREATE TABLE IF NOT EXISTS annual_financials (
									id INT PRIMARY KEY AUTO_INCREMENT,
                                    brand_id INT,
                                    fiscal_year INT NOT NULL,
                                    total_revenue DECIMAL(10, 2) NOT NULL CHECK (total_revenue >= 0),
                                    footwear_revenue DECIMAL(10, 2),
                                    operating_income DECIMAL(10, 2),
                                    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE,
                                    UNIQUE KEY uq_brand_year (brand_id, fiscal_year))
                                    ;
                                    
CREATE TABLE IF NOT EXISTS partnerships (
									id INT PRIMARY KEY KEY AUTO_INCREMENT,
                                    collaborator_id INT NOT NULL,
                                    brand_id INT NOT NULL, 
                                    sub_brand VARCHAR(100) NOT NULL,
                                    start_year INT NOT NULL,
                                    end_year INT,
                                    est_peak_annual_rev DECIMAL(10, 2) CHECK (est_peak_annual_rev >= 0),
                                    
                                    CONSTRAINT time_frame CHECK (end_year IS NULL OR end_year >= start_year),
                                    FOREIGN KEY (collaborator_id) REFERENCES collaborators(id) ON DELETE CASCADE,
                                    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE)
                                    ;