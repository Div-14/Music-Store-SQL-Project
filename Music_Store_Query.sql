/*	Question Set 1 - Easy */
-- Q1: Who is the senior most employee based on the job title ?
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2: Which countries have the most invoices?
SELECT COUNT(*) AS c , billing_country FROM invoice
GROUP BY billing_country
ORDER BY c DESC;

-- Q3: What are top 3 values of the total invoices?
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4: Which city has the best customers? We would like to through a promotional music
-- festival in the city we made the most money. Write a query that returns one city that 
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.
SELECT SUM(total) AS invoice_total, billing_city FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC;

-- Q5: Who is the best customer? The customer who has spent the most money will be declared 
-- the best customer. Write a query that returns the person who has spent the most money.
SELECT customer.customer_id, customer.first_name, 
customer.last_name, SUM(invoice.total) AS total 
FROM customer 
JOIN invoice ON customer.customer_id =  invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total DESC
limit 1;


-- Question Set 2 - Moderate 
-- Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.
SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN (
    SELECT track_id
    FROM track
    JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

-- Q2: Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.
SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

-- Q3: Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.
SELECT name, milliseconds
FROM track
WHERE  milliseconds >(
	SELECT AVG(milliseconds) AS avg_song_length FROM track
)
ORDER BY milliseconds DESC;


-- Question Set 3 - Advance 
-- Q1: Find how much amount spent by each customer on artists? Write a query to return 
-- customer name, artist name and total spent 
WITH customer_artist_sales AS (
	SELECT c.customer_id, ar.artist_id, c.first_name||' '||c.last_name AS customer_name,
	ar.name AS artist_name, il.unit_price*quantity AS amount 
	FROM customer c
	JOIN invoice i ON c.customer_id = i.customer_id
	JOIN invoice_line il ON i.invoice_id = il.invoice_id
	JOIN track t ON il.track_id = t.track_id
	JOIN album al ON t.album_id = al.album_id
	JOIN artist ar ON al.artist_id = ar.artist_id
)
SELECT customer_name, artist_name, SUM(amount) AS total_spent 
FROM customer_artist_sales
GROUP BY customer_name, artist_name
ORDER BY total_spent DESC;

-- Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
-- the maximum number of purchases is shared return all Genres.
WITH ranked AS (
  SELECT c.country, g.name AS genre, COUNT(*) AS purchases,
  RANK() OVER (PARTITION BY c.country ORDER BY COUNT(*) DESC) AS rnk
  FROM customer c
  JOIN invoice i ON c.customer_id = i.customer_id
  JOIN invoice_line il ON i.invoice_id = il.invoice_id
  JOIN track t ON il.track_id = t.track_id
  JOIN genre g ON t.genre_id = g.genre_id
  GROUP BY c.country, g.name
)
SELECT country, genre, purchases
FROM ranked
WHERE rnk = 1
ORDER BY country;

-- Q3: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.
WITH ranked AS (
  SELECT  c.first_name || ' ' || c.last_name AS customer_name, c.country,
  SUM(il.unit_price * il.quantity) AS total_spent,
  RANK() OVER (PARTITION BY c.country ORDER BY SUM(il.unit_price * il.quantity) DESC) AS rnk
  FROM customer c
  JOIN invoice i ON c.customer_id = i.customer_id
  JOIN invoice_line il ON i.invoice_id = il.invoice_id
  GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT customer_name, country, total_spent
FROM ranked
WHERE rnk = 1
ORDER BY country;









 

