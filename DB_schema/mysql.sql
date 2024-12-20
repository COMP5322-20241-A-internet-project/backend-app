CREATE DATABASE ONLINE_STORE if not exists;
USE ONLINE_STORE;

drop table PRODUCT_REVIEW;
drop table FAVOURITE;
drop table ORDERS;
drop table USER;
drop table PRODUCT;

CREATE TABLE USER (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    USERNAME VARCHAR(255) NOT NULL,
    PASSWORD VARCHAR(255) NOT NULL,
    ADDRESS VARCHAR(255),
    FIRST_NAME VARCHAR(255),
    LAST_NAME VARCHAR(255),
    EMAIL VARCHAR(100),
    PHONE VARCHAR(32),
    CREATE_DATE TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PRODUCT (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    NAME VARCHAR(255) NOT NULL,
    CATEGORY VARCHAR(255),
    PRICE DECIMAL(10, 2),
    BRAND VARCHAR(255),
    LIFESTAGE VARCHAR(255),
    IMG VARCHAR(255),
    WEIGHT DECIMAL(10, 2),
    DESCRIPTION VARCHAR(255),
    INGREDIENTS VARCHAR(255),
    CREATE_DATE TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE PRODUCT_REVIEW (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    PRODUCT_ID INT(255) NOT NULL,
    USER_ID INT(255) NOT NULL,
    FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCT(ID),
    FOREIGN KEY (USER_ID) REFERENCES USER(ID),
    COMMENT VARCHAR(1024) NOT NULL,
    CREATE_DATE TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE FAVOURITE (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    PRODUCT_ID INT(255) NOT NULL,
    USER_ID INT(255) NOT NULL,
    FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCT(ID),
    FOREIGN KEY (USER_ID) REFERENCES USER(ID),
    CREATE_DATE TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ORDERS (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    PRODUCT_ORDERS JSON NOT NULL,
    USER_ID INT(255) NOT NULL,
    FOREIGN KEY (USER_ID) REFERENCES USER(ID),
    TOTAL_PRICE DECIMAL(10, 2) NOT NULL,
    ADDRESS VARCHAR(255),
    FIRST_NAME VARCHAR(32),
    LAST_NAME VARCHAR(32),
    STATUS VARCHAR(64),
    CREATE_DATE TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ORDERS (PRODUCT_ORDERS, USER_ID, TOTAL_PRICE, ADDRESS, PHONE, STATUS) VALUES 
('{"1": 3, "3": 2}', 1, 70.00, 'RM1010, Sing King Building ST.125, Hong Kong', '98765432', 'pending');

SELECT PRODUCT_ORDERS FROM ORDERS;

INSERT INTO USER (USERNAME, PASSWORD, ADDRESS, FIRST_NAME, LAST_NAME, EMAIL, PHONE) VALUES 
('admin', '$2a$10$AiIp.Wz9C/X37NGC9jN9ke2kIUpS9za8NX9Ap/keUppdy1qOb4dMC', 'RM1010, Sing King Building ST.125, Hong Kong', 'Tai Man', 'Chan', 'taiman@email.com', '98765432');

INSERT INTO USER (USERNAME, PASSWORD, ADDRESS, FIRST_NAME, LAST_NAME, EMAIL, PHONE) VALUES 
('admin2', 'admin2', 'RM203, Tiu Yau House ST.23, KLN, Hong Kong', 'Ming Ting', 'Tseung', 'mingting@email.com', '65432198');

INSERT INTO PRODUCT (NAME, CATEGORY, PRICE, BRAND, LIFESTAGE, IMG, WEIGHT, DESCRIPTION, INGREDIENTS) VALUES 
('Young Rabbit Food', 'food', 35.00, 'Bunny Natures', 'child', 'product1.jpg', 10.00, 'This food loaded with natural goodness for rabbit;- Made in the USA;- No artificial colors or preservatives;- Enriched with DHA as well as digestive probiotics;- Contains fruits, vegetables, wholesome seeds, grains, nuts, legumes and much more', 'Pumpkin Seeds, Coconut, Raisins, White Millet, Oats, Sun-Cured Timothy Hay, Wheat Millet, Pyridoxine Hydrochloride, Riboflavin Supplement, Zinc Proteinate, Manganese Proteinate, Copper Proteinate, Calcium Iodate, Yucca Schidigera Extract, Sodium Selenite.');

INSERT INTO PRODUCT (NAME, CATEGORY, PRICE, BRAND, LIFESTAGE, IMG, WEIGHT, DESCRIPTION, INGREDIENTS) VALUES 
('Mature Rabbit Food', 'food', 50.00, 'Kaytees', 'adult', 'product2.jpg', 12.00, 'product2 description', 'product2 ingredients');

INSERT INTO PRODUCT (NAME, CATEGORY, PRICE, BRAND, LIFESTAGE, IMG, WEIGHT, DESCRIPTION, INGREDIENTS) VALUES 
('Child Rabbit Food', 'food', 45.00, 'Kaytees', 'child', 'product3.jpg', 12.00, 'product2 description', 'product2 ingredients');

INSERT INTO PRODUCT (NAME, CATEGORY, PRICE, BRAND, LIFESTAGE, IMG, WEIGHT, DESCRIPTION, INGREDIENTS) VALUES 
('Senior Rabbit Food', 'food', 105.00, 'Sun Seeds', 'senior', 'product4.jpg', 15.00, 'product3 description', 'product3 ingredients');

INSERT INTO PRODUCT (NAME, CATEGORY, PRICE, BRAND, LIFESTAGE, IMG, WEIGHT, DESCRIPTION, INGREDIENTS) VALUES 
('Young Rabbit Food', 'food', 40.00, 'Sun Seeds', 'child', 'product5.jpg', 13.00, 'product3 description', 'product3 ingredients');

INSERT INTO PRODUCT (NAME, CATEGORY, PRICE, BRAND, LIFESTAGE, IMG, WEIGHT, DESCRIPTION, INGREDIENTS) VALUES 
('Adult Rabbit Food', 'food', 60.00, 'Sun Seeds', 'adult', 'product6.jpg', 16.00, 'product3 description', 'product3 ingredients');

INSERT INTO PRODUCT_REVIEW (PRODUCT_ID, USER_ID, COMMENT) VALUES 
(1, 1, 'product1 review');

INSERT INTO PRODUCT_REVIEW (PRODUCT_ID, USER_ID, COMMENT) VALUES 
(1, 2, 'product1 review by admin2');

INSERT INTO PRODUCT_REVIEW (PRODUCT_ID, USER_ID, COMMENT) VALUES 
(2, 2, 'product2 review by admin2');

INSERT INTO FAVOURITE (PRODUCT_ID, USER_ID) VALUES 
(1, 1);

select * from PRODUCT 
join PRODUCT_REVIEW on PRODUCT.ID = PRODUCT_REVIEW.PRODUCT_ID
join USER on PRODUCT_REVIEW.USER_ID = USER.ID
where PRODUCT_ID = 1;

SELECT 
    p.ID AS id,
    p.NAME AS title,
    p.CATEGORY AS category,
    p.PRICE AS price,
    p.BRAND AS brand,
    p.LIFESTAGE AS lifestage,
    p.IMG AS img,
    p.WEIGHT AS weight,
    p.DESCRIPTION AS description,
    p.INGREDIENTS AS ingredients,
    JSON_ARRAYAGG(
        JSON_OBJECT(
            'id', pr.ID,
            'username', u.USERNAME,
            'comment', pr.COMMENT,
            'date', pr.CREATE_DATE
        )
    ) AS reviews
FROM 
    PRODUCT p
JOIN 
    PRODUCT_REVIEW pr ON p.ID = pr.PRODUCT_ID
JOIN 
    USER u ON pr.USER_ID = u.ID
WHERE 
    p.ID = 1
GROUP BY 
    p.ID;
