-- -------------------
-- | Create database |
-- -------------------
CREATE DATABASE vehicle_rental_db;

-- ----------------
-- | Define enums |
-- ----------------
CREATE TYPE user_role AS enum('admin', 'customer');

CREATE TYPE vehicle_type AS enum('car', 'bike', 'truck');

CREATE TYPE vehicle_status AS enum('available', 'rented', 'maintenance');

CREATE TYPE booking_status AS enum('pending', 'confirmed', 'complete', 'cancelled');

-- -----------------------------
-- |       Create tables       |
-- -----------------------------
-- Users table
CREATE TABLE IF NOT EXISTS users (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name varchar(150),
  email varchar(200) UNIQUE NOT NULL,
  password varchar(255) NOT NULL,
  phone varchar(15),
  role user_role DEFAULT ('customer')
);

-- Index on users email
CREATE INDEX idx_users_email ON users (email);

-- Vehicle table
CREATE TABLE IF NOT EXISTS vehicles (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name varchar DEFAULT ('unnamed vehicle'),
  type vehicle_type,
  registration_number varchar UNIQUE NOT NULL,
  rent_price decimal(6, 2) NOT NULL,
  availability_status vehicle_status DEFAULT ('available')
);

-- Index on vehicle registration number
CREATE INDEX idx_vehicles_registration ON vehicles (registration_number);

-- Bookings table
CREATE TABLE IF NOT EXISTS bookings (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES users (id),
  vehicle_id uuid REFERENCES vehicles (id),
  start_date timestamptz NOT NULL,
  end_date timestamptz NOT NULL,
  status booking_status DEFAULT ('pending'),
  total_cost decimal(10, 2) NOT NULL
);

-- Index on user_id & vehicle_id
CREATE INDEX idx_bookings_ref ON bookings (user_id, vehicle_id);

-- --------------------------------------------------------------------------------
-- |  JOIN - Retrive booking information along with customer name & vehicle name  |
-- --------------------------------------------------------------------------------
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

-- ------------------------------------------------------------
-- |  EXISTS - Find all vehicles that have never been booked  |
-- ------------------------------------------------------------
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

-- ---------------------------------------------------------------
-- |  WHERE - Retrive all available vehicles of a specific type  |
-- ---------------------------------------------------------------
SELECT
  *
FROM
  vehicles
WHERE
  type = 'bike'
  AND availability_status = 'available';

-- -----------------------------------------------------------------------------
-- |  GROUP BY and Having - Retrive all available vehicles of a specific type  |
-- -----------------------------------------------------------------------------
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

-- -----------------------------
-- |  Drop Database or Table   |
-- -----------------------------
DROP DATABASE vehicle_rental_db;

DROP TABLE IF EXISTS users;

DROP INDEX idx_users_email;

DROP TABLE IF EXISTS vehicles;

DROP INDEX idx_vehicles_registration;

DROP TABLE IF EXISTS bookings;

DROP INDEX idx_bookings_ref;

-- -----------------------------
-- |  Insert Values (Users)    |
-- -----------------------------
INSERT INTO
  users (name, email, password, phone, role)
VALUES
  (
    'John Doe',
    'john@example.com',
    'hash_01',
    '555-0101',
    'customer'
  ),
  (
    'Jane Smith',
    'jane@example.com',
    'hash_02',
    '555-0102',
    'admin'
  ),
  (
    'Alice Johnson',
    'alice@example.com',
    'hash_03',
    '555-0103',
    'customer'
  ),
  (
    'Bob Brown',
    'bob@example.com',
    'hash_04',
    '555-0104',
    'customer'
  ),
  (
    'Charlie Davis',
    'charlie@example.com',
    'hash_05',
    '555-0105',
    'customer'
  ),
  (
    'Diana Prince',
    'diana@example.com',
    'hash_06',
    '555-0106',
    'customer'
  ),
  (
    'Edward Norton',
    'edward@example.com',
    'hash_07',
    '555-0107',
    'customer'
  ),
  (
    'Fiona Gallagher',
    'fiona@example.com',
    'hash_08',
    '555-0108',
    'customer'
  ),
  (
    'George Miller',
    'george@example.com',
    'hash_09',
    '555-0109',
    'customer'
  ),
  (
    'Hannah Abbott',
    'hannah@example.com',
    'hash_10',
    '555-0110',
    'customer'
  ),
  (
    'Ian Wright',
    'ian@example.com',
    'hash_11',
    '555-0111',
    'customer'
  ),
  (
    'Julia Roberts',
    'julia@example.com',
    'hash_12',
    '555-0112',
    'customer'
  ),
  (
    'Kevin Hart',
    'kevin@example.com',
    'hash_13',
    '555-0113',
    'customer'
  ),
  (
    'Laura Palmer',
    'laura@example.com',
    'hash_14',
    '555-0114',
    'customer'
  ),
  (
    'Mike Ross',
    'mike@example.com',
    'hash_15',
    '555-0115',
    'admin'
  ),
  (
    'Nina Simone',
    'nina@example.com',
    'hash_16',
    '555-0116',
    'customer'
  ),
  (
    'Oscar Isaac',
    'oscar@example.com',
    'hash_17',
    '555-0117',
    'customer'
  ),
  (
    'Peter Parker',
    'peter@example.com',
    'hash_18',
    '555-0118',
    'customer'
  ),
  (
    'Quinn Fabray',
    'quinn@example.com',
    'hash_19',
    '555-0119',
    'customer'
  ),
  (
    'Riley Reid',
    'riley@example.com',
    'hash_20',
    '555-0120',
    'customer'
  );

-- -----------------------------
-- | Insert values (vehicles) |
-- -----------------------------
INSERT INTO
  vehicles (
    name,
    type,
    registration_number,
    rent_price,
    availability_status
  )
VALUES
  (
    'Toyota Corolla',
    'car',
    'ABC-1234',
    45.00,
    'available'
  ),
  (
    'Honda Civic',
    'car',
    'DEF-5678',
    50.00,
    'available'
  ),
  (
    'Ford F-150',
    'truck',
    'TRK-9012',
    85.50,
    'available'
  ),
  (
    'Yamaha R1',
    'bike',
    'BIK-3456',
    30.00,
    'available'
  ),
  (
    'Tesla Model 3',
    'car',
    'ELE-7890',
    95.00,
    'available'
  ),
  (
    'Chevrolet Silverado',
    'truck',
    'TRK-1122',
    80.00,
    'maintenance'
  ),
  (
    'Kawasaki Ninja',
    'bike',
    'BIK-3344',
    25.00,
    'available'
  ),
  (
    'BMW 3 Series',
    'car',
    'LUX-5566',
    75.00,
    'rented'
  ),
  (
    'Mercedes Sprinter',
    'truck',
    'VAN-7788',
    90.00,
    'available'
  ),
  (
    'Harley Davidson',
    'bike',
    'BIK-9900',
    40.00,
    'available'
  ),
  (
    'Hyundai Elantra',
    'car',
    'ECO-1111',
    40.00,
    'available'
  ),
  (
    'Ram 1500',
    'truck',
    'TRK-2222',
    82.00,
    'available'
  ),
  (
    'Suzuki Hayabusa',
    'bike',
    'BIK-4444',
    35.00,
    'rented'
  ),
  (
    'Volkswagen Golf',
    'car',
    'GER-5555',
    48.00,
    'available'
  ),
  (
    'Volvo FH16',
    'truck',
    'BIG-6666',
    150.00,
    'available'
  ),
  (
    'Ducati Panigale',
    'bike',
    'BIK-7777',
    55.00,
    'maintenance'
  ),
  ('Audi A4', 'car', 'AUD-8888', 70.00, 'available'),
  (
    'Nissan Titan',
    'truck',
    'TRK-0000',
    78.00,
    'available'
  ),
  (
    'Honda Rebel',
    'bike',
    'BIK-1212',
    20.00,
    'available'
  ),
  (
    'Jeep Wrangler',
    'car',
    'OFF-3434',
    65.00,
    'available'
  );

-- -----------------------------
-- | Insert Values (Bookings) |
-- -----------------------------
INSERT INTO bookings (
  user_id,
  vehicle_id,
  start_date,
  end_date,
  status,
  total_cost
)
SELECT
  u.id,
  v.id,
  '2025-12-25 10:00:00'::timestamp + (random() * interval '30 days'),
  '2026-01-05 10:00:00'::timestamp + (random() * interval '30 days'),
  'confirmed',
  (random() * 500 + 50)::decimal(6, 2)
FROM
  users u
  CROSS JOIN vehicles v
ORDER BY
  random()
LIMIT
  18;