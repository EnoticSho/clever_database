--1
SELECT ad.aircraft_code, ad.model, ad.range, s.fare_conditions, count(s.seat_no)
FROM aircrafts_data ad
         JOIN seats s
              ON ad.aircraft_code = s.aircraft_code
GROUP BY ad.aircraft_code, ad.model, ad.range, s.fare_conditions;

--2
SELECT ad.model, count(s.seat_no) AS count
FROM aircrafts_data ad
         JOIN seats s
              ON ad.aircraft_code = s.aircraft_code
GROUP BY ad.model
ORDER BY count DESC
LIMIT 3;

--3
SELECT *
FROM flights f
WHERE actual_departure IS NOT NULL
  AND EXTRACT(EPOCH FROM (f.actual_departure - f.scheduled_departure)) / 3600 > 2;

--4
SELECT t.passenger_name, t.contact_data
FROM tickets t
         JOIN ticket_flights tf
              ON t.ticket_no = tf.ticket_no AND tf.fare_conditions LIKE ('Business')
         JOIN bookings b
              ON t.book_ref = b.book_ref
ORDER BY b.book_date DESC
LIMIT 10;

--5
SELECT *
FROM flights f
         LEFT JOIN ticket_flights tf
                   ON f.flight_id = tf.flight_id AND tf.fare_conditions = 'Business'
WHERE tf.ticket_no IS NULL;

--6
SELECT DISTINCT ad.airport_name, ad.city
FROM airports_data ad
         JOIN flights f
              ON f.departure_airport = ad.airport_code
WHERE f.status = 'Delayed';

--7
SELECT ad.airport_name, COUNT(f.flight_id) AS flights_count
FROM airports_data ad
         JOIN flights f
              ON f.departure_airport = ad.airport_code
GROUP BY ad.airport_name
ORDER BY flights_count DESC;

--8
SELECT *
FROM flights f
WHERE f.actual_arrival IS NOT NULL
  AND f.scheduled_arrival <> f.actual_arrival;

--9
SELECT ad.aircraft_code, ad.model, s.seat_no
FROM aircrafts_data ad
         JOIN seats s
              ON s.aircraft_code = ad.aircraft_code
                  AND s.fare_conditions <> 'Economy'
WHERE ad.model ->> 'ru' = 'Аэробус A321-200'
ORDER BY s.seat_no DESC;

--10
SELECT ad.city
FROM airports_data ad
GROUP BY ad.city
having count(ad.airport_code) > 1;

--11
SELECT t.passenger_id, t.passenger_name
FROM tickets t
         JOIN bookings b ON b.book_ref = t.book_ref
GROUP BY t.passenger_id, t.passenger_name
HAVING SUM(b.total_amount) > (SELECT AVG(total_amount)
                              FROM bookings);

--12
SELECT f.*
FROM flights f
         JOIN airports_data ad
              ON ad.airport_code = f.departure_airport AND ad.city ->> 'ru' = 'Екатеринбург'
         JOIN airports_data ad1
              ON ad1.airport_code = f.arrival_airport AND ad1.city ->> 'ru' = 'Москва'
where f.status IN ('Scheduled', 'On Time')
ORDER BY f.scheduled_departure
LIMIT 1;


--13
(SELECT * FROM bookings.ticket_flights
 ORDER BY amount ASC, ticket_no ASC
 LIMIT 1)
UNION
(SELECT * FROM bookings.ticket_flights
 ORDER BY amount DESC, ticket_no DESC
 LIMIT 1);

--14
CREATE TABLE bookings.Customers
(
    id        SERIAL PRIMARY KEY,
    firstName VARCHAR(40)  NOT NULL,
    lastName  VARCHAR(40)  NOT NULL,
    email     VARCHAR(255) NOT NULL UNIQUE,
    phone     VARCHAR(20)  NULL UNIQUE
);

--15
CREATE TABLE bookings.Orders
(
    id         SERIAL PRIMARY KEY,
    customerId INT NOT NULL,
    quantity   INT NOT NULL CHECK (quantity > 0),
    FOREIGN KEY (customerId) REFERENCES Customers (id)
);

--16
INSERT INTO bookings.Customers (firstName, lastName, email, phone)
VALUES ('Qwerty', 'Qwerty', 'qwerty@mail.ru', '1234567890'),
       ('Asd', 'Asd', 'asd@mail.ru', '1234567891'),
       ('Zxc', 'Zxc', 'zxc@mail.ru', '1234567892'),
       ('Fgh', 'Fgh', 'fgh@mail.ru', '1234567893'),
       ('Bnm', 'Bnm', 'bnm@mail.ru', '1234567895');

INSERT INTO bookings.Orders (customerId, quantity)
VALUES (1, 3),
       (2, 1),
       (3, 2),
       (1, 5),
       (4, 1);

--17
DROP TABLE bookings.orders;
DROP TABLE bookings.customers;
