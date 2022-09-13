-- CREATE TABLE w_book(
--     book_id INT PRIMARY KEY,
--     title [VARCHAR](50),
--     author [VARCHAR](30),
--     price [DECIMAL](8, 2),
--     amount [INT]
-- );

-- INSERT INTO book (book_id, title, author, price, amount) 
-- VALUES ('1', 'Мастер и Маргарита', 'Булгаков М.А.', '670.99', '3');
-- SELECT * FROM book;

-- SELECT title, price, 
--     (price*18/100)/(1+18/100) AS tax, 
--     price/(1+18/100) AS price_tax 
-- FROM book;

-- SELECT title, 
--     price, 
--     ROUND((price*18/100)/(1+18/100),2) AS tax, 
--     ROUND(price/(1+18/100),2) AS price_tax 
-- FROM book;

-- SELECT title, author, amount, 
--     ROUND(price*0.7,2) AS new_price
-- FROM book;

-- INSERT INTO book (book_id, title, author, price, amount) 
-- VALUES ('2', 'Белая гвардия', 'Булгаков М.А.', '540.50', '5');
-- INSERT INTO book (book_id, title, author, price, amount) 
-- VALUES ('3', 'Идиот', 'Достоевский Ф.М.', '460.00', '10');
-- INSERT INTO book (book_id, title, author, price, amount) 
-- VALUES ('4', 'Братья Карамазовы', 'Достоевский Ф.М.', '799.01', '2');

-- SELECT * FROM book;

-- SELECT title, 
--     price, 
--     ROUND((price*18/100)/(1+18/100),2) AS tax, 
--     ROUND(price/(1+18/100),2) AS price_tax 
-- FROM book;

-- SELECT title, author, amount, 
--     ROUND(price*0.7,2) AS new_price
-- FROM book;

-- SELECT * FROM book;

-- SELECT author, title,
--     ROUND(
--         CASE
--         WHEN author = 'Булгаков М.А.' THEN price * 1.1
--         WHEN author = 'Есенин С.А.' THEN price * 1.05
--         ELSE price END,
--         2) AS new_price
-- FROM book;

-- SELECT author, title, price
-- FROM book
-- WHERE amount < 10;

-- SELECT title, author, price, amount
-- FROM book
-- WHERE (price < 500 OR price > 600) AND (price * amount = 3000 OR price * amount > 3000);

-- SELECT title, author
-- FROM book
-- WHERE (price BETWEEN 540.50 AND 800) AND amount IN(2, 3, 5, 7)

-- SELECT author, title
-- FROM book
-- WHERE amount BETWEEN 2 AND 14
-- ORDER BY author DESC, title;

-- -- не работает!!
-- SELECT title, author
-- FROM book 
-- WHERE title LIKE "%_ _%"
--     AND author LIKE "%С.%"
-- ORDER BY title;

-- SELECT DISTINCT author AS Автор, COUNT(author) AS Различных_книг, SUM(amount) AS Количество_экземпляров
-- FROM book
-- GROUP BY author;

-- SELECT author, MIN(price) AS Минимальная_цена, MAX(price) AS Максимальная_цена, AVG(price) AS Средняя_цена
-- FROM book
-- GROUP BY author;

-- SELECT author, 
--     SUM(price * amount) AS Стоимость, 
--     ROUND(SUM(price * amount)*(18/100)/(1+18/100), 2) AS НДС, 
--     ROUND(SUM(price * amount)/(1+18/100), 2) AS Стоимость_без_НДС
-- FROM book
-- GROUP BY author;

