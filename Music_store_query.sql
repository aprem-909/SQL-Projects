/*	Question Set 1 - Easy */
/* Q1: who is the senior most employee based in job title? */

select employee_id, last_name, first_name, title, levels from employee
order by 5 desc
limit 1;

/* Q2: Which countries have the most Invoices? */

select count(*) as most_invoices,billing_country from invoice
group by 2
order by 1 desc

/* Q3: What are top 3 values of total invoice? */

select total from invoice
order by 1 desc

/* Q4: Which city has the best customers? We would like to throw a promotional 
Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select sum(total) as invoice_total, billing_city from invoice
group by 2
order by 1 desc
limit 1

/* Q5: Who is the best customer? The customer who has spent the most money will be 
declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select customer.customer_id, first_name, last_name, sum(total) as total_money_spent from customer
join invoice on customer.customer_id = invoice.customer_id
group by 1
order by 4 desc
limit 1

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct c.email as email, c.first_name, c.last_name,genre.name from customer as c
join invoice on c.customer_id = invoice.invoice_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'ROCK'
order by 1

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id,artist.name, genre.name, count(artist.artist_id) as no_of_songs
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'ROCK'
group by 1,2,3
order by 4 desc
limit 10

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length 
with the longest songs listed first. */

select track.name, track.milliseconds
from track
where milliseconds > 
(select avg(milliseconds) as average from track)
order by 2 desc

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return 
customer name, artist name and total spent */

with best_selling_artist as (
select artist.artist_id, artist.name, sum(invoice_line.unit_price * invoice_line.quantity) as total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 1)
	
select customer.first_name,customer.last_name,customer.customer_id ,bsa.name, 
sum(invoice_line.unit_price * invoice_line.quantity) as total_spent
	from customer 
	join invoice on invoice.customer_id = customer.customer_id
	join invoice_line on invoice_line.invoice_id = invoice.invoice_id
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join best_selling_artist as bsa on bsa.artist_id =album.artist_id
	group by 1,2,3,4
	order by 5 desc
	
/* Q2: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country 
along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */	

with popular_music_genre as(
select count (invoice_line.quantity) as purchases,customer.country, genre.name, genre.genre_id,
	row_number() over(partition by customer.country order by count (invoice_line.quantity) desc) as rowno
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on invoice.customer_id = customer.customer_id
	join track on track.track_id =invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_music_genre 
where rowno <=1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customer_music_country as(
select customer.customer_id, customer.first_name, customer.last_name, billing_country, sum(total),
	row_number() over(partition by billing_country order by sum(total) desc) as Rowno
	from customer
	join invoice on invoice.customer_id = customer.customer_id
	group by 1,2,3,4
	order by 4 asc,5 desc
)
select * from customer_music_country
where Rowno <= 1

