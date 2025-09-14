CREATE DATABASE Music_Prjects;

select*from album$;

-- Who is the senior most employee based on job title?--
SELECT TOP 1 *FROM employee$
ORDER BY levels DESC;

-- Which country has the most invoices?--
SELECT * FROM invoice$
SELECT COUNT(*) AS Invoice_Nmbr,billing_country from invoice$
group by billing_country order by
Invoice_Nmbr desc;

-- what are top 3 value of total invoices?--

select top 3 total from invoice$ order by
total desc;


--which city has the best customer?Which city has the highest sum of invoice totals?--
--Return both the city name and sum of all invoice totals--

select*from invoice$;
select sum(total) AS Invoice_Total, billing_city
from invoice$ group by billing_city
order by Invoice_Total desc


-- Who is the best customer? Returns the person who has spent the most money--
select * from customer$;

SELECT TOP 1 c.customer_id, c.first_name, c.last_name, 
 SUM(i.total) AS Total12 FROM customer$ c
JOIN invoice$ i 
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY Total12 DESC;


--write query to return the email, first name, ;last name, and genre of all rock music listners in alphabetical ordered start feom email A--
select *from customer$

SELECT DISTINCT 
c.email, 
c.first_name, 
c.last_name 
FROM customer$ c
JOIN invoice$ i ON c.customer_id = i.customer_id
JOIN invoice_line$ il ON i.invoice_id = il.invoice_id
WHERE il.track_id IN (
    SELECT t.track_id 
	FROM track$ t
    JOIN genre$ g ON t.genre_id = g.genre_id
    WHERE g.name = 'Rock') 
	ORDER BY c.email;

-- Query that returns the artist name and total track count of the top 10 rock band--
select*from artist$;

SELECT TOP 10 ar.artist_id, ar.name,COUNT(t.track_id) AS Number_of_songs
FROM track$ t
JOIN album$ al ON al.album_id = t.album_id
JOIN artist$ ar ON ar.artist_id = al.artist_id
JOIN genre$ g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
GROUP BY ar.artist_id, ar.name
ORDER BY Number_of_songs DESC;


-- returns all the track name that have a song length longer than the average song length--
-- return the name and milliseconds for each track. Order by the song length with the longest-- 
--songs listed first--

select name, milliseconds
from track$
where milliseconds > (
select avg(milliseconds) AS Avg_trck_length
from track$)
order by milliseconds desc;



SELECT DISTINCT c.email AS Email, c.first_name AS FirstName, c.last_name AS LastName, g.name AS GenreName
FROM customer$ c
JOIN invoice$ i  ON i.customer_id = c.customer_id
JOIN invoice_line$ il ON il.invoice_id = i.invoice_id
JOIN track$ t ON t.track_id = il.track_id
JOIN genre$ g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock' ORDER BY c.email;


Advance qiestion
1-- Amount spent by each customer on artists? Return the customer name, artist name and total spent--


WITH Best_selling_artist AS (SELECT  ar.artist_id AS Artist_ID,  ar.name AS Artist_Name, 
SUM(il.unit_price * il.quantity) AS Total_Sales FROM invoice_line$ il
    JOIN track$ t ON t.track_id = il.track_id
    JOIN album$ a ON a.album_id = t.album_id
    JOIN artist$ ar ON ar.artist_id = a.artist_id
    GROUP BY ar.artist_id, ar.name) SELECT TOP 3 * FROM Best_selling_artist
ORDER BY Total_Sales DESC;

select c.customer_id, c.first_name, bsa.artist_name, sum(il.unit_price*il.quantity) AS amount_spent
from invoice$ i
join customer$ c on c.customer_id=i.customer_id
join invoice_line$ il on il.invoice_id=i.invoice_id
join track$ t on t.track_id=il.track_id
join album$ al on al.album_id=t.album_id
join Best_selling_artist bsa on bsa.artist_id=al.album_id
group by c.customer_id, c.first_name, bsa.Artist_Name
order by amount_spent desc;

WITH Best_selling_artist AS (
    SELECT 
        ar.artist_id AS Artist_ID, 
        ar.name AS Artist_Name, 
        SUM(il.unit_price * il.quantity) AS Total_Sales
    FROM invoice_line$ il
    JOIN track$ t ON t.track_id = il.track_id
    JOIN album$ a ON a.album_id = t.album_id
    JOIN artist$ ar ON ar.artist_id = a.artist_id
    GROUP BY ar.artist_id, ar.name
)
SELECT 
    c.customer_id, 
    c.first_name, 
    bsa.Artist_Name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice$ i
JOIN customer$ c ON c.customer_id = i.customer_id
JOIN invoice_line$ il ON il.invoice_id = i.invoice_id
JOIN track$ t ON t.track_id = il.track_id
JOIN album$ al ON al.album_id = t.album_id
JOIN Best_selling_artist bsa ON bsa.Artist_ID = al.artist_id
GROUP BY c.customer_id, c.first_name, bsa.Artist_Name
ORDER BY amount_spent DESC;



2--Find out most popular music genre for each country.Return each country along with top genre--
--maximum number of purchase is shared--

WITH popular_genre AS 
(
     SELECT COUNT(il.quantity) AS purchases,c.country, g.name, g.genre_id, 
	 ROW_NUMBER() OVER (PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS Rowno 
	 FROM invoice_line$ il
    JOIN invoice$ i ON i.invoice_id = il.invoice_id
    JOIN customer$ c ON c.customer_id = i.customer_id 
    JOIN track$ t ON t.track_id = il.track_id
    JOIN genre$ g ON g.genre_id = t.genre_id
    GROUP BY c.country, g.name, g.genre_id
)
SELECT *FROM popular_genre 
WHERE Rowno <= 1 
ORDER BY country asc, purchases desc;


3-- query that determines the customer that has spent on music for each country
--return that country along with the top customer and how much they have spent--
--For countries where the top amount spent is shared, provide all custoers who spent this amount--

with customer_with_country AS(select c.customer_id, c.first_name,c.last_name,i.billing_country,
SUM(i.total) AS total_spending,row_number() over(partition by billing_country 
order by SUM(i.total)desc) AS RowNo 
from invoice$ i
join customer$ c ON c.customer_id=i.customer_id
group by c.customer_id, c.first_name,c.last_name,i.billing_country
)
select * from customer_with_country where RowNo <=1 
order by billing_country ASC, total_spending desc



c.customer_id,
    c.first_name,
    c.last_name,
    c.billing_country,
    c.total_spending 
country_max_spending AS(
      select 
	  billing_country, 
	  max(total_spending) AS max_spending
	  from customer_with_country
	  group by billing_country
	  )
    select  
	cc.billing_country, 
	cc.total_spending, 
	cc.first_name, 
	cc.last_name, 
	cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country=ms.billing_country
where cc.total_spending=ms.max_spending
order by cc.billing_country;


