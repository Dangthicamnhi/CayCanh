-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Dec 12, 2024 at 06:01 AM
-- Server version: 8.0.31
-- PHP Version: 8.0.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rainbow`
--
CREATE DATABASE IF NOT EXISTS `rainbow` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `rainbow`;

DELIMITER $$
--
-- Procedures
--
DROP PROCEDURE IF EXISTS `AddToCart`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AddToCart` (IN `ctID` INT(11), IN `productID` INT(11), IN `quantity` INT(11))   BEGIN
	DECLARE idcart int(11) DEFAULT 0;
    
	SELECT ID into idcart FROM `order` WHERE sttOrder='1' AND custom_id=ctID;
    
    if idcart=0 THEN
    	INSERT INTO `order`( `createdate`, `custom_id`, `fullname`, `sttOrder`) VALUES (now(),customID,fullname,1);
    	set idCart=LAST_INSERT_ID();
    END IF;
     INSERT INTO `order_line`(`id_order`, `id_product`, `quantity`) VALUES (idCart,productID,quantity);
  
END$$

DROP PROCEDURE IF EXISTS `capnhat_SoLuongSanPham`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `capnhat_SoLuongSanPham` (`productID` INT(11), `quantity` INT(11))   BEGIN
    DECLARE v_inStock INT(11);
    SET SESSION TRANSACTION isolation level READ uncommitted;
        START TRANSACTION;
        SELECT inStock INTO v_inStock FROM `product` WHERE id = productID FOR UPDATE;
   
        SET v_inStock = v_inStock - quantity;
   
        UPDATE `product`
        SET inStock = v_inStock
        WHERE id = productID;
   
        COMMIT;
END$$

DROP PROCEDURE IF EXISTS `INSERToder`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `INSERToder` (IN `customID` INT(11), IN `FullName` VARCHAR(200), IN `productID` INT(11), IN `quantity` INT(11))   BEGIN
	DECLARE orderID int(11);
	INSERT INTO `order`( `createdate`, `custom_id`, `fullname`, `sttOrder`) VALUES (now(),customID,fullname,1);
    
    set orderID =LAST_INSERT_ID();
    INSERT INTO `order_line`(`id_order`, `id_product`, `quantity`) VALUES (orderID,productID,quantity);
  
END$$

DROP PROCEDURE IF EXISTS `LoadCart`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `LoadCart` (IN `ctID` INT(11))   BEGIN
	DECLARE productID,pdquatity int(11);
     DECLARE done int DEFAULT false;
    DECLARE corderline cursor for SELECT id_product, quantity FROM order_line WHERE Id_order in (SELECT ID FROM `order` WHERE sttOrder='1' AND custom_id=ctID);
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done =true;
    
    
    OPEN corderline;
  	My_loop: LOOP
  		FETCH corderline INTO productID,pdquatity;
    	if done then LEAVE MY_loop;
  		end if;  
            SELECT p.* , pdquatity, activePrice(p.ID) 			FROM product p WHERE p.ID=productID;
   	 	end LOOP My_loop;
     
     CLOSE corderline;    
     
END$$

DROP PROCEDURE IF EXISTS `pr_kiemtraMuaHang`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `pr_kiemtraMuaHang` ()   BEGIN
   DECLARE v_inStock INT(11);
   SELECT inStock INTO v_inStock  FROM product WHERE product.`id` = NEW.id_product;
   
   IF NEW.quantity > v_inStock THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'this err'; 
   END IF;  
END$$

DROP PROCEDURE IF EXISTS `sp_capnhatGia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_capnhatGia` (`p_productID` INT(11), `p_price` FLOAT, `p_startdate` DATE)   BEGIN
-- declare handler
    DECLARE exit handler FOR sqlexception
        BEGIN
    -- ERROR
        ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR';
        END;
    -- Start transaction
        START TRANSACTION;
   -- B1 Lấy giá của sản phẩm hiện tại, isActive = 0 và gán cho nó ngày kết thúc là hiện tại đang làm
   UPDATE pricelist
   SET enddate = p_startdate, isActive = FALSE
   WHERE productID = p_productID AND isActive = TRUE;
    -- B2 Thêm vào giá mới
   INSERT INTO pricelist (productID, price, startdate, isActive) VALUES (p_productID, p_price, CURRENT_DATE(), TRUE);
   commit;
END$$

DROP PROCEDURE IF EXISTS `sp_changePrice`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_changePrice` (IN `pdID` INT(11), IN `starD` DATETIME, IN `endD` DATETIME, IN `pr` INT(11))   begin
 

-- Start transaction
    SET session transaction isolation level read uncommitted;
start transaction;
-- Gọi them gia
   INSERT INTO pricelist(productID, price, startdate,enddate) VALUES(pdID,pr, starD, endD);
   
-- Lỗi
-- Rollback commit;
do sleep(10);
ROLLBACK;
end$$

DROP PROCEDURE IF EXISTS `sp_huyDonHang`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_huyDonHang` (`p_orderID` INT(11))   BEGIN
       
        DECLARE v_productID INT(11);
    DECLARE v_quantity INT(11);
    DECLARE v_stt INT(11);
    DECLARE v_count INT(11);
    DECLARE v_found bool DEFAULT FALSE;
    DECLARE my_cursor cursor FOR
                                                (SELECT _product, o.quantity FROM `order_line` o WHERE _order = p_orderID);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_found := TRUE;
        DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
                ROLLBACK;
        END;
       
        DECLARE EXIT HANDLER FOR SQLWARNING
        BEGIN
        ROLLBACK;
        END;
   
    START TRANSACTION;
        SET v_count = 0;
                OPEN my_cursor;
                        my_loop: loop
                        fetch my_cursor INTO v_productID, v_quantity;
                        #kết thúc vòng lặp khi đã duyệt hết bản ghi trên cursor
                        IF v_found THEN leave my_loop;
                        END IF;
                                #Vì đã có TRIGGER test đặt hàng, 1 khi đặt hàng nghĩa là đủ số lượng!
                                CALL sp_capnhatSoLuongSanPham(v_productID, 0 - update_quantity);
                                SET v_count = v_count +1;
                        END loop my_loop;
                close my_cursor;
       
        SELECT sttID INTO v_stt
        FROM `order`
        WHERE sttName = 'canceled';
       
        UPDATE `order`
        SET sttOrder = v_stt
        WHERE id = p_orderID;
        COMMIT;
END$$

DROP PROCEDURE IF EXISTS `sp_lietkeSanPhamNoiBat`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_lietkeSanPhamNoiBat` ()   BEGIN
-- declare handler
    DECLARE exit handler FOR sqlexception
    BEGIN
-- ERROR
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR';
    END;
-- Start transaction
    SET SESSION TRANSACTION isolation level READ committed;
START TRANSACTION;
--  Dua code vao day cua nhung truong hop lay thong tin san pham!
   
       SELECT p.* , activePrice(p.ID) as price FROM product p JOIN (SELECT sum(quantity), id_product FROM order_line GROUP BY id_product ORDER BY sum(quantity) DESC LIMIT 4) q ON p.id=q.id_product WHERE p.isAvailable=1; 
-- Lỗi
-- Rollback
    commit;
END$$

DROP PROCEDURE IF EXISTS `sp_lietkeSanPhamTheoLoai`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_lietkeSanPhamTheoLoai` (IN `categoryname` VARCHAR(200), IN `dstart` INT(3), IN `size` INT(3))   BEGIN
-- declare handler
    DECLARE exit handler FOR sqlexception
    BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR';
    END;
-- Start transaction
    SET SESSION TRANSACTION isolation level READ committed;
START TRANSACTION;
--  Dua code vao day cua nhung truong hop lay thong tin san pham!
   SELECT p.* , activePrice(p.id) as price FROM product p WHERE category=categoryname limit dstart, size;
-- Lỗi
-- Rollback 
    commit;
END$$

DROP PROCEDURE IF EXISTS `sp_themFeedback`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_themFeedback` (`v_name` VARCHAR(100), `v_phone` INT(11), `v_email` VARCHAR(100), `v_content` TEXT)   BEGIN
        INSERT INTO feedback (`name`, `phone`,`email`,`content`)
    VALUES (v_name, v_phone, v_email, v_content);
END$$

DROP PROCEDURE IF EXISTS `sp_themvaoGioHang`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_themvaoGioHang` (`p_productID` INT(11), `p_orderID` INT(11), `p_quantity` INT(11))   BEGIN
   DECLARE onSell BOOLEAN;
   DECLARE avaiQuantity INT(11);
   SELECT inStock, isAvailable INTO @avaiQuantity, @onSell
   FROM product
   WHERE id = p_productID;
   
   IF (avaiQuantity > 0 AND onSell = TRUE) THEN
   BEGIN
                INSERT INTO `order` VALUES (p_orderID, p_productID, p_quantity);
   END;
   END IF;
END$$

DROP PROCEDURE IF EXISTS `sp_themvaoGioHangtest2`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_themvaoGioHangtest2` (`p_productID` INT(11), `p_orderID` INT(11), `p_quantity` INT(11))   BEGIN
   

 DECLARE onSell BOOLEAN;
   DECLARE avaiQuantity INT(11);
 DECLARE exit handler FOR sqlexception
    BEGIN
-- ERROR
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR';
    END;
-- Start transaction
    SET SESSION TRANSACTION isolation level SERIALIZABLE;
	START TRANSACTION;
  
   SELECT inStock, isAvailable INTO avaiQuantity, onSell
   FROM product
   WHERE product.`id` = p_productID;
   
   IF (avaiQuantity > 0 AND onSell = TRUE) THEN
   BEGIN
                INSERT INTO order_line VALUES (p_orderID, p_productID, p_quantity);
   END;
   END IF;
   do sleep(10);
   SELECT * FROM order_line o WHERE o.id_order = p_orderID;
   commit; 
END$$

DROP PROCEDURE IF EXISTS `sp_thongkeDoanhThu`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_thongkeDoanhThu` (IN `startdate` DATE, IN `enddate` DATE, OUT `totalAmounts` DOUBLE)   BEGIN
                -- declare handler
                DECLARE exit handler FOR sqlexception
                BEGIN
                -- ERROR
                ROLLBACK;
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERROR';
                END;
                -- Start transaction
SET SESSION TRANSACTION isolation level repeatable READ;
                START TRANSACTION;      

SELECT o.id, a.fullname, sumOrderLine(o.id)
                FROM account a, `order` o
                WHERE o.custom_id=a.id AND o.`createdate` >= @startdate  AND o.`createdate`<= @enddate AND o.`sttOrder`=4;
                commit;  
END$$

DROP PROCEDURE IF EXISTS `sp_thongkeDonHang`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_thongkeDonHang` (`startdate` DATETIME, `enddate` DATETIME, `categoryPD` INT(11))   begin
SELECT  ol.quantity * activePrice(ol.id_product)as total, o.id, o.createdate FROM order_line ol JOIN( SELECT o.id, o.createdate FROM `order` o WHERE o.sttOrder=5 AND o.createdate BETWEEN startdate AND enddate) o ON ol.id_order=o.id WHERE ol.id_product IN
    (SELECT id from product WHERE category=categoryPD);
END$$

DROP PROCEDURE IF EXISTS `sp_thongkeSanPhamDaBan`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_thongkeSanPhamDaBan` ()   BEGIN
        SELECT  DISTINCT *
    FROM `product`
    WHERE id IN (SELECT id_product FROM `order_line`);
END$$

DROP PROCEDURE IF EXISTS `sp_thongkeSanPhamTonKho`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_thongkeSanPhamTonKho` ()   BEGIN
        SELECT DISTINCT *
    FROM `product`
    WHERE inStock > 0;
END$$

DROP PROCEDURE IF EXISTS `sp_xacnhanDonHang`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_xacnhanDonHang` (`v_orderID` INT(11))   BEGIN
        DECLARE v_found bool DEFAULT FALSE;
        DECLARE v_productID INT(11);
    DECLARE v_quantity INT(11);
    DECLARE my_cursor cursor FOR
                                                (SELECT _product, o.quantity FROM `order_line` o WHERE _order = v_orderID);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_found := TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
                ROLLBACK;
        END;
 
        DECLARE EXIT HANDLER FOR SQLWARNING
        BEGIN
        ROLLBACK;
        END;
    SET SESSION TRANSACTION isolation level READ uncommitted;
        START TRANSACTION;
    OPEN my_cursor;
                my_loop: loop
                        fetch my_cursor INTO v_productID, v_quantity;
                        #kết thúc vòng lặp khi đã duyệt hết bản ghi trên cursor
                        IF v_found THEN leave my_loop;
                        END IF;
                        #Vì đã có TRIGGER test đặt hàng, 1 khi đặt hàng nghĩa là đủ số lượng!
                        UPDATE `product`
                        SET inStock = inStock - v_quantity
                        WHERE id = v_productID;
                END loop my_loop;
        close my_cursor;
 
    COMMIT;
END$$

DROP PROCEDURE IF EXISTS `sp_xoaGioHang`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_xoaGioHang` (`p_orderID` INT(11))   BEGIN
   	DELETE FROM `order_line` WHERE `order_line`.`id_order` = p_orderID;
    DELETE FROM `order` WHERE `order`.`id` = p_orderID; 
END$$

DROP PROCEDURE IF EXISTS `test_lostupdate_trans1`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_lostupdate_trans1` ()   BEGIN
 
    DECLARE v_inStock INT(11);
        SET SESSION TRANSACTION isolation level READ committed;
        START TRANSACTION;
    SELECT inStock INTO v_inStock
    FROM `product`
    WHERE id= 47;
   
    SELECT sleep(12);
    SET v_inStock = v_inStock - 2;
   
        UPDATE `product`
        SET inStock = v_inStock
        WHERE id = 47;
    COMMIT;
   
    SELECT inStock
    FROM `product`
    WHERE id = 47;
END$$

DROP PROCEDURE IF EXISTS `test_lostupdate_trans2`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `test_lostupdate_trans2` ()   BEGIN
    DECLARE v_inStock INT(11);
    SET SESSION TRANSACTION isolation level READ committed;
        START TRANSACTION;
    SELECT inStock INTO v_inStock
    FROM `product`
    WHERE id=47;
   
    SELECT sleep(3);
    SET v_inStock = v_inStock - 3;
 
   
        UPDATE `product`
        SET inStock = v_inStock
        WHERE id = 47;
   
    COMMIT;
   
        SELECT inStock
    FROM `product`
    WHERE id = 47;
END$$

--
-- Functions
--
DROP FUNCTION IF EXISTS `activePrice`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `activePrice` (`pdID` INT(11)) RETURNS FLOAT  BEGIN
   	
    DECLARE dstartdate, denddate datetime;
    DECLARE dprice float;
    DECLARE done int DEFAULT false;
    DECLARE dnowdate datetime DEFAULT CURRENT_DATE;
     DECLARE cPrilist CURSOR for SELECT  startdate, enddate, price from pricelist WHERE productID = pdID
    order BY priceID DESC;
    
     DECLARE CONTINUE HANDLER FOR NOT FOUND SET done =true;
 
	OPEN cPrilist;
  	My_loop: LOOP
  		FETCH cPrilist INTO dstartdate,denddate, dprice;
    	if done then LEAVE MY_loop;
  		end if;  
            if(dstartdate <=dnowdate AND
                dnowdate <=denddate) THEN
                RETURN dprice;
                LEAVE MY_loop;
              END if;
   	 end LOOP My_loop;
     
     CLOSE cPrilist;    

  RETURN 0;
     
END$$

DROP FUNCTION IF EXISTS `priceOfProduct`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `priceOfProduct` (`pdID` INT(11), `orderDate` DATETIME) RETURNS FLOAT  BEGIN
   	
    DECLARE dstartdate, denddate datetime;
    DECLARE dprice float;
    DECLARE done int DEFAULT false;
    
     DECLARE cPrilist CURSOR for SELECT  startdate, enddate, price from pricelist WHERE productID = pdID
    order BY priceID DESC;
    
     DECLARE CONTINUE HANDLER FOR NOT FOUND SET done =true;
 
	OPEN cPrilist;
  	My_loop: LOOP
  		FETCH cPrilist INTO dstartdate,denddate, dprice;
    	if done then LEAVE MY_loop;
  		end if;  
            if(dstartdate <=@orderDate AND
                @orderDate <=denddate) THEN
                RETURN dprice;
                LEAVE MY_loop;
              END if;
   	 end LOOP My_loop;
     
     CLOSE cPrilist;    

  RETURN 0; 
END$$

DROP FUNCTION IF EXISTS `totalAmounts`$$
CREATE DEFINER=`root`@`localhost` FUNCTION `totalAmounts` (`beginDate` DATETIME, `endDate` DATETIME, `categoryPD` INT) RETURNS INT  BEGIN  
DECLARE sumOder int DEFAULT 0;
    SELECT sum( ol.quantity * activePrice(ol.id_product)) into sumOder FROM order_line ol WHERE id_order IN( SELECT o.id FROM `order` o WHERE o.sttOrder=4 AND o.createdate BETWEEN beginDate AND endDate) AND ol.id_product IN
    (SELECT id from product WHERE category=categoryPD);
   return sumOder;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `account`
--

DROP TABLE IF EXISTS `account`;
CREATE TABLE IF NOT EXISTS `account` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'client',
  `username` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `passwords` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `fullname` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `createdate` datetime DEFAULT NULL,
  `lastmodified` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `account`
--

INSERT INTO `account` (`id`, `role`, `username`, `passwords`, `fullname`, `createdate`, `lastmodified`) VALUES
(1, 'admin', 'admin@admin.com', '$2y$10$DHvAyS/AoCVWtf/a3SEmeOU/vTg8qU8pRYUUqaTfm1YlVwH1r9e.q', 'Cẩm Nhi', '2024-12-19 23:23:30', NULL),
(2, 'client', 'client@gmail.com', '$2y$10$qJBsqhdSv2jpnDnpEzWpyel4K7Xo0IuO6.JyhUMpbQFlxxqCnOS2S', 'Hoài Thương', '2024-12-20 11:18:16', NULL),
(3, 'client', 'client1@gmail.com', 'client1', 'Lê Thị Thúy', '2024-03-19 00:00:00', '2024-01-09 00:00:00'),
(4, 'client', 'client2@gmail.com', 'client2', 'Nguyễn Thị Trường', '2024-08-28 00:00:00', '2024-01-13 00:00:00'),
(5, 'client', 'client3@gmail.com', 'client3', 'Nguyễn Tường', '2024-09-23 00:00:00', '2024-01-08 00:00:00'),
(6, 'client', 'client4@gmail.com', 'client4', 'Trần Hà Thiên', '2024-12-03 00:00:00', '2024-01-23 00:00:00'),
(7, 'client', 'client5@gmail.com', 'client5', 'Đào Hải', '2024-12-28 00:00:00', '2024-01-22 00:00:00'),
(8, 'client', 'client6@gmail.com', 'client6', 'Nguyễn Thị Ngọc', '2024-12-04 00:00:00', '2024-01-19 00:00:00'),
(9, 'client', 'client7@gmail.com', 'client7', 'Nguyễn Thị Trâm', '2024-08-09 00:00:00', '2024-01-12 00:00:00'),
(10, 'client', 'client8@gmail.com', 'client8', 'Nguyễn Vũ Thụy', '2024-12-01 00:00:00', '2024-01-31 00:00:00'),
(11, 'client', 'client9@gmail.com', 'client9', 'Thân Hoàng Thúy', '2024-09-09 00:00:00', '2024-01-19 00:00:00'),
(12, 'client', 'client10@gmail.com', 'client10', 'Trần Huyền My', '2024-03-12 00:00:00', '2024-01-10 00:00:00'),
(13, 'client', 'client11@gmail.com', 'client11', 'Trần Thị Vân', '2024-02-11 00:00:00', '2024-01-15 00:00:00'),
(14, 'client', 'client12@gmail.com', 'client12', 'Hà Thị Thu', '2024-05-04 00:00:00', '2024-01-05 00:00:00'),
(15, 'client', 'client13@gmail.com', 'client13', 'Nguyễn Ngọc', '2024-05-31 00:00:00', '2024-01-23 00:00:00'),
(16, 'client', 'client14@gmail.com', 'client14', 'Võ Phan Thúy', '2024-04-20 00:00:00', '2024-01-12 00:00:00'),
(17, 'client', 'client15@gmail.com', 'client15', 'Võ Thúy', '2024-05-04 00:00:00', '2024-01-01 00:00:00'),
(18, 'client', 'client16@gmail.com', 'client16', 'Đặng Thị', '2024-12-24 00:00:00', '2024-01-21 00:00:00'),
(19, 'client', 'client17@gmail.com', 'client17', 'Nguyễn Thị Ngọc', '2024-12-19 00:00:00', '2024-01-21 00:00:00'),
(20, 'client', 'client18@gmail.com', 'client18', 'Phạm Thị Hoàng', '2024-04-06 00:00:00', '2024-01-10 00:00:00'),
(21, 'client', 'client19@gmail.com', 'client19', 'Vũ Trương Ngọc', '2024-05-28 00:00:00', '2024-01-02 00:00:00'),
(22, 'client', 'client20@gmail.com', 'client20', 'Vương Thị Ngọc', '2024-10-10 00:00:00', '2024-01-09 00:00:00'),
(23, 'client', 'client21@gmail.com', 'client21', 'Bùi Thị Ngọc', '2024-07-20 00:00:00', '2024-01-25 00:00:00'),
(24, 'client', 'client22@gmail.com', 'client22', 'Nguyễn Quốc', '2024-04-24 00:00:00', '2024-01-04 00:00:00'),
(25, 'client', 'client23@gmail.com', 'client23', 'Trần Anh', '2024-06-16 00:00:00', '2024-01-22 00:00:00'),
(26, 'client', 'client24@gmail.com', 'client24', 'Lê Thị Kim', '2024-03-07 00:00:00', '2024-01-18 00:00:00'),
(27, 'client', 'client25@gmail.com', 'client25', 'Lê Thị', '2024-12-20 00:00:00', '2024-01-01 00:00:00'),
(28, 'client', 'client26@gmail.com', 'client26', 'Bùi Thị Thanh', '2024-10-07 00:00:00', '2024-01-01 00:00:00'),
(29, 'client', 'client27@gmail.com', 'client27', 'Phan Thanh', '2024-05-25 00:00:00', '2024-01-16 00:00:00'),
(30, 'client', 'client28@gmail.com', 'client28', 'Vũ Hải', '2024-01-11 00:00:00', '2024-01-23 00:00:00'),
(31, 'client', 'client29@gmail.com', 'client29', 'Trương Thị', '2024-07-01 00:00:00', '2024-01-05 00:00:00'),
(32, 'client', 'client30@gmail.com', 'client30', 'Đặng Thị Lệ', '2024-07-03 00:00:00', '2024-01-05 00:00:00'),
(33, 'client', 'client31@gmail.com', 'client31', 'Chung Phối', '2024-06-26 00:00:00', '2024-01-25 00:00:00'),
(34, 'client', 'client32@gmail.com', 'client32', 'Diệp Bảo Quỳnh', '2024-06-02 00:00:00', '2024-01-12 00:00:00'),
(35, 'client', 'client33@gmail.com', 'client33', 'Dương Lê Quỳnh', '2024-05-05 00:00:00', '2024-01-07 00:00:00'),
(36, 'client', 'client34@gmail.com', 'client34', 'Lê Minh Bảo', '2024-10-11 00:00:00', '2024-01-16 00:00:00'),
(37, 'client', 'client35@gmail.com', 'client35', 'Nguyễn Thị Minh', '2024-11-12 00:00:00', '2024-01-27 00:00:00'),
(38, 'client', 'thw@gmail.com', '$2y$10$80NxrYxWUQGS5WRZKTjHt.KTV5oG.MoFjWrlquD5zSP4aEzHmPKLe', 'thwthw', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `account_info`
--

DROP TABLE IF EXISTS `account_info`;
CREATE TABLE IF NOT EXISTS `account_info` (
  `id` int NOT NULL AUTO_INCREMENT,
  `id_user` int NOT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `createdate` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `active` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `account_info`
--

INSERT INTO `account_info` (`id`, `id_user`, `phone`, `address`, `createdate`, `active`) VALUES
(1, 1, '0565284762', 'thu duc', '2024-12-12 11:44:56', 1),
(2, 1, '0987644675', 'q2', '2024-12-12 11:56:48', 0);

-- --------------------------------------------------------

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
CREATE TABLE IF NOT EXISTS `category` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `image` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `category`
--

INSERT INTO `category` (`id`, `name`, `image`) VALUES
(1, 'cây mini', 'img/deban.jpg'),
(2, 'cây không khí', 'img/khongkhi.jpg'),
(3, 'cây handmade', 'img/handmade.jpg'),
(4, 'haha', 'img/category_675a784760f920.29850475.jpg');

-- --------------------------------------------------------

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
CREATE TABLE IF NOT EXISTS `comments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `user_id` int NOT NULL,
  `user_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment_content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `createdate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `comments`
--

INSERT INTO `comments` (`id`, `product_id`, `user_id`, `user_name`, `comment_content`, `createdate`) VALUES
(1, 56, 1, 'Cẩm Nhi', 'hhh', NULL),
(2, 56, 1, 'Cẩm Nhi', 'dfg', '2024-12-12 12:01:46');

-- --------------------------------------------------------

--
-- Table structure for table `feedback`
--

DROP TABLE IF EXISTS `feedback`;
CREATE TABLE IF NOT EXISTS `feedback` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `phone` int DEFAULT NULL,
  `email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `content` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `feedback`
--

INSERT INTO `feedback` (`id`, `name`, `phone`, `email`, `content`) VALUES
(1, 'Vũ Hải', 92312493, 'vuhai@gmail.com', 'Là người khá kỹ tính, nên những thứ tôi chọn thường yêu cầu rất cao. Nhưng may mắn thay, tôi mua cây tại đây các bạn tư vấn rất nhiệt tình và khá chi tiết. Hi vọng các bạn sẽ vẫn giữ được sự chuyên nghiệp này, tôi sẽ ủng hộ dài dài.'),
(2, 'Trương Thị', 2039428, 'truong111@gmail.com', 'Tôi yêu hoa cảnh và kinh doanh. Tôi tìm được vườn có nhiều loại cây khá độc và dễ thương. Biết là cạnh tranh nhưng các bạn rất thoải mái tư vấn về kinh doanh và chăm sóc cây. Hi vọng hợp tác dài lâu với vườn.'),
(3, 'Đặng Thị Lệ', 23425436, 'Dangthi32@gmail.com', 'Tôi là người yêu thích cây cảnh, hoa hòe, tìm hoài không biết nên mua cái gì để chưng cho phòng khách cả. Tình cờ tìm được trang web vuoncaymini.com, click vào xem thì quá ư là thích, nó vừa lạ, vừa bé, vừa xinh, không chịu nỗi.'),
(4, 'Chung Phối', 3476546, 'phoi@gmail.com', 'Tôi quyết định trang trí bàn làm việc bằng những cây xanh, mà thấy ở đâu cũng những cây lớn quá cỡ. Được người bạn giới thiệu lên vuoncaymini.com xem. Thế là bàn của tôi không những xinh mà còn sinh động nữa chứ.'),
(5, '', 967984326, 'dangthicamnhi12@gmail.com', 'nhinhi hgtliytd gtu'),
(6, 'Nhi Đặng', 967984326, 'dangthicamnhi12@gmail.com', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Velit illum harum corporis libero repellat fugit neque suscipit distinctio rem ipsa facere sunt molestias deserunt aliquid, tempora sit beatae nulla deleniti.'),
(7, 'Nhi Đặng', 967984326, 'dangthicamnhi12@gmail.com', 'sdfghklt ???? ');

-- --------------------------------------------------------

--
-- Table structure for table `order`
--

DROP TABLE IF EXISTS `order`;
CREATE TABLE IF NOT EXISTS `order` (
  `id` int NOT NULL AUTO_INCREMENT,
  `createdate` datetime DEFAULT NULL,
  `custom_id` int DEFAULT NULL,
  `fullname` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `phone` varchar(20) COLLATE utf8mb3_unicode_ci NOT NULL,
  `sttOrder` int DEFAULT NULL,
  `address` varchar(255) COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `custom_id` (`custom_id`),
  KEY `sttOrder` (`sttOrder`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `order`
--

INSERT INTO `order` (`id`, `createdate`, `custom_id`, `fullname`, `phone`, `sttOrder`, `address`) VALUES
(37, '2024-12-01 05:07:46', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc'),
(38, '2024-12-03 05:09:05', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc'),
(39, '2024-12-12 05:16:28', 1, 'Cẩm Nhi', '0565284762', 5, 'thu duc'),
(40, '2024-12-12 05:21:18', 1, 'Cẩm Nhi', '0565284762', 3, 'thu duc'),
(41, '2024-12-12 05:25:38', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc'),
(42, '2024-02-29 05:28:44', 1, 'Cẩm Nhi', '0565284762', 1, 'thu duc'),
(43, '2024-09-11 05:31:16', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc'),
(44, '2024-12-05 05:45:45', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc');

--
-- Triggers `order`
--
DROP TRIGGER IF EXISTS `tg_xacnhanDonHang`;
DELIMITER $$
CREATE TRIGGER `tg_xacnhanDonHang` AFTER UPDATE ON `order` FOR EACH ROW BEGIN
        DECLARE v_oldSttName VARCHAR(10);
    DECLARE v_newSttName VARCHAR(10);
    DECLARE v_orderID INT(11);
    DECLARE v_productID INT(11);
    DECLARE v_quantity INT(11);
    DECLARE v_count INTEGER;
    DECLARE v_found BOOLEAN;
        #Trường hợp xác nhận từ Cart ---> Draft
        IF (OLD.sttOrder <> NEW.sttOrder) THEN
                BEGIN
                                IF (OLD.sttOrder = 1 AND NEW.sttOrder = 2) THEN
                                BEGIN
                                        DECLARE my_cursor cursor FOR
                                                (SELECT _product, o.quantity FROM `order_line` o WHERE id_order = NEW.ID );
                                        DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_found := TRUE;
                                        SET v_count = 0;
                                        OPEN my_cursor;
                                                my_loop: loop
                                                        fetch my_cursor INTO v_productID, v_quantity;
                                                        #kết thúc vòng lặp khi đã duyệt hết bản ghi trên cursor
                                                        IF v_found THEN leave my_loop;
                                                        END IF;
                            #Vì đã có TRIGGER test đặt hàng, 1 khi đặt hàng nghĩa là đủ số lượng!
                                                        CALL capnhat_SoLuongSanPham(v_productID, v_quantity);
                                                        SET v_count = v_count +1;
                                                END loop my_loop;
                                        close my_cursor;
                                END;
                        END IF;
                END;
        END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `order_line`
--

DROP TABLE IF EXISTS `order_line`;
CREATE TABLE IF NOT EXISTS `order_line` (
  `id_order` int NOT NULL,
  `id_product` int NOT NULL,
  `quantity` int DEFAULT NULL,
  `price` double NOT NULL,
  PRIMARY KEY (`id_order`,`id_product`),
  KEY `id_order` (`id_order`,`id_product`),
  KEY `id_product` (`id_product`),
  KEY `id_order_2` (`id_order`),
  KEY `id_product_2` (`id_product`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `order_line`
--

INSERT INTO `order_line` (`id_order`, `id_product`, `quantity`, `price`) VALUES
(37, 62, 2, 239000),
(37, 63, 1, 1216000),
(38, 56, 1, 208098),
(38, 57, 1, 16245700),
(39, 56, 1, 208098),
(39, 57, 1, 16245700),
(39, 58, 1, 6000000),
(40, 62, 1, 239000),
(40, 63, 1, 1216000),
(40, 64, 1, 4678000),
(41, 62, 1, 239000),
(42, 50, 1, 50009),
(43, 47, 3, 100000000),
(43, 49, 1, 1000000),
(43, 50, 1, 50009),
(43, 51, 1, 3816500),
(43, 62, 1, 239000),
(43, 63, 1, 1216000),
(44, 74, 1, 50000);

-- --------------------------------------------------------

--
-- Table structure for table `pricelist`
--

DROP TABLE IF EXISTS `pricelist`;
CREATE TABLE IF NOT EXISTS `pricelist` (
  `priceID` int NOT NULL AUTO_INCREMENT,
  `productID` int DEFAULT NULL,
  `price` float DEFAULT NULL,
  `startdate` date DEFAULT NULL,
  `enddate` date DEFAULT NULL,
  PRIMARY KEY (`priceID`),
  KEY `productID` (`productID`)
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `pricelist`
--

INSERT INTO `pricelist` (`priceID`, `productID`, `price`, `startdate`, `enddate`) VALUES
(1, 66, 109, '2024-04-11', '2024-12-12'),
(2, 66, 109, '2024-04-11', '2024-12-12'),
(3, 60, 159, '2024-04-29', '2024-12-28'),
(4, 60, 364, '2024-08-17', '2024-12-14'),
(5, 56, 316, '2024-01-04', '2024-12-06'),
(6, 57, 162, '2024-07-25', '2024-12-30'),
(7, 52, 410, '2024-08-09', '2024-12-27'),
(8, 48, 315, '2024-05-28', '2024-12-17'),
(9, 65, 321, '2024-11-16', '2024-12-23'),
(10, 64, 399, '2024-02-08', '2024-12-22'),
(11, 48, 58, '2024-12-25', '2024-12-13'),
(12, 67, 282, '2024-07-16', '2024-12-06'),
(13, 56, 325, '2024-01-14', '2024-12-11'),
(14, 58, 60, '2024-08-26', '2024-12-26'),
(15, 61, 166, '2024-06-16', '2024-12-08'),
(16, 62, 239, '2024-05-19', '2024-12-25'),
(17, 52, 276, '2024-10-02', '2024-12-19'),
(18, 51, 298, '2024-06-22', '2024-12-12'),
(19, 69, 396, '2024-01-17', '2024-12-22'),
(20, 48, 157, '2024-05-07', '2024-12-07'),
(21, 56, 208, '2024-09-30', '2024-12-12'),
(22, 66, 491, '2024-05-08', '2024-12-01'),
(23, 59, 490, '2024-05-08', '2024-12-11'),
(24, 64, 467, '2024-06-06', '2024-12-28'),
(25, 59, 400, '2024-05-14', '2024-12-18'),
(26, 63, 121, '2024-01-28', '2024-12-30'),
(27, 51, 381, '2024-05-09', '2024-12-16'),
(28, 69, 389, '2024-09-22', '2024-12-15'),
(29, 59, 53, '2024-05-07', '2024-12-07'),
(30, 50, 50, '2024-06-01', '2024-12-23'),
(31, 69, 100, '2016-05-01', '2024-08-08'),
(33, 72, 3050000, '2024-11-18', '2025-01-01'),
(35, 47, 0, '2024-11-19', '0000-00-00'),
(36, 47, 10000, '2024-11-19', '0000-00-00'),
(37, 47, 5489000000000, '2024-11-19', '0000-00-00'),
(38, 47, 10000, '2024-11-19', '2025-11-19'),
(39, 49, 10000, '2024-11-19', '2025-11-19'),
(40, 49, 10000, '2024-11-19', '2025-11-19'),
(41, 47, 10000, '2024-11-19', '2025-11-19'),
(42, 47, 10000, '2024-11-19', '2025-11-19'),
(43, 48, 15789000, '2024-11-19', '2025-11-19'),
(44, 50, 50009, '2024-11-19', '2025-11-19'),
(45, 51, 3816500, '2024-11-19', '2025-11-19'),
(46, 52, 276600, '2024-11-19', '2025-11-19'),
(47, 53, 4567900, '2024-11-19', '2025-11-19'),
(48, 54, 34567800, '2024-11-19', '2025-11-19'),
(49, 55, 76890, '2024-11-19', '2025-11-19'),
(50, 56, 208098, '2024-11-19', '2025-11-19'),
(51, 57, 16245700, '2024-11-19', '2025-11-19'),
(52, 69, 389980, '2024-11-19', '2025-11-19'),
(53, 68, 8790540, '2024-11-19', '2025-11-19'),
(54, 67, 282000, '2024-11-19', '2025-11-19'),
(55, 66, 491000, '2024-11-19', '2025-11-19'),
(56, 65, 3216700, '2024-11-19', '2025-11-19'),
(57, 64, 4678000, '2024-11-19', '2025-11-19'),
(58, 63, 1216000, '2024-11-19', '2025-11-19'),
(59, 62, 239000, '2024-11-19', '2025-11-19'),
(60, 61, 166000, '2024-11-19', '2025-11-19'),
(61, 60, 3646700, '2024-11-19', '2025-11-19'),
(62, 58, 6000000, '2024-11-19', '2025-11-19'),
(63, 59, 530000, '2024-11-19', '2025-11-19'),
(64, 49, 1000000, '2024-11-19', '2025-11-19'),
(65, 47, 100000000, '2024-11-19', '2025-11-19'),
(66, 74, 50000, '2024-12-12', '2025-01-01');

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
CREATE TABLE IF NOT EXISTS `product` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `saleoff` int DEFAULT NULL,
  `category` int DEFAULT NULL,
  `imagiUrl` varchar(225) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  `short_descripsion` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci,
  `inStock` int DEFAULT '0',
  `isAvailable` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`id`, `name`, `saleoff`, `category`, `imagiUrl`, `short_descripsion`, `inStock`, `isAvailable`) VALUES
(47, 'Santa Claus Tứ Phương', 7, 1, 'img/product_673cbfab287864.28489226.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 20, 1),
(48, 'Hộp Gỗ Ống Điếu', 0, 3, 'img/mn2.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(49, 'Bigly Móng Rồng', 10, 3, 'img/product_673cbe2944bc19.06645048.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(50, 'Hộp Gỗ Lá Tim', 10, 3, 'img/mn4.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(51, 'Merry Chrimas Sen Kim', 10, 3, 'img/mn5.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(52, 'Hộp Gỗ Móng Rồng', 10, 3, 'img/mn6.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(53, 'Gỗ Vẽ Cá Sấu', 10, 3, 'img/mn7.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(54, 'Snowman Sen Phật Bà', 10, 3, 'img/mn8.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(55, 'Giọt Nước Màu Sắc', 10, 2, 'img/kk1.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(56, 'Giọt Nước Đen Trắng', 10, 2, 'img/kk2.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(57, 'Giọt Nước Dây Treo', 10, 2, 'img/kk3.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(58, 'Đại Dương Đa Sắc', 10, 2, 'img/kk4.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(59, 'Cây Không Khí AT001', 10, 2, 'img/kk5.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(60, 'Cây Không Khí', 10, 2, 'img/kk6.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(61, 'Biển Xanh Nhiệt Đới', 10, 2, 'img/product_673cc1d825f894.14345485.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(62, 'Cây Đồng Tiền', 10, 1, 'img/cmn1.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(63, 'Cây Mini Hồng Xinh', 10, 1, 'img/cmn2.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(64, 'Cây Trầ Bà Sữa', 10, 1, 'img/cmn3.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(65, 'Cây DGA Huyết Dụ', 10, 1, 'img/cmn4.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(66, 'Cây Tiểu Cảnh Để Bàn', 10, 1, 'img/cmn5.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(67, 'Cây Môn Xanh Nhật Bản', 10, 1, 'img/cmn6.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(68, 'Cây Môn Nhí Lá Tròn', 10, 1, 'img/cmn7.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(69, 'Cây Ngũ Gia Bì', 10, 1, 'img/cmn8.jpg', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Ab fugiat, expedita ut, suscipit officia tenetur enim error nulla perferendis dicta quaerat saepe, quo placeat odit quos tempore consectetur corrupti modi.', 10, 1),
(72, 'Cây dương xỉ', 10, 1, 'img/product_673a2a830ed644.54278460.jpg', 'Cây thực vật', 300, 1),
(74, 'haha1', 4, 4, 'img/product_675a786cd4a601.93740109.jpg', 'cay oki', 25, 1);

-- --------------------------------------------------------

--
-- Table structure for table `sttorder`
--

DROP TABLE IF EXISTS `sttorder`;
CREATE TABLE IF NOT EXISTS `sttorder` (
  `sttID` int NOT NULL AUTO_INCREMENT,
  `sttName` varchar(70) CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`sttID`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `sttorder`
--

INSERT INTO `sttorder` (`sttID`, `sttName`) VALUES
(1, 'Chờ xác nhận'),
(2, 'Đang vận chuyển'),
(3, 'Đang giao hàng'),
(4, 'Đã giao hàng'),
(5, 'Đơn đã hủy');

--
-- Constraints for dumped tables
--

--
-- Constraints for table `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`),
  ADD CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `account` (`id`);

--
-- Constraints for table `order`
--
ALTER TABLE `order`
  ADD CONSTRAINT `order_ibfk_1` FOREIGN KEY (`sttOrder`) REFERENCES `sttorder` (`sttID`),
  ADD CONSTRAINT `order_ibfk_2` FOREIGN KEY (`custom_id`) REFERENCES `account` (`id`);

--
-- Constraints for table `order_line`
--
ALTER TABLE `order_line`
  ADD CONSTRAINT `order_line_ibfk_1` FOREIGN KEY (`id_order`) REFERENCES `order` (`id`),
  ADD CONSTRAINT `order_line_ibfk_2` FOREIGN KEY (`id_product`) REFERENCES `product` (`id`);

--
-- Constraints for table `pricelist`
--
ALTER TABLE `pricelist`
  ADD CONSTRAINT `pricelist_ibfk_1` FOREIGN KEY (`productID`) REFERENCES `product` (`id`);

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `product_ibfk_1` FOREIGN KEY (`category`) REFERENCES `category` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
