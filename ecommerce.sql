-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 26, 2024 at 05:51 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ecommerce`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `showCustomers` ()   BEGIN
    SELECT * FROM Customers;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateOrderStatus` (`id_order` INT, `status` VARCHAR(20))   BEGIN
    UPDATE Orders SET status = status WHERE id_order = id_order;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `updateProductStock` (IN `p_id_product` INT, IN `p_quantityChange` INT)   BEGIN
    DECLARE currentStock INT;
    
    -- Get current stock
    SELECT stock INTO currentStock FROM products WHERE id_product = p_id_product;
    
    -- Update stock using IF statement
    IF (currentStock + p_quantityChange) < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Stock cannot be negative';
    ELSE
        UPDATE products 
        SET stock = stock + p_quantityChange 
        WHERE id_product = p_id_product;
        
        -- Note: The following IF block is commented out because there's no low_stock_alerts table in your schema
        -- If you want to use this feature, you'll need to create the table first
        /*
        IF (currentStock + p_quantityChange) < 10 THEN
            INSERT INTO low_stock_alerts (product_id, current_stock, alert_date)
            VALUES (p_id_product, currentStock + p_quantityChange, NOW());
        END IF;
        */
    END IF;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `getTotalOrders` () RETURNS INT(11)  BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total FROM Orders;
    RETURN total;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `getTotalPayments` (`id_order` INT, `start_date` DATE) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT SUM(jumlah_bayar) INTO total FROM Payments WHERE id_order = id_order AND tanggal_bayar >= start_date;
    RETURN total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `base_view`
-- (See below for the actual view)
--
CREATE TABLE `base_view` (
`id_customer` int(11)
,`nama` varchar(100)
);

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id_customer` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  `telepon` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id_customer`, `nama`, `alamat`, `telepon`) VALUES
(2, 'Alice', '1134 Elm Street', '811111'),
(5, 'Bob', '6789 Pine Street', NULL),
(6, 'Batman', '5678 Oak Street', '0987654321');

--
-- Triggers `customers`
--
DELIMITER $$
CREATE TRIGGER `after_delete_customers` AFTER DELETE ON `customers` FOR EACH ROW BEGIN
    INSERT INTO log_changes (event_type, table_name, old_data)
    VALUES ('AFTER DELETE', 'Customers', CONCAT('Name: ', OLD.nama, ', Address: ', OLD.alamat, ', Phone: ', OLD.telepon));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_customers` BEFORE INSERT ON `customers` FOR EACH ROW BEGIN
    INSERT INTO log_changes (event_type, table_name, new_data)
    VALUES ('BEFORE INSERT', 'Customers', CONCAT('Name: ', NEW.nama, ', Address: ', NEW.alamat, ', Phone: ', NEW.telepon));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `horizontal_view`
-- (See below for the actual view)
--
CREATE TABLE `horizontal_view` (
`id_customer` int(11)
,`nama` varchar(100)
,`alamat` varchar(255)
);

-- --------------------------------------------------------

--
-- Table structure for table `index_orders`
--

CREATE TABLE `index_orders` (
  `order_id` int(11) DEFAULT NULL,
  `customer_id` int(11) DEFAULT NULL,
  `order_date` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `log_changes`
--

CREATE TABLE `log_changes` (
  `id` int(11) NOT NULL,
  `event_time` timestamp NOT NULL DEFAULT current_timestamp(),
  `event_type` varchar(20) DEFAULT NULL,
  `table_name` varchar(50) DEFAULT NULL,
  `old_data` text DEFAULT NULL,
  `new_data` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_changes`
--

INSERT INTO `log_changes` (`id`, `event_time`, `event_type`, `table_name`, `old_data`, `new_data`) VALUES
(1, '2024-07-25 19:12:35', 'BEFORE INSERT', 'Customers', NULL, 'Name: Robin, Address: 1134 Elm Street, Phone: 1111789'),
(2, '2024-07-25 20:33:54', 'BEFORE DELETE', 'Orders', NULL, NULL),
(3, '2024-07-25 20:44:11', 'BEFORE UPDATE', 'Products', 'Name: Product A, Stock: 35', 'Name: [Product C], Stock: 0'),
(4, '2024-07-25 20:50:23', 'AFTER UPDATE', 'Orders', NULL, NULL),
(5, '2024-07-25 20:57:34', 'AFTER DELETE', 'Customers', 'Name: Joker, Address: 1234 Elm Street, Phone: 1234567890', NULL),
(6, '2024-07-25 21:04:16', 'AFTER INSERT', 'Products', NULL, 'Name: Product f, Stock: 40'),
(7, '2024-07-25 22:51:23', 'BEFORE INSERT', 'Customers', NULL, NULL),
(8, '2024-07-26 03:18:31', 'BEFORE UPDATE', 'Products', 'Name: Product f, Stock: 40', 'Name: Product f, Stock: 35');

-- --------------------------------------------------------

--
-- Stand-in structure for view `nested_view`
-- (See below for the actual view)
--
CREATE TABLE `nested_view` (
`id_customer` int(11)
,`nama` varchar(100)
);

-- --------------------------------------------------------

--
-- Table structure for table `orderdetails`
--

CREATE TABLE `orderdetails` (
  `id_order_detail` int(11) NOT NULL,
  `id_order` int(11) DEFAULT NULL,
  `id_product` int(11) DEFAULT NULL,
  `kuantitas` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id_order` int(11) NOT NULL,
  `id_customer` int(11) DEFAULT NULL,
  `tanggal_pesan` date DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `id_product` int(11) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id_order`, `id_customer`, `tanggal_pesan`, `status`, `id_product`, `quantity`) VALUES
(18, 6, '2024-07-25', 'Shipped', NULL, 50);

--
-- Triggers `orders`
--
DELIMITER $$
CREATE TRIGGER `after_update_orders` AFTER UPDATE ON `orders` FOR EACH ROW BEGIN
    INSERT INTO log_changes (event_type, table_name, old_data, new_data)
    VALUES ('AFTER UPDATE', 'Orders', CONCAT('Customer ID: ', OLD.id_customer, ', Product ID: ', OLD.id_product, ', Quantity: ', OLD.quantity), CONCAT('Customer ID: ', NEW.id_customer, ', Product ID: ', NEW.id_product, ', Quantity: ', NEW.quantity));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_orders` BEFORE DELETE ON `orders` FOR EACH ROW BEGIN
    INSERT INTO log_changes (event_type, table_name, old_data)
    VALUES ('BEFORE DELETE', 'Orders', CONCAT('Customer ID: ', OLD.id_customer, ', Product ID: ', OLD.id_product, ', Quantity: ', OLD.quantity));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id_payment` int(11) NOT NULL,
  `id_order` int(11) DEFAULT NULL,
  `jumlah_bayar` decimal(10,2) DEFAULT NULL,
  `tanggal_bayar` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id_product` int(11) NOT NULL,
  `nama_product` varchar(100) DEFAULT NULL,
  `harga` decimal(10,2) DEFAULT NULL,
  `stock` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id_product`, `nama_product`, `harga`, `stock`) VALUES
(0, '[Product C]', 0.00, 0),
(1, 'Product f', 300.00, 35),
(2, 'Product B', 200.00, 20);

--
-- Triggers `products`
--
DELIMITER $$
CREATE TRIGGER `after_insert_products` AFTER INSERT ON `products` FOR EACH ROW BEGIN
    INSERT INTO log_changes (event_type, table_name, new_data)
    VALUES ('AFTER INSERT', 'Products', CONCAT('Name: ', NEW.nama_product, ', Stock: ', NEW.stock));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_update_products` BEFORE UPDATE ON `products` FOR EACH ROW BEGIN
    INSERT INTO log_changes (event_type, table_name, old_data, new_data)
    VALUES ('BEFORE UPDATE', 'Products', CONCAT('Name: ', OLD.nama_product, ', Stock: ', OLD.stock), CONCAT('Name: ', NEW.nama_product, ', Stock: ', NEW.stock));
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `vertical_view`
-- (See below for the actual view)
--
CREATE TABLE `vertical_view` (
`nama` varchar(100)
,`alamat` varchar(255)
);

-- --------------------------------------------------------

--
-- Structure for view `base_view`
--
DROP TABLE IF EXISTS `base_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `base_view`  AS SELECT `customers`.`id_customer` AS `id_customer`, `customers`.`nama` AS `nama` FROM `customers` WHERE `customers`.`nama` is not null ;

-- --------------------------------------------------------

--
-- Structure for view `horizontal_view`
--
DROP TABLE IF EXISTS `horizontal_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `horizontal_view`  AS SELECT `customers`.`id_customer` AS `id_customer`, `customers`.`nama` AS `nama`, `customers`.`alamat` AS `alamat` FROM `customers` ;

-- --------------------------------------------------------

--
-- Structure for view `nested_view`
--
DROP TABLE IF EXISTS `nested_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `nested_view`  AS SELECT `base_view`.`id_customer` AS `id_customer`, `base_view`.`nama` AS `nama` FROM `base_view`WITH CASCADED CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Structure for view `vertical_view`
--
DROP TABLE IF EXISTS `vertical_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vertical_view`  AS SELECT `customers`.`nama` AS `nama`, `customers`.`alamat` AS `alamat` FROM `customers` WHERE `customers`.`alamat` is not null ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id_customer`),
  ADD KEY `idx_customer_name_address` (`nama`,`alamat`),
  ADD KEY `idx_name_phone` (`nama`,`telepon`);

--
-- Indexes for table `index_orders`
--
ALTER TABLE `index_orders`
  ADD KEY `order_id` (`order_id`,`customer_id`);

--
-- Indexes for table `log_changes`
--
ALTER TABLE `log_changes`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orderdetails`
--
ALTER TABLE `orderdetails`
  ADD PRIMARY KEY (`id_order_detail`),
  ADD KEY `id_order` (`id_order`),
  ADD KEY `id_product` (`id_product`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id_order`),
  ADD KEY `id_customer` (`id_customer`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id_payment`),
  ADD KEY `id_order` (`id_order`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id_product`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id_customer` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `log_changes`
--
ALTER TABLE `log_changes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `orderdetails`
--
ALTER TABLE `orderdetails`
  MODIFY `id_order_detail` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id_order` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id_payment` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id_product` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `orderdetails`
--
ALTER TABLE `orderdetails`
  ADD CONSTRAINT `orderdetails_ibfk_1` FOREIGN KEY (`id_order`) REFERENCES `orders` (`id_order`),
  ADD CONSTRAINT `orderdetails_ibfk_2` FOREIGN KEY (`id_product`) REFERENCES `products` (`id_product`);

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`id_customer`) REFERENCES `customers` (`id_customer`);

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`id_order`) REFERENCES `orders` (`id_order`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
