-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1
-- Generation Time: 23 Okt 2016 pada 06.53
-- Versi Server: 10.1.16-MariaDB
-- PHP Version: 5.6.24

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hotel`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_customers` (IN `id` INT)  BEGIN
SELECT count(*) FROM customer;

END$$

CREATE DEFINER=`hotel`@`localhost` PROCEDURE `get_available_rooms` (IN `o_room_type` VARCHAR(50), IN `o_checkin_date` VARCHAR(50), IN `o_checkout_date` VARCHAR(50))  BEGIN
SELECT * FROM `room` WHERE room_type=o_room_type AND NOT EXISTS (
SELECT room_id FROM reservation WHERE reservation.room_id=room.room_id AND checkout_date >= o_checkin_date AND checkin_date <= o_checkout_date
UNION ALL
SELECT room_id FROM room_sales WHERE room_sales.room_id=room.room_id AND checkout_date >= o_checkin_date AND checkin_date <= o_checkout_date
);
END$$

CREATE DEFINER=`hotel`@`localhost` PROCEDURE `get_customers` (IN `today_date` VARCHAR(50))  BEGIN
SELECT * FROM `room_sales` NATURAL JOIN `customer` WHERE checkout_date >= today_date AND checkin_date <= today_date;
END$$

CREATE DEFINER=`hotel`@`localhost` PROCEDURE `todays_service_count` (IN `today_date` VARCHAR(50))  BEGIN
SELECT count(*) as amount, "laundry" as type FROM laundry_service WHERE laundry_date=today_date UNION ALL SELECT count(*) as amount, "massage" as type FROM massage_service WHERE massage_date=today_date UNION ALL SELECT count(*) as amount, "roomservice" as type FROM get_roomservice WHERE roomservice_date=today_date UNION ALL SELECT count(*) as amount, "medicalservice" as type FROM get_medicalservice WHERE medicalservice_date=today_date UNION ALL SELECT count(*) as amount, "sport" as type FROM do_sport WHERE dosport_date=today_date
UNION ALL SELECT count(*) as amount, "restaurant" as type FROM restaurant_booking WHERE book_date=today_date;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `customer`
--

CREATE TABLE `customer` (
  `customer_id` int(11) NOT NULL,
  `customer_firstname` varchar(50) NOT NULL,
  `customer_lastname` varchar(50) NOT NULL,
  `customer_TCno` varchar(11) NOT NULL,
  `customer_city` varchar(50) DEFAULT NULL,
  `customer_country` varchar(50) DEFAULT NULL,
  `customer_telephone` varchar(50) NOT NULL,
  `customer_email` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data untuk tabel `customer`
--

INSERT INTO `customer` (`customer_id`, `customer_firstname`, `customer_lastname`, `customer_TCno`, `customer_city`, `customer_country`, `customer_telephone`, `customer_email`) VALUES
(1, 'channu', 'hakari', '1', 'hubli', 'india', '9900371461', 'channaveer@gmail.com'),
(2, 'Prabhanjan', 'l', '12', 'hubli', 'inida', '1234567890', 'prabhanjan@gmail.com'),
(3, 'Nurul', 'Azizah', '14', 'Surabaya', 'Indonesia', '085740888750', 'nurulazizah@gmail.com');

-- --------------------------------------------------------

--
-- Struktur dari tabel `department`
--

CREATE TABLE `department` (
  `department_id` int(11) NOT NULL,
  `department_name` varchar(50) NOT NULL,
  `department_budget` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data untuk tabel `department`
--

INSERT INTO `department` (`department_id`, `department_name`, `department_budget`) VALUES
(3, 'Laundry', 2000),
(4, 'Information Media', 2000000);

-- --------------------------------------------------------

--
-- Struktur dari tabel `do_sport`
--

CREATE TABLE `do_sport` (
  `customer_id` int(11) NOT NULL,
  `sportfacility_id` int(11) NOT NULL,
  `dosport_date` varchar(50) NOT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `dosport_details` text,
  `dosport_price` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Trigger `do_sport`
--
DELIMITER $$
CREATE TRIGGER `after_insert_sport_service` AFTER INSERT ON `do_sport` FOR EACH ROW BEGIN
    UPDATE room_sales SET room_sales.total_service_price = room_sales.total_service_price + NEW.dosport_price WHERE room_sales.customer_id = NEW.customer_id AND room_sales.checkin_date <= NEW.dosport_date AND room_sales.checkout_date >= NEW.dosport_date;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_sport_service` BEFORE DELETE ON `do_sport` FOR EACH ROW BEGIN
    UPDATE room_sales SET room_sales.total_service_price = room_sales.total_service_price - OLD.dosport_price WHERE room_sales.customer_id = OLD.customer_id AND room_sales.checkin_date <= OLD.dosport_date AND room_sales.checkout_date >= OLD.dosport_date;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `employee`
--

CREATE TABLE `employee` (
  `employee_id` int(11) NOT NULL,
  `employee_username` varchar(50) NOT NULL,
  `employee_password` varchar(50) CHARACTER SET utf32 NOT NULL,
  `employee_firstname` varchar(50) NOT NULL,
  `employee_lastname` varchar(50) NOT NULL,
  `employee_telephone` varchar(50) DEFAULT NULL,
  `employee_email` varchar(50) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `employee_type` varchar(50) NOT NULL,
  `employee_salary` float DEFAULT NULL,
  `employee_hiring_date` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data untuk tabel `employee`
--

INSERT INTO `employee` (`employee_id`, `employee_username`, `employee_password`, `employee_firstname`, `employee_lastname`, `employee_telephone`, `employee_email`, `department_id`, `employee_type`, `employee_salary`, `employee_hiring_date`) VALUES
(5, 'umum', 'enter-umum', 'Umum', 'Umum', '12345678', 'asdf@ghj.kl', 3, 'A', 10000, '21 Oktober 2016');

-- --------------------------------------------------------

--
-- Struktur dari tabel `get_medicalservice`
--

CREATE TABLE `get_medicalservice` (
  `customer_id` int(11) NOT NULL,
  `medicalservice_id` int(11) NOT NULL,
  `medicalservice_date` varchar(50) CHARACTER SET utf8 NOT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `getmedicalservice_details` text CHARACTER SET utf8,
  `medicalservice_price` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf16;

--
-- Trigger `get_medicalservice`
--
DELIMITER $$
CREATE TRIGGER `after_delete_medical_service` BEFORE DELETE ON `get_medicalservice` FOR EACH ROW BEGIN
    UPDATE room_sales SET room_sales.total_service_price = room_sales.total_service_price - OLD.medicalservice_price WHERE room_sales.customer_id = OLD.customer_id AND room_sales.checkin_date <= OLD.medicalservice_date AND room_sales.checkout_date >= OLD.medicalservice_date;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_insert_medical_service` AFTER INSERT ON `get_medicalservice` FOR EACH ROW BEGIN
    UPDATE room_sales SET room_sales.total_service_price = room_sales.total_service_price + NEW.medicalservice_price WHERE room_sales.customer_id = NEW.customer_id AND room_sales.checkin_date <= NEW.medicalservice_date AND room_sales.checkout_date >= NEW.medicalservice_date;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `get_roomservice`
--

CREATE TABLE `get_roomservice` (
  `customer_id` int(11) NOT NULL,
  `roomservice_id` int(11) NOT NULL,
  `roomservice_date` varchar(50) NOT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `getroomservice_details` text,
  `roomservice_price` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Trigger `get_roomservice`
--
DELIMITER $$
CREATE TRIGGER `after_insert_room_service` AFTER INSERT ON `get_roomservice` FOR EACH ROW BEGIN
    UPDATE room_sales SET room_sales.total_service_price = room_sales.total_service_price + NEW.roomservice_price WHERE room_sales.customer_id = NEW.customer_id AND room_sales.checkin_date <= NEW.roomservice_date AND room_sales.checkout_date >= NEW.roomservice_date;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_room_service` BEFORE DELETE ON `get_roomservice` FOR EACH ROW BEGIN
    UPDATE room_sales SET room_sales.total_service_price = room_sales.total_service_price - OLD.roomservice_price WHERE room_sales.customer_id = OLD.customer_id AND room_sales.checkin_date <= OLD.roomservice_date AND room_sales.checkout_date >= OLD.roomservice_date;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `laundry`
--

CREATE TABLE `laundry` (
  `laundry_id` int(11) NOT NULL,
  `laundry_open_time` varchar(50) DEFAULT NULL,
  `laundry_close_time` varchar(50) DEFAULT NULL,
  `laundry_details` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktur dari tabel `laundry_service`
--

CREATE TABLE `laundry_service` (
  `customer_id` int(11) NOT NULL,
  `laundry_id` int(11) NOT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `laundry_date` varchar(50) DEFAULT NULL,
  `laundry_amount` int(11) DEFAULT NULL,
  `laundry_price` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Trigger `laundry_service`
--
DELIMITER $$
CREATE TRIGGER `after_insert_laundry_service` AFTER INSERT ON `laundry_service` FOR EACH ROW BEGIN
    UPDATE room_sales SET room_sales.total_service_price = room_sales.total_service_price + NEW.laundry_price WHERE room_sales.customer_id = NEW.customer_id AND room_sales.checkin_date <= NEW.laundry_date AND room_sales.checkout_date >= NEW.laundry_date;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_laundry_service` BEFORE DELETE ON `laundry_service` FOR EACH ROW BEGIN
    UPDATE room_sales SET room_sales.total_service_price = room_sales.total_service_price - OLD.laundry_price WHERE room_sales.customer_id = OLD.customer_id AND room_sales.checkin_date <= OLD.laundry_date AND room_sales.checkout_date >= OLD.laundry_date;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `massage_room`
--

CREATE TABLE `massage_room` (
  `massageroom_id` int(11) NOT NULL,
  `massageroom_open_time` varchar(10) DEFAULT NULL,
  `massageroom_close_time` varchar(10) DEFAULT NULL,
  `massageroom_details` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data untuk tabel `massage_room`
--

INSERT INTO `massage_room` (`massageroom_id`, `massageroom_open_time`, `massageroom_close_time`, `massageroom_details`) VALUES
(1, '8.00 Am', '10.00 Pm', 'Ayruedic Massage');

-- --------------------------------------------------------

--
-- Struktur dari tabel `massage_service`
--

CREATE TABLE `massage_service` (
  `customer_id` int(11) NOT NULL,
  `massageroom_id` int(11) NOT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `massage_date` varchar(50) DEFAULT NULL,
  `massage_details` text,
  `massage_price` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Trigger `massage_service`
--
DELIMITER $$
CREATE TRIGGER `after_insert_massage_service` AFTER INSERT ON `massage_service` FOR EACH ROW BEGIN
    UPDATE room_sales SET room_sales.total_service_price = room_sales.total_service_price + NEW.massage_price WHERE room_sales.customer_id = NEW.customer_id AND room_sales.checkin_date <= NEW.massage_date AND room_sales.checkout_date >= NEW.massage_date;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_massage_service` BEFORE DELETE ON `massage_service` FOR EACH ROW BEGIN
    UPDATE room_sales SET room_sales.total_service_price = room_sales.total_service_price - OLD.massage_price WHERE room_sales.customer_id = OLD.customer_id AND room_sales.checkin_date <= OLD.massage_date AND room_sales.checkout_date >= OLD.massage_date;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `medical_service`
--

CREATE TABLE `medical_service` (
  `medicalservice_id` int(11) NOT NULL,
  `medicalservice_open_time` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `medicalservice_close_time` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `medicalservice_details` text CHARACTER SET utf8
) ENGINE=InnoDB DEFAULT CHARSET=utf16;

--
-- Dumping data untuk tabel `medical_service`
--

INSERT INTO `medical_service` (`medicalservice_id`, `medicalservice_open_time`, `medicalservice_close_time`, `medicalservice_details`) VALUES
(1, '8.00 Am', '10.00 Pm', 'First Aid');

-- --------------------------------------------------------

--
-- Struktur dari tabel `reservation`
--

CREATE TABLE `reservation` (
  `customer_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `checkin_date` varchar(50) NOT NULL,
  `checkout_date` varchar(50) DEFAULT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `reservation_date` varchar(50) DEFAULT NULL,
  `reservation_price` float DEFAULT NULL,
  `status` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktur dari tabel `restaurant`
--

CREATE TABLE `restaurant` (
  `restaurant_name` varchar(50) NOT NULL,
  `restaurant_open_time` varchar(10) DEFAULT NULL,
  `restaurant_close_time` varchar(10) DEFAULT NULL,
  `restaurant_details` text,
  `table_count` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data untuk tabel `restaurant`
--

INSERT INTO `restaurant` (`restaurant_name`, `restaurant_open_time`, `restaurant_close_time`, `restaurant_details`, `table_count`) VALUES
('Rest Name', '8.00 Am', '10.00 Pm', 'Very good', 4);

-- --------------------------------------------------------

--
-- Struktur dari tabel `restaurant_booking`
--

CREATE TABLE `restaurant_booking` (
  `restaurant_name` varchar(50) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `book_date` varchar(50) NOT NULL,
  `table_number` int(11) DEFAULT NULL,
  `book_price` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Trigger `restaurant_booking`
--
DELIMITER $$
CREATE TRIGGER `after_insert_restaurant_service` AFTER INSERT ON `restaurant_booking` FOR EACH ROW BEGIN
    UPDATE room_sales SET room_sales.total_service_price = room_sales.total_service_price + NEW.book_price WHERE room_sales.customer_id = NEW.customer_id AND room_sales.checkin_date <= NEW.book_date AND room_sales.checkout_date >= NEW.book_date;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_restaurant_service` BEFORE DELETE ON `restaurant_booking` FOR EACH ROW BEGIN
    UPDATE room_sales SET room_sales.total_service_price = room_sales.total_service_price - OLD.book_price WHERE room_sales.customer_id = OLD.customer_id AND room_sales.checkin_date <= OLD.book_date AND room_sales.checkout_date >= OLD.book_date;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `room`
--

CREATE TABLE `room` (
  `room_id` int(11) NOT NULL,
  `room_type` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data untuk tabel `room`
--

INSERT INTO `room` (`room_id`, `room_type`) VALUES
(3, 'Double Bed'),
(4, 'Double Bed');

--
-- Trigger `room`
--
DELIMITER $$
CREATE TRIGGER `after_insert_room` AFTER INSERT ON `room` FOR EACH ROW BEGIN
    UPDATE room_type SET room_type.room_quantity =room_type.room_quantity + 1 WHERE room_type.room_type = NEW.room_type;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_room` BEFORE DELETE ON `room` FOR EACH ROW BEGIN
    UPDATE room_type SET room_type.room_quantity =room_type.room_quantity - 1 WHERE room_type.room_type = OLD.room_type;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `room_sales`
--

CREATE TABLE `room_sales` (
  `customer_id` int(11) NOT NULL,
  `room_id` int(11) NOT NULL,
  `checkin_date` varchar(50) NOT NULL,
  `checkout_date` varchar(50) DEFAULT NULL,
  `employee_id` int(11) DEFAULT NULL,
  `room_sales_price` float DEFAULT NULL,
  `total_service_price` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktur dari tabel `room_service`
--

CREATE TABLE `room_service` (
  `roomservice_id` int(11) NOT NULL,
  `roomservice_open_time` varchar(50) DEFAULT NULL,
  `roomservice_close_time` varchar(50) DEFAULT NULL,
  `roomservice_floor` varchar(50) DEFAULT NULL,
  `roomservice_details` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Struktur dari tabel `room_type`
--

CREATE TABLE `room_type` (
  `room_type` varchar(50) NOT NULL,
  `room_price` int(11) DEFAULT NULL,
  `room_details` text,
  `room_quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data untuk tabel `room_type`
--

INSERT INTO `room_type` (`room_type`, `room_price`, `room_details`, `room_quantity`) VALUES
('Double Bed', 100, 'Double room', 4),
('Single Bed', 200, 'Single Bed', 0);

-- --------------------------------------------------------

--
-- Struktur dari tabel `sport_facilities`
--

CREATE TABLE `sport_facilities` (
  `sportfacility_id` int(11) NOT NULL,
  `sportfacility_open_time` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `sportfacility_close_time` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `sportfacility_details` text CHARACTER SET utf8
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data untuk tabel `sport_facilities`
--

INSERT INTO `sport_facilities` (`sportfacility_id`, `sportfacility_open_time`, `sportfacility_close_time`, `sportfacility_details`) VALUES
(1, '8.00 Am', '10.00 Pm', 'Chess');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`customer_id`);

--
-- Indexes for table `department`
--
ALTER TABLE `department`
  ADD PRIMARY KEY (`department_id`);

--
-- Indexes for table `do_sport`
--
ALTER TABLE `do_sport`
  ADD PRIMARY KEY (`customer_id`,`sportfacility_id`,`dosport_date`),
  ADD KEY `customer` (`customer_id`),
  ADD KEY `sport_facility` (`sportfacility_id`),
  ADD KEY `employee` (`employee_id`);

--
-- Indexes for table `employee`
--
ALTER TABLE `employee`
  ADD PRIMARY KEY (`employee_id`),
  ADD UNIQUE KEY `username` (`employee_username`),
  ADD UNIQUE KEY `email` (`employee_email`),
  ADD KEY `department` (`department_id`),
  ADD KEY `login` (`employee_username`,`employee_password`);

--
-- Indexes for table `get_medicalservice`
--
ALTER TABLE `get_medicalservice`
  ADD PRIMARY KEY (`customer_id`,`medicalservice_id`,`medicalservice_date`),
  ADD KEY `customer` (`customer_id`),
  ADD KEY `medical_service` (`medicalservice_id`),
  ADD KEY `employee` (`employee_id`);

--
-- Indexes for table `get_roomservice`
--
ALTER TABLE `get_roomservice`
  ADD PRIMARY KEY (`customer_id`,`roomservice_id`,`roomservice_date`),
  ADD KEY `customer` (`customer_id`),
  ADD KEY `room_service` (`roomservice_id`),
  ADD KEY `employee` (`employee_id`);

--
-- Indexes for table `laundry`
--
ALTER TABLE `laundry`
  ADD PRIMARY KEY (`laundry_id`);

--
-- Indexes for table `laundry_service`
--
ALTER TABLE `laundry_service`
  ADD PRIMARY KEY (`customer_id`,`laundry_id`),
  ADD KEY `customer` (`customer_id`),
  ADD KEY `laundry` (`laundry_id`),
  ADD KEY `employee` (`employee_id`);

--
-- Indexes for table `massage_room`
--
ALTER TABLE `massage_room`
  ADD PRIMARY KEY (`massageroom_id`);

--
-- Indexes for table `massage_service`
--
ALTER TABLE `massage_service`
  ADD PRIMARY KEY (`customer_id`,`massageroom_id`),
  ADD KEY `customer` (`customer_id`),
  ADD KEY `massage` (`massageroom_id`),
  ADD KEY `employee` (`employee_id`);

--
-- Indexes for table `medical_service`
--
ALTER TABLE `medical_service`
  ADD PRIMARY KEY (`medicalservice_id`);

--
-- Indexes for table `reservation`
--
ALTER TABLE `reservation`
  ADD PRIMARY KEY (`customer_id`,`room_id`,`checkin_date`),
  ADD KEY `customer` (`customer_id`),
  ADD KEY `employee` (`employee_id`),
  ADD KEY `room` (`room_id`),
  ADD KEY `availability` (`room_id`,`checkin_date`,`checkout_date`);

--
-- Indexes for table `restaurant`
--
ALTER TABLE `restaurant`
  ADD PRIMARY KEY (`restaurant_name`);

--
-- Indexes for table `restaurant_booking`
--
ALTER TABLE `restaurant_booking`
  ADD PRIMARY KEY (`restaurant_name`,`customer_id`,`book_date`),
  ADD KEY `restaurant` (`restaurant_name`),
  ADD KEY `customer` (`customer_id`);

--
-- Indexes for table `room`
--
ALTER TABLE `room`
  ADD PRIMARY KEY (`room_id`),
  ADD KEY `room_type` (`room_type`);

--
-- Indexes for table `room_sales`
--
ALTER TABLE `room_sales`
  ADD PRIMARY KEY (`customer_id`,`room_id`,`checkin_date`),
  ADD KEY `customer` (`customer_id`),
  ADD KEY `employee` (`employee_id`),
  ADD KEY `room` (`room_id`),
  ADD KEY `availability` (`room_id`,`checkin_date`,`checkout_date`);

--
-- Indexes for table `room_service`
--
ALTER TABLE `room_service`
  ADD PRIMARY KEY (`roomservice_id`);

--
-- Indexes for table `room_type`
--
ALTER TABLE `room_type`
  ADD PRIMARY KEY (`room_type`);

--
-- Indexes for table `sport_facilities`
--
ALTER TABLE `sport_facilities`
  ADD PRIMARY KEY (`sportfacility_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customer`
--
ALTER TABLE `customer`
  MODIFY `customer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT for table `department`
--
ALTER TABLE `department`
  MODIFY `department_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `employee`
--
ALTER TABLE `employee`
  MODIFY `employee_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT for table `laundry`
--
ALTER TABLE `laundry`
  MODIFY `laundry_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `massage_room`
--
ALTER TABLE `massage_room`
  MODIFY `massageroom_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `medical_service`
--
ALTER TABLE `medical_service`
  MODIFY `medicalservice_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `room`
--
ALTER TABLE `room`
  MODIFY `room_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT for table `room_service`
--
ALTER TABLE `room_service`
  MODIFY `roomservice_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `sport_facilities`
--
ALTER TABLE `sport_facilities`
  MODIFY `sportfacility_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `do_sport`
--
ALTER TABLE `do_sport`
  ADD CONSTRAINT `do_sport_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `do_sport_ibfk_2` FOREIGN KEY (`sportfacility_id`) REFERENCES `sport_facilities` (`sportfacility_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `do_sport_ibfk_3` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `employee`
--
ALTER TABLE `employee`
  ADD CONSTRAINT `employee_ibfk_1` FOREIGN KEY (`department_id`) REFERENCES `department` (`department_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `get_medicalservice`
--
ALTER TABLE `get_medicalservice`
  ADD CONSTRAINT `get_medicalservice_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `get_medicalservice_ibfk_2` FOREIGN KEY (`medicalservice_id`) REFERENCES `medical_service` (`medicalservice_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `get_medicalservice_ibfk_3` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `get_roomservice`
--
ALTER TABLE `get_roomservice`
  ADD CONSTRAINT `get_roomservice_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `get_roomservice_ibfk_2` FOREIGN KEY (`roomservice_id`) REFERENCES `room_service` (`roomservice_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `get_roomservice_ibfk_3` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `laundry_service`
--
ALTER TABLE `laundry_service`
  ADD CONSTRAINT `laundry_service_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `laundry_service_ibfk_2` FOREIGN KEY (`laundry_id`) REFERENCES `laundry` (`laundry_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `laundry_service_ibfk_3` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `massage_service`
--
ALTER TABLE `massage_service`
  ADD CONSTRAINT `massage_service_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `massage_service_ibfk_2` FOREIGN KEY (`massageroom_id`) REFERENCES `massage_room` (`massageroom_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `massage_service_ibfk_3` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `reservation`
--
ALTER TABLE `reservation`
  ADD CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reservation_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `room` (`room_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `reservation_ibfk_3` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `restaurant_booking`
--
ALTER TABLE `restaurant_booking`
  ADD CONSTRAINT `restaurant_booking_ibfk_1` FOREIGN KEY (`restaurant_name`) REFERENCES `restaurant` (`restaurant_name`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `restaurant_booking_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `room`
--
ALTER TABLE `room`
  ADD CONSTRAINT `room_ibfk_1` FOREIGN KEY (`room_type`) REFERENCES `room_type` (`room_type`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Ketidakleluasaan untuk tabel `room_sales`
--
ALTER TABLE `room_sales`
  ADD CONSTRAINT `room_sales_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `room_sales_ibfk_2` FOREIGN KEY (`room_id`) REFERENCES `room` (`room_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `room_sales_ibfk_3` FOREIGN KEY (`employee_id`) REFERENCES `employee` (`employee_id`) ON DELETE CASCADE ON UPDATE CASCADE;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
