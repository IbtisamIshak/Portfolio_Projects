/* 

Restaurant Order Analysis in SQL 

*/



---------------------------------------------------------------------------------------------
--OBJECTIVE 1: Explore the menu_items table to get an idea of what's on the menu.

--view the table

Select *
From restaurant_db..menu_items

--find the number of items on the menu

Select Count(*)
From restaurant_db..menu_items

--what are the least and most expensive items on the menu?

Select *
From restaurant_db..menu_items
Order by price

Select *
From restaurant_db..menu_items
Order by price desc

--how many Italian dishes on the menu? 

Select Count(*)
From restaurant_db..menu_items
Where category = 'Italian'

--what are the least and most expensive Italian dishes on the menu?

Select *
From restaurant_db..menu_items
Where category = 'Italian'
Order by price 

Select *
From restaurant_db..menu_items
Where category = 'Italian'
Order by price desc

--how many dishes are in each category? what is the average dish price for each category?

Select category, Count(item_name) as number_dishes, AVG(price) as avg_price
From restaurant_db..menu_items
Group by category 

---------------------------------------------------------------------------------------------
--OBJECTIVE 2: Explore the order_details table to get an idea of the data that's been collected.

Select *
From restaurant_db..order_details

--what is the date range of the table

Select MIN(order_date), MAX(order_date)
From restaurant_db..order_details


--how many orders were made within this date range?

Select COUNT(Distinct(order_id))
From restaurant_db..order_details

--how many items were ordered within this date range?

Select COUNT(order_details_id)
From restaurant_db..order_details

--which orders has the most number of items?

Select order_id, COUNT(item_id) as num_item
From restaurant_db..order_details
Group by order_id
order by COUNT(item_id) desc


--how many orders had more than 12 items?

With num_order as 
(
Select COUNT(item_id) as num_item
From restaurant_db..order_details
Group by order_id
having COUNT(item_id) > 12
)

Select COUNT(*) 
From num_order


---------------------------------------------------------------------------------------------
--OBJECTIVE 3: Use both tables to understand how customers are reacting to the new menu 

--combine the menu_item and order_details tables into a single table

Select *
From restaurant_db..order_details a
Join restaurant_db..menu_items b
	On a.item_id = b.menu_item_id


--what were the least and most ordered items? what categories were they in?

-----least ordered
Select b.item_name,Count(a.item_id) as total_purchases, b.category
From restaurant_db..order_details a
Join restaurant_db..menu_items b
	On a.item_id = b.menu_item_id
Group by b.item_name, b.category
Order by Count(a.item_id) 

-----most ordered
Select b.item_name, Count(a.item_id) as total_purchases
From restaurant_db..order_details a
Join restaurant_db..menu_items b
	On a.item_id = b.menu_item_id
Group by b.item_name, b.category
Order by Count(a.item_id) desc

--what were the top 5 orders that spent the most money?

With top_orders as
(
Select a.order_id, SUM(b.price) as total_spent
From restaurant_db..order_details a
Join restaurant_db..menu_items b
	On a.item_id = b.menu_item_id
Group by a.order_id 
--Order by SUM(b.price) desc
)
Select top 5 *
From top_orders 
order by total_spent desc

--view the detail of the highest spent order. what insight can you gain?

Select *
From restaurant_db..order_details a
Join restaurant_db..menu_items b
	On a.item_id = b.menu_item_id
where order_id = 440

Select b.category, Count(item_id) as num_items
From restaurant_db..order_details a
Join restaurant_db..menu_items b
	On a.item_id = b.menu_item_id
where order_id = 440
Group by b.category
-----Customer who made the biggest order prefer italian dishes

--view details of the top 5 highest spent orders. what insight can you gain?

Select b.category, Count(item_id) as num_items
From restaurant_db..order_details a
Join restaurant_db..menu_items b
	On a.item_id = b.menu_item_id
where order_id in (440, 2075, 1957, 330, 2675)
Group by b.category
-----Customers who purchase big orders prefer to order italian dishes

Select a.order_id, b.category, Count(item_id) as num_items
From restaurant_db..order_details a
Join restaurant_db..menu_items b
	On a.item_id = b.menu_item_id
where a.order_id in (440, 2075, 1957, 330, 2675)
Group by b.category, order_id
