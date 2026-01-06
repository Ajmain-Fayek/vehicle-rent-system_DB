# Database Schema for **_Vehicle Rental System_**

---

## Schema ERD: <https://dbdiagram.io/d/Library_Management_ERD-6947a8184bbde0fd74e9d608>

## Viva Videos: <>

---

## Documentation

---

### Create the database

```sql
CREATE DATABASE vehicle_rental_db;
```

---

#### Define the enums

```sql
CREATE TYPE user_role AS enum('admin', 'customer');

CREATE TYPE vehicle_type AS enum('car', 'bike', 'truck');

CREATE TYPE vehicle_status AS enum('available', 'rented', 'maintenance');

CREATE TYPE booking_status AS enum('pending', 'confirmed', 'complete', 'cancelled');
```

---

### Create Tables

---

#### Users Table

```sql
CREATE TABLE IF NOT EXISTS users (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name varchar(150),
  email varchar(200) UNIQUE NOT NULL,
  password varchar(255) NOT NULL,
  phone varchar(15),
  role user_role DEFAULT ('customer')
);
```

#### Create index on users_email

```sql
CREATE INDEX idx_users_email ON users (email);
```

---

#### Vehicle Tables

```sql
CREATE TABLE IF NOT EXISTS vehicles (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name varchar DEFAULT ('unnamed vehicle'),
  type vehicle_type,
  registration_number varchar UNIQUE NOT NULL,
  rent_price decimal(6, 2) NOT NULL,
  availability_status vehicle_status DEFAULT ('available')
);
```

#### Create index on vehicles_registration_number

```sql
CREATE INDEX idx_vehicles_registration ON vehicles (registration_number);
```

---

#### Bookings Table

```sql
CREATE TABLE IF NOT EXISTS bookings (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES users (id),
  vehicle_id uuid REFERENCES vehicles (id),
  start_date timestamptz NOT NULL,
  end_date timestamptz NOT NULL,
  status booking_status DEFAULT ('pending'),
  total_cost decimal(10, 2) NOT NULL
);
```

#### Create index on bookigs_user-id_vehicle-id

```sql
CREATE INDEX idx_bookings_ref ON bookings (user_id, vehicle_id);
```

---

#### Retrive booking information along with customer name & vehicle name

As bookings table contains **_REFERENCE_** `foreign key` constraints with `users` table and `vehicle` table to retrive bookings information along with customer name and vehcile name we can `join` bookings table with users table and vechile table to get the right user and vehicle.

```sql
SELECT
  b.id AS "Booking ID",
  b.start_date AS "Start Date",
  b.end_date AS "End Date",
  b.status AS "Booking Status",
  b.total_cost AS "Total Cost",
  u.name AS "Customer Name",
  v.name AS "Vehicle Name"
FROM
  bookings AS b
  JOIN users AS u ON b.user_id = u.id
  JOIN vehicles AS v ON b.vehicle_id = v.id;
```

---

#### Find all vehicles that have never been booked

`NOT EXISTS` will return true/false. If `bookings` has/had vehciles id, then return true, if not then return false. If `NOT EXISTS` is true then retrive the vehicle tupple. If not then skip that tuple.

```sql
SELECT
  *
FROM
  vehicles
WHERE
  NOT EXISTS (
    SELECT
      vehicle_id
    FROM
      bookings
    WHERE
      vehicle_id = vehicles.id
  );
```

---

#### Retrive all available vehicles of a specific type

`vehicles` table contains 2 ENUM type attributes. `type` = ['car', 'bike', 'truck'] & `availability_status` = ['available', 'rented', 'maintenance']. We can simply define the types in `WHERE` cluse.

```sql
SELECT
  *
FROM
  vehicles
WHERE
  type = 'bike'
  AND availability_status = 'available';
```

---

#### Find the total number of bookings for each vehicle and display only those vehicles that have more than 2 bookings

We will join `vehicles` table with `bookings` table as we need vehicles name. We need to count the tuples of each distinct vehicles from bookings table (`...COUNT(b.vehicle_id) AS Total Bookings...`). Which will be our ***Total bookings*** number. Then Group the vehicle tuple with their name. At last we will do filtering using `HAVING` clause.

```sql
SELECT
  v.name AS "Vehicle Name",
  count(b.vehicle_id) AS "Total Bookings"
FROM
  vehicles AS v
  JOIN bookings AS b ON b.vehicle_id = v.id
GROUP BY
  v.name
HAVING
  count(b.vehicle_id) > 2;
```
