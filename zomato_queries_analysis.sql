select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;

--1) what is the total amount that customer spent on zomato?
select s.userid,sum(pr.price)as amount from
sales s join product pr on s.product_id=pr.product_id group by s.userid order by s.userid

--2) how many days has each customer visited zomato?
select userid,count(distinct created_date)as distinct_days from sales group by userid

--3) what was the first product purchased by each customer?
select * from 
(select *, rank() over(partition by userid order by created_date) as rn from sales) x where x.rn =1

--4) what is the most purchased item on the menu and how many times was it purchased by all customers?
select userid,count(product_id)as most_pur from sales where product_id=
(select product_id from sales group by  product_id order by count(product_id) desc limit 1)
group by userid

--5) what item was most popular for each cutomer?
select * from
(select* , rank() over(partition by userid order by cnt desc) rnk from
(select userid, product_id, count(product_id) cnt from sales group by userid,product_id)x)y
where rnk=1

--6) which item was purchased first by the customer after they became member?
select*from
(select*, rank() over(partition by userid order by created_date) rnk from
(select s.userid,s.created_date,s.product_id,gs.gold_signup_date from
sales s join goldusers_signup gs on s.userid=gs.userid and created_date>=gold_signup_date)x)y
where rnk=1;

--7) which item was purchased first by the customer before they became member?
select*from
(select*, rank() over(partition by userid order by created_date desc) rnk from
(select s.userid,s.created_date,s.product_id,gs.gold_signup_date from
sales s join goldusers_signup gs on s.userid=gs.userid and created_date<=gold_signup_date)x)y
where rnk=1;

--8) what is the total order and amount spent for each member before they became a member?
select userid,count(product_id) cnt,sum(price) amount from
(select s.userid,s.created_date,s.product_id,pr.price,gs.gold_signup_date from sales s join product pr on s.product_id=pr.product_id
join goldusers_signup gs on s.userid=gs.userid and created_date<=gold_signup_date)x
group by userid order by userid

/* 9) If buying each product generates point for eg 5rs=2 zomato points and each product has different purchasing points
for eg for p1 5rs=1 zp ,for p2 10rs=5 zp and for p3 5rs=1 zp then calculate points collected by each customer and for which product
most points have been given till now */

--points by each customer
select b.userid , sum(b.total_points) u_pnts from
(select z.userid,z.product_id, amnt/points as total_points from
(select y.*,case when product_id=1 then 5 when product_id =2 then 2 when product_id=3 then 5 else 0 end as points from
(select x.userid,x.product_id,sum(x.price) amnt from
(select s.*,pr.price from sales s join product pr on s.product_id=pr.product_id)x
group by x.userid,x.product_id)y)z)b group by b.userid order by b.userid

--product with most points
select e.* from
(select d.*, rank() over(order by d.u_pnts desc) rnk from
(select b.product_id , sum(b.total_points) u_pnts from
(select z.userid,z.product_id, amnt/points as total_points from
(select y.*,case when product_id=1 then 5 when product_id =2 then 2 when product_id=3 then 5 else 0 end as points from
(select x.userid,x.product_id,sum(x.price) amnt from
(select s.*,pr.price from sales s join product pr on s.product_id=pr.product_id)x
group by x.userid,x.product_id)y)z)b group by b.product_id)d) e
where rnk=1;

/*10) In the first one year after the customer joins the gold program(including join date) irrespective of what customer
has purchased they earn 5 zp on every 10 rs the spent. Calculate who earned more customer 1 or 3 and 
the total zp earned in their first year*/

select b.*, price/2 zp_pnt from
(select s.userid,s.created_date,s.product_id,gs.gold_signup_date,pr.price from
sales s join product pr on s.product_id=pr.product_id join
goldusers_signup gs on s.userid=gs.userid and created_date>=gold_signup_date and created_date<gold_signup_date+365)b


