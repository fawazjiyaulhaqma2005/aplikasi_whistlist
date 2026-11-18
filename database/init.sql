CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_tokens (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    token_hash CHAR(64) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_token_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_token_expiry (expires_at)
);

CREATE TABLE IF NOT EXISTS categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(80) NOT NULL UNIQUE,
    icon VARCHAR(80) NULL
);

CREATE TABLE IF NOT EXISTS wishlists (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    destination VARCHAR(160) NOT NULL,
    location VARCHAR(160) NULL,
    category_id BIGINT UNSIGNED NULL,
    estimated_budget DECIMAL(14,2) NULL,
    priority ENUM('Rendah', 'Sedang', 'Tinggi') DEFAULT 'Sedang',
    description TEXT NULL,
    photo_url VARCHAR(500) NULL,
    status ENUM('Belum Dikunjungi', 'Sudah Dikunjungi') DEFAULT 'Belum Dikunjungi',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_wishlist_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_wishlist_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    INDEX idx_wishlist_user (user_id)
);

INSERT IGNORE INTO categories (name, icon) VALUES
('Luar Negeri', 'flight'),
('Dalam Negeri', 'landscape'),
('Pantai', 'beach'),
('Gunung', 'mountain'),
('Kota', 'city'),
('Wisata Alam', 'nature');
