-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Dec 14, 2024 at 07:58 AM
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_thongkeDonHang` (IN `startdate` DATETIME, IN `enddate` DATETIME, IN `categoryPD` INT(11))   begin
SELECT  ol.quantity * activePrice(ol.id_product)as total, o.id, o.createdate FROM order_line ol JOIN( SELECT o.id, o.createdate FROM `order` o WHERE o.sttOrder=4 AND o.createdate BETWEEN startdate AND enddate) o ON ol.id_order=o.id WHERE ol.id_product IN
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
) ENGINE=InnoDB AUTO_INCREMENT=40 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

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
(38, 'client', 'thw@gmail.com', '$2y$10$80NxrYxWUQGS5WRZKTjHt.KTV5oG.MoFjWrlquD5zSP4aEzHmPKLe', 'thwthw', NULL, NULL),
(39, 'client', 'anhminh@gmail.com', '$2y$10$tWHcVz1OYlMeCqNOZ5JFOuxX5HUWL2fcmIqplW3dGS5D7NRBXMP/6', 'Đào Anh Minh', NULL, NULL);

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
(4, 'Hoa cỏ', 'img/category_675d21428a1da6.86622744.jpg');

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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `comments`
--

INSERT INTO `comments` (`id`, `product_id`, `user_id`, `user_name`, `comment_content`, `createdate`) VALUES
(1, 56, 1, 'Cẩm Nhi', 'hhh', NULL),
(2, 56, 1, 'Cẩm Nhi', 'dfg', '2024-12-12 12:01:46'),
(3, 47, 1, 'Cẩm Nhi', 'cay gia thanh hop ly', '2024-12-14 13:35:19'),
(4, 74, 39, 'Đào Anh Minh', 'cây xinh', '2024-12-14 13:38:36');

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
) ENGINE=InnoDB AUTO_INCREMENT=48 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `order`
--

INSERT INTO `order` (`id`, `createdate`, `custom_id`, `fullname`, `phone`, `sttOrder`, `address`) VALUES
(37, '2024-12-01 05:07:46', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc'),
(38, '2024-12-03 05:09:05', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc'),
(39, '2024-12-12 05:16:28', 1, 'Cẩm Nhi', '0565284762', 5, 'thu duc'),
(40, '2024-12-12 05:21:18', 1, 'Cẩm Nhi', '0565284762', 3, 'thu duc'),
(41, '2024-12-12 05:25:38', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc'),
(42, '2024-02-29 05:28:44', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc'),
(43, '2024-09-11 05:31:16', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc'),
(44, '2024-12-05 05:45:45', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc'),
(45, '2024-12-12 06:27:00', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc'),
(46, '2024-12-13 14:20:54', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc'),
(47, '2024-12-14 06:30:00', 1, 'Cẩm Nhi', '0565284762', 4, 'thu duc');

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
(44, 74, 1, 50000),
(45, 47, 1, 100000000),
(45, 49, 1, 1000000),
(45, 50, 1, 50009),
(45, 51, 1, 3816500),
(45, 56, 1, 208098),
(45, 57, 1, 16245700),
(45, 58, 1, 6000000),
(45, 63, 1, 1216000),
(45, 64, 1, 4678000),
(45, 72, 1, 3050000),
(45, 74, 4, 50000),
(46, 63, 1, 1216000),
(46, 74, 1, 50000),
(47, 47, 1, 100000000);

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
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

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
(66, 74, 50000, '2024-12-12', '2025-01-01'),
(67, 75, 780990000, '2024-12-14', '2025-01-01'),
(68, 76, 67900000, '2024-12-14', '2025-01-01'),
(69, 77, 1050000000, '2024-12-14', '2025-01-01'),
(70, 78, 4500000, '2024-12-14', '2025-01-01'),
(71, 79, 350000000, '2024-12-14', '2025-01-01'),
(72, 80, 5600000, '2024-12-14', '2025-01-01'),
(73, 81, 458000000, '2024-12-14', '2025-01-01'),
(74, 82, 56500000, '2024-12-14', '2025-01-01'),
(75, 47, 100000000, '2024-12-14', '2025-12-14'),
(76, 74, 50000, '2024-12-14', '2025-12-14'),
(77, 74, 50000, '2024-12-14', '2025-12-14'),
(78, 75, 780990000, '2024-12-14', '2025-12-14'),
(79, 47, 100000000, '2024-12-14', '2025-12-14'),
(80, 48, 15789000, '2024-12-14', '2025-12-14'),
(81, 49, 1000000, '2024-12-14', '2025-12-14'),
(82, 50, 50009, '2024-12-14', '2025-12-14'),
(83, 51, 3816500, '2024-12-14', '2025-12-14');

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
) ENGINE=InnoDB AUTO_INCREMENT=83 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`id`, `name`, `saleoff`, `category`, `imagiUrl`, `short_descripsion`, `inStock`, `isAvailable`) VALUES
(47, 'Santa Claus Tứ Phương', 7, 1, 'img/product_675d26ef8bc958.45966701.jpg', '\"Santa Claus Tứ Phương\" là một thuật ngữ phổ biến trong văn hóa Giáng sinh tại Việt Nam, ám chỉ hình ảnh ông già Noel (Santa Claus) trong những trang phục đặc trưng với bộ râu trắng dài, áo đỏ và chiếc mũ đỏ, mang quà tặng cho trẻ em vào dịp lễ Giáng sinh. Tuy nhiên, \"Tứ Phương\" có thể được hiểu là sự lan tỏa của hình ảnh ông già Noel khắp mọi nơi, khắp bốn phương trời, từ các thành phố lớn đến những vùng quê xa xôi.\r\nHình ảnh \"Santa Claus Tứ Phương\" biểu trưng cho tinh thần của mùa Giáng sinh: sự sẻ chia, yêu thương và niềm vui mà ông già Noel mang đến cho mọi người, không phân biệt quốc gia hay địa phương. Nó thể hiện sự kết nối giữa các nền văn hóa và truyền thống khác nhau trên thế giới, cùng nhau chào đón mùa lễ hội ấm áp và đầy ý nghĩa.\r\nMỗi năm vào dịp Giáng sinh, hình ảnh ông già Noel (Santa Claus) trở nên phổ biến hơn trong các buổi lễ hội, sự kiện và các chương trình giải trí, tạo không khí vui tươi và ấm cúng cho mọi người, đặc biệt là trẻ em.', 20, 1),
(48, 'Hộp Gỗ Ống Điếu', 0, 3, 'img/mn2.jpg', '\"Cây hộp gỗ ống điếu\" có thể là một cách gọi chung cho một loại cây gỗ được sử dụng để chế tạo các hộp đựng ống điếu, hoặc đơn giản là loại cây có gỗ cứng, dùng để làm các sản phẩm thủ công mỹ nghệ. Tuy nhiên, nếu bạn đang nhắc đến một loại cây cụ thể có tên \"Cây hộp gỗ ống điếu,\" có thể là một sự nhầm lẫn, vì không có loài cây nào mang tên này trong danh sách thực vật chính thức.\r\nNếu bạn muốn tìm hiểu về các loại gỗ được sử dụng để chế tạo hộp đựng ống điếu, các loại gỗ tự nhiên như gỗ hương, gỗ sồi, gỗ gụ, hoặc gỗ thông thường được ưa chuộng nhờ tính chất bền, đẹp, và dễ gia công. Những loại gỗ này không chỉ có màu sắc đẹp mà còn mang lại mùi hương nhẹ nhàng và độ bền cao, phù hợp để làm các vật dụng như hộp đựng ống điếu.', 10, 1),
(49, 'Bigly Móng Rồng', 10, 3, 'img/product_673cbe2944bc19.06645048.jpg', 'Cây Móng Rồng là tên gọi phổ biến của một số loài cây, thường được trồng làm cảnh hoặc sử dụng trong y học dân gian. Loài cây này có đặc điểm đặc biệt ở hình dáng lá, thân hoặc hoa giống với móng vuốt rồng, tạo nên vẻ ngoài độc đáo và thu hút.\r\nĐặc điểm của cây Móng Rồng (Artabotrys hexapetalus):\r\nTên khoa học: Artabotrys hexapetalus.\r\nLoài cây này còn được gọi là móng rồng hoa, thuộc họ Na (Annonaceae).\r\nHình dáng:\r\nCây dạng dây leo, có thân mềm dẻo, dễ dàng bám vào các giá đỡ hoặc hàng rào.\r\nLá hình bầu dục, màu xanh bóng, tạo vẻ mát mẻ và tươi mát cho không gian.\r\nHoa:\r\nHoa móng rồng có màu xanh lục nhạt khi mới nở, sau đó chuyển dần sang vàng.\r\nHoa có hương thơm nhẹ nhàng, dễ chịu, thường nở vào mùa hè và thu.\r\nQuả:\r\nQuả hình tròn, kích thước nhỏ, khi chín chuyển màu vàng cam.\r\nỨng dụng của cây Móng Rồng:\r\nTrang trí cảnh quan:\r\nCây móng rồng thường được trồng làm cây cảnh leo giàn, hàng rào, hoặc trên tường để tạo bóng mát và làm đẹp không gian.\r\nLà loại cây dễ trồng, phù hợp với khí hậu nhiệt đới và không đòi hỏi nhiều công chăm sóc.\r\nÝ nghĩa phong thủy:\r\nCây móng rồng được coi là biểu tượng của sức mạnh và sự bảo vệ. Người ta tin rằng cây có thể mang lại năng lượng tích cực và xua đuổi điều xấu.\r\nSử dụng trong y học:\r\nMột số bộ phận của cây được sử dụng trong y học dân gian để hỗ trợ điều trị một số bệnh, như giảm viêm, giảm đau.\r\nTạo hương thơm tự nhiên:\r\nHoa móng rồng có mùi thơm dễ chịu, thường được sử dụng để làm nước hoa hoặc khử mùi.\r\nCách trồng và chăm sóc cây Móng Rồng:\r\nÁnh sáng: Cây thích ánh sáng tự nhiên, nên trồng ở nơi có ánh sáng vừa phải, không quá nắng gắt.\r\nĐất: Ưu tiên đất tơi xốp, thoát nước tốt.\r\nTưới nước: Tưới đều đặn nhưng không để cây bị ngập úng.\r\nCắt tỉa: Cắt tỉa cây thường xuyên để giữ dáng và kích thích ra hoa.\r\nLưu ý:\r\nCây móng rồng có thể mang lại vẻ đẹp độc đáo cho không gian sống, nhưng cần chú ý đến đặc tính dây leo, tránh để cây phát triển quá mức gây rối hoặc ảnh hưởng đến công trình xung quanh.', 10, 1),
(50, 'Hộp Gỗ Lá Tim', 10, 3, 'img/mn4.jpg', 'Hộp Gỗ Lá Tim là một loại hộp gỗ được thiết kế với hình dáng hoặc hoa văn giống chiếc lá tim, thường mang ý nghĩa tình yêu, sự gắn bó và lòng chân thành. Đây là sản phẩm thủ công mỹ nghệ phổ biến, vừa có giá trị sử dụng vừa mang tính thẩm mỹ cao, thích hợp làm quà tặng hoặc vật trang trí.\r\nĐặc điểm của Hộp Gỗ Lá Tim\r\nChất liệu:\r\nHộp thường được làm từ các loại gỗ tự nhiên như gỗ thông, gỗ hương, gỗ sồi hoặc gỗ gụ.\r\nChất liệu gỗ tự nhiên tạo sự mộc mạc, sang trọng và bền bỉ.\r\nThiết kế:\r\n\r\nHình dáng hộp hoặc nắp hộp được khắc hoặc tạo hình theo kiểu chiếc lá tim.\r\nMột số hộp được chạm khắc họa tiết tinh xảo để tăng tính nghệ thuật.\r\nKích thước:\r\nHộp có nhiều kích cỡ khác nhau, phù hợp cho các mục đích sử dụng như đựng trang sức, quà tặng, hoặc vật dụng cá nhân nhỏ gọn.\r\nMàu sắc:\r\nThường giữ màu gỗ tự nhiên, được sơn bóng hoặc phủ lớp bảo vệ để tăng độ bền và giữ nét đẹp tự nhiên.\r\nCông dụng của Hộp Gỗ Lá Tim\r\nLàm quà tặng:\r\nHộp gỗ lá tim thường được dùng làm quà tặng trong các dịp như lễ tình nhân, kỷ niệm, sinh nhật, hoặc làm hộp đựng quà cưới.\r\nTrang trí:\r\nĐặt hộp trên bàn làm việc, kệ sách, hoặc bàn trang điểm để tăng tính thẩm mỹ cho không gian.\r\nĐựng đồ:\r\nSử dụng để đựng trang sức, phụ kiện nhỏ, hoặc các đồ vật giá trị như kỷ vật cá nhân.\r\nÝ nghĩa của Hộp Gỗ Lá Tim\r\nHình dáng lá tim tượng trưng cho tình yêu và sự gắn kết, nên sản phẩm này mang ý nghĩa đặc biệt khi làm quà tặng.\r\nChất liệu gỗ tự nhiên biểu trưng cho sự trường tồn, giản dị nhưng tinh tế, thể hiện tấm lòng chân thành và mộc mạc của người tặng.\r\nCách bảo quản Hộp Gỗ Lá Tim\r\nVệ sinh: Lau sạch bằng khăn mềm, tránh sử dụng chất tẩy rửa mạnh.\r\nTránh ẩm ướt: Bảo quản nơi khô ráo để tránh ẩm mốc hoặc mối mọt.\r\nBảo vệ bề mặt: Hạn chế va đập để giữ hộp không bị trầy xước hoặc nứt gãy.\r\nHộp Gỗ Lá Tim không chỉ là vật dụng hữu ích mà còn là món quà tinh tế, đầy ý nghĩa để thể hiện tình cảm và sự trân trọng đối với người nhận.', 10, 1),
(51, 'Merry Chrimas Sen Kim', 10, 3, 'img/mn5.jpg', 'Sen Kim - Ý Nghĩa Tên Gọi\r\nSen: Tượng trưng cho sự thuần khiết, cao quý, và thanh nhã. Trong văn hóa Á Đông, sen được xem là biểu tượng của sự thanh tịnh và vẻ đẹp vượt thời gian.\r\nKim: Mang ý nghĩa bền vững, quý giá, liên tưởng đến kim loại hoặc sự mạnh mẽ, trường tồn.\r\nSự kết hợp này có thể gợi lên hình ảnh một vật phẩm hoặc biểu tượng đẹp đẽ, mang giá trị sâu sắc.\r\n2. Nếu Sen Kim là một loại cây\r\nCây Sen Kim có thể là một giống cây trang trí, thường nhỏ gọn, với lá sắc nhọn như kim, phù hợp làm cảnh hoặc quà tặng phong thủy.\r\nĐặc điểm:\r\nLá cứng, xanh mướt, hoặc phủ một lớp ánh kim tự nhiên.\r\nDễ trồng, không cần chăm sóc quá nhiều, phù hợp với môi trường trong nhà hoặc ngoài trời.\r\n3. Nếu Sen Kim là sản phẩm hoặc thương hiệu\r\nCó thể đây là tên một dòng sản phẩm đặc biệt như:\r\nQuà tặng phong thủy: Các chậu cây nhân tạo hoặc sản phẩm trang trí mang ý nghĩa tài lộc và bình an.\r\nĐồ thủ công mỹ nghệ: Hộp gỗ, chậu cây, hoặc đồ vật trang trí làm từ chất liệu tự nhiên.\r\n4. Ứng dụng của Sen Kim\r\nTrang trí không gian sống: Cây hoặc sản phẩm \"Sen Kim\" mang tính nghệ thuật và tạo cảm giác thanh thoát, gần gũi thiên nhiên.\r\nLàm quà tặng ý nghĩa: Với ý nghĩa thanh cao và giá trị phong thủy, \"Sen Kim\" là lựa chọn lý tưởng cho các dịp đặc biệt như khai trương, tân gia, hay Giáng sinh.\r\n5. Ý tưởng phát triển Sen Kim\r\nThiết kế hiện đại: Nếu là cây hoặc sản phẩm, có thể kết hợp ánh kim loại, đèn LED hoặc hộp quà sang trọng để tăng giá trị.\r\nPhong thủy: Đưa vào ý nghĩa tài lộc, sự thịnh vượng để thu hút người dùng yêu thích sản phẩm độc đáo.', 10, 1),
(52, 'Hộp Gỗ Móng Rồng', 10, 3, 'img/mn6.jpg', 'Hộp Gỗ Móng Rồng là một sản phẩm thủ công tinh xảo, mang đậm yếu tố văn hóa và phong thủy Á Đông. Được chế tác từ gỗ tự nhiên, hộp gỗ này không chỉ có giá trị sử dụng cao mà còn là một món đồ trang trí đầy ý nghĩa, tượng trưng cho sự may mắn, bảo vệ và sức mạnh.\r\n\r\nĐặc điểm và chất liệu:\r\nChất liệu gỗ cao cấp: Hộp Gỗ Móng Rồng thường được làm từ các loại gỗ quý như gỗ sồi, gỗ hương, gỗ trắc, gỗ cẩm lai... với các vân gỗ đẹp mắt và bền chắc, mang lại cảm giác tự nhiên và gần gũi. Gỗ được xử lý kỹ lưỡng để đảm bảo độ bền và khả năng chống mối mọt.\r\n\r\nChạm khắc tinh xảo: Điểm đặc biệt của hộp gỗ này chính là hình ảnh móng rồng được chạm khắc hoặc khắc nổi rất chi tiết. Móng rồng là biểu tượng của quyền lực, sức mạnh và sự may mắn trong văn hóa Á Đông. Hình ảnh này cũng thể hiện sự bảo vệ, bảo vệ gia đình và tài sản của gia chủ.\r\n\r\nMàu sắc và hoàn thiện: Bề mặt gỗ được xử lý một cách tỉ mỉ, mài nhẵn và phủ lớp sơn bóng hoặc sơn mài, tạo độ sáng bóng và bảo vệ gỗ khỏi tác động của môi trường. Màu sắc của hộp gỗ thường dao động từ nâu sẫm đến màu vàng sáng, tuỳ vào loại gỗ sử dụng, mang lại cảm giác sang trọng và cổ điển.\r\n\r\nKích thước và thiết kế:\r\nKích thước nhỏ gọn: Hộp gỗ có thể được thiết kế với nhiều kích thước khác nhau, thường có kích thước vừa phải, dễ dàng đặt trên bàn làm việc, tủ kệ hoặc bàn thờ.\r\nChế tác đa dạng: Một số mẫu hộp gỗ Móng Rồng còn có thể được thiết kế với nhiều ngăn, thích hợp cho việc đựng các vật dụng như trang sức, giấy tờ quan trọng, tiền mặt hoặc vật phẩm phong thủy.\r\nÝ nghĩa phong thủy:\r\nTượng trưng cho quyền lực và may mắn: Móng rồng trong phong thủy đại diện cho sức mạnh, quyền lực và khả năng bảo vệ. Sản phẩm này thường được cho là sẽ mang lại sự may mắn, thịnh vượng và giúp xua đuổi tà khí cho gia chủ.\r\n\r\nBảo vệ tài sản và gia đình: Hình ảnh móng rồng không chỉ mang ý nghĩa tượng trưng mà còn được tin rằng có thể bảo vệ những vật dụng quý giá của gia đình, giữ cho mọi thứ luôn an toàn và phát đạt.\r\n\r\nChuyên dùng làm quà tặng: Hộp Gỗ Móng Rồng cũng là một món quà tặng ý nghĩa trong các dịp lễ Tết, sinh nhật, khai trương hoặc các sự kiện trọng đại. Nó không chỉ mang giá trị vật chất mà còn thể hiện tấm lòng của người tặng trong việc cầu chúc cho người nhận sức khỏe, tài lộc và sự thịnh vượng.\r\n\r\nỨng dụng:\r\nTrang trí nội thất: Hộp Gỗ Móng Rồng có thể được đặt ở các vị trí trang trọng trong nhà như phòng khách, phòng làm việc hoặc phòng thờ để tạo điểm nhấn và mang lại không gian sang trọng, quý phái.\r\nĐựng đồ cá nhân: Hộp gỗ cũng rất tiện dụng trong việc lưu trữ các vật dụng nhỏ như trang sức, đồng hồ, chìa khóa, hay các vật phẩm phong thủy, giúp tổ chức không gian sống gọn gàng và ngăn nắp.\r\nLợi ích lâu dài:\r\nVới sự bền bỉ của gỗ tự nhiên và sự chăm chút trong quá trình chế tác, Hộp Gỗ Móng Rồng không chỉ mang lại giá trị sử dụng cao mà còn trở thành món đồ có giá trị qua thời gian, đặc biệt nếu được chăm sóc đúng cách. Thêm vào đó, các chi tiết chạm khắc sẽ trở nên càng thêm đẹp và độc đáo theo năm tháng.\r\n\r\nVới tất cả những đặc điểm và ý nghĩa này, Hộp Gỗ Móng Rồng không chỉ là một món đồ trang trí đơn thuần mà còn là vật phẩm phong thủy, mang lại may mắn và bảo vệ cho gia chủ.', 10, 1),
(53, 'Gỗ Vẽ Cá Sấu', 10, 3, 'img/mn7.jpg', 'Gỗ Vẽ Cá Sấu là một sản phẩm thủ công độc đáo, mang đậm dấu ấn nghệ thuật và văn hóa, kết hợp giữa chất liệu gỗ tự nhiên và hình ảnh động vật cá sấu. Sản phẩm này không chỉ có giá trị sử dụng mà còn có giá trị về mặt thẩm mỹ, với những họa tiết vẽ tay tinh xảo, mang lại vẻ đẹp sang trọng và độc đáo.\r\n\r\nĐặc điểm và chất liệu:\r\nChất liệu gỗ cao cấp:\r\nGỗ vẽ cá sấu thường được làm từ các loại gỗ tự nhiên như gỗ sồi, gỗ hương, gỗ trắc, hoặc các loại gỗ có vân đẹp và bền bỉ. Gỗ được xử lý cẩn thận, giúp bảo vệ khỏi mối mọt và giữ được vẻ đẹp tự nhiên qua thời gian.\r\nVẽ tay tinh xảo:\r\nĐiểm đặc biệt của sản phẩm này là những họa tiết cá sấu được vẽ hoàn toàn bằng tay, tạo nên sự độc đáo và chi tiết. Các nghệ nhân sử dụng kỹ thuật vẽ tinh xảo, thường là màu nước hoặc sơn dầu để tạo ra hình ảnh cá sấu sống động, rõ nét.\r\nChế tác thủ công:\r\nMỗi sản phẩm Gỗ Vẽ Cá Sấu đều được chế tác tỉ mỉ từng chi tiết. Quá trình chế tác đòi hỏi sự kiên nhẫn và khéo léo của người thợ, từ việc chọn lựa chất liệu gỗ, vẽ hình ảnh cho đến việc hoàn thiện sản phẩm bằng lớp sơn bóng bảo vệ.\r\nKích thước và thiết kế:\r\nKích thước đa dạng: Sản phẩm Gỗ Vẽ Cá Sấu có thể có nhiều kích thước khác nhau, từ những món đồ trang trí nhỏ như móc khóa, hộp nhỏ, cho đến các tác phẩm lớn như tranh vẽ hoặc các bức tượng cá sấu gỗ.\r\nThiết kế độc đáo: Các sản phẩm có thể là những bức tranh vẽ cá sấu, những tượng gỗ cá sấu hay thậm chí là các vật dụng trang trí nội thất, tất cả đều được vẽ với hình ảnh động vật cá sấu mạnh mẽ, gợi lên sự uy nghi và bí ẩn của loài vật này.\r\nÝ nghĩa và phong thủy:\r\nBiểu tượng của sự mạnh mẽ và bền bỉ:\r\n\r\nCá sấu trong văn hóa nhiều nơi là biểu tượng của sức mạnh, sự kiên cường và bền bỉ. Nó tượng trưng cho khả năng vượt qua thử thách và sự tồn tại lâu dài, điều này cũng phản ánh trong chất liệu gỗ vẽ cá sấu, một sản phẩm có giá trị và có thể tồn tại qua thời gian.\r\nBảo vệ và may mắn:\r\n\r\nCá sấu cũng được xem là một linh vật bảo vệ trong nhiều nền văn hóa, giúp xua đuổi tà ma và đem lại sự bình an, may mắn cho gia chủ. Sản phẩm này thường được sử dụng làm quà tặng phong thủy hoặc đặt trong nhà với mong muốn mang lại tài lộc, sự thịnh vượng.\r\nSự độc đáo trong trang trí:\r\n\r\nGỗ Vẽ Cá Sấu không chỉ là vật dụng phong thủy mà còn là món đồ trang trí nghệ thuật đầy ấn tượng. Hình ảnh cá sấu sống động sẽ là điểm nhấn nổi bật trong không gian sống, mang lại vẻ đẹp tự nhiên và sang trọng.\r\nỨng dụng và Lợi ích:\r\nTrang trí nội thất:\r\n\r\nSản phẩm Gỗ Vẽ Cá Sấu có thể dùng để trang trí phòng khách, phòng làm việc, phòng thờ hoặc các không gian khác trong ngôi nhà. Những chi tiết vẽ cá sấu sẽ mang đến không gian sống độc đáo, đầy nghệ thuật và cá tính.\r\nQuà tặng ý nghĩa:\r\n\r\nVới vẻ đẹp độc đáo và ý nghĩa phong thủy sâu sắc, Gỗ Vẽ Cá Sấu là món quà tuyệt vời cho các dịp lễ Tết, sinh nhật, khai trương hoặc tân gia. Nó thể hiện sự trân trọng và chúc phúc đến người nhận.\r\nLưu trữ vật phẩm phong thủy:\r\n\r\nNgoài tác dụng trang trí, sản phẩm cũng có thể sử dụng để đựng vật phẩm phong thủy như đá quý, vòng tay hay những đồ vật có giá trị khác. Nó giúp tổ chức không gian và mang lại sự hài hòa cho không gian sống.\r\nLợi ích lâu dài:\r\nSản phẩm Gỗ Vẽ Cá Sấu không chỉ có giá trị sử dụng cao mà còn là một tác phẩm nghệ thuật có thể lưu giữ qua thời gian. Khi chăm sóc và bảo quản đúng cách, nó có thể trở thành một món đồ quý giá và có giá trị lâu dài, đặc biệt là những sản phẩm có các họa tiết vẽ tay độc đáo và chất liệu gỗ quý.\r\nVới sự kết hợp giữa chất liệu gỗ tự nhiên, hình ảnh cá sấu mạnh mẽ và tinh xảo, Gỗ Vẽ Cá Sấu là sản phẩm mang giá trị thẩm mỹ cao, mang đến vẻ đẹp độc đáo và ý nghĩa phong thủy sâu sắc cho không gian sống của bạn.', 10, 1),
(54, 'Snowman Sen Phật Bà', 10, 3, 'img/mn8.jpg', 'Snowman Sen Phật Bà là một sản phẩm nghệ thuật độc đáo kết hợp giữa hình ảnh của người tuyết (snowman), hoa sen và hình tượng Phật Bà Quan Âm, mang đậm ý nghĩa tâm linh và sự thanh tịnh. Đây là sự hòa quyện giữa nghệ thuật trang trí và giá trị văn hóa, tạo nên một tác phẩm đẹp mắt, mang đến không chỉ vẻ đẹp thẩm mỹ mà còn những giá trị sâu sắc về tinh thần.\r\n\r\nĐặc điểm và chất liệu:\r\nChất liệu chế tác:\r\n\r\nSản phẩm thường được chế tác từ các chất liệu thủ công như gốm sứ, đất nung, hoặc chất liệu nhựa cao cấp, tạo nên sự bền bỉ và đẹp mắt cho sản phẩm. Các chi tiết được hoàn thiện một cách tỉ mỉ, từ hình dáng của người tuyết cho đến hoa sen và hình tượng Phật Bà.\r\nHình tượng người tuyết (Snowman):\r\n\r\nHình ảnh người tuyết trong tác phẩm thường được vẽ với vẻ ngoài đáng yêu, dễ thương, là biểu tượng của mùa đông và sự ngây thơ. Tuy nhiên, người tuyết này không chỉ đơn giản là hình ảnh mùa đông, mà còn được hòa quyện với các yếu tố tâm linh, làm tăng thêm sự ấm áp và hạnh phúc.\r\nHoa sen:\r\n\r\nHoa sen, trong văn hóa phương Đông, đặc biệt là trong Phật giáo, là biểu tượng của sự thuần khiết và giác ngộ. Hoa sen thể hiện sự thanh tịnh, vươn lên từ bùn lầy để nở hoa, giống như hành trình tu hành của con người vượt qua khổ đau để đạt đến giác ngộ.\r\nPhật Bà Quan Âm:\r\n\r\nPhật Bà Quan Âm, tượng trưng cho lòng từ bi vô lượng và sự cứu độ chúng sinh, là một biểu tượng của sự an lạc và bình yên. Hình ảnh Phật Bà được kết hợp vào sản phẩm này để tạo ra một tác phẩm mang tính chất tâm linh sâu sắc, vừa thể hiện sự bảo vệ, vừa mang đến may mắn và bình an.\r\nÝ nghĩa của Snowman Sen Phật Bà:\r\nBiểu tượng của sự bảo vệ và từ bi:\r\n\r\nSự kết hợp của người tuyết, hoa sen và Phật Bà Quan Âm tạo thành một biểu tượng mạnh mẽ của sự bảo vệ, từ bi và tình yêu thương. Phật Bà Quan Âm tượng trưng cho sự cứu độ và bảo vệ, trong khi người tuyết mang đến sự dễ thương, gần gũi và ấm áp.\r\nTinh thần giác ngộ và thanh tịnh:\r\n\r\nHoa sen là biểu tượng của sự giác ngộ trong Phật giáo. Với sự hiện diện của hoa sen và Phật Bà, sản phẩm này thể hiện sự hướng tới sự thuần khiết, vươn lên từ mọi khó khăn, và sự thanh tịnh trong tâm hồn.\r\nTạo sự bình an trong không gian sống:\r\n\r\nSản phẩm Snowman Sen Phật Bà không chỉ là một vật trang trí đẹp mắt mà còn mang lại năng lượng tích cực và sự bình an cho không gian sống. Đặt trong nhà, sản phẩm này giúp không gian trở nên ấm cúng và yên bình hơn.\r\nQuà tặng ý nghĩa:\r\n\r\nVới sự kết hợp giữa yếu tố tâm linh và nghệ thuật, Snowman Sen Phật Bà là món quà tuyệt vời cho những ai yêu thích nghệ thuật thủ công và các giá trị văn hóa Phật giáo. Đây cũng là món quà tặng mang ý nghĩa cầu chúc may mắn, bình an và hạnh phúc cho người nhận.\r\nỨng dụng và lợi ích:\r\nTrang trí nội thất:\r\n\r\nSnowman Sen Phật Bà có thể được đặt trong phòng khách, phòng thờ, hoặc bất kỳ không gian nào trong nhà. Nó là một điểm nhấn độc đáo, tạo sự hài hòa và an lành cho không gian sống.\r\nThích hợp cho các dịp lễ Tết:\r\n\r\nĐây là một món quà tặng ý nghĩa cho các dịp lễ Tết, sinh nhật, hoặc các dịp đặc biệt. Món quà không chỉ mang vẻ đẹp thẩm mỹ mà còn có giá trị tâm linh, giúp người nhận cảm nhận được sự bình an và may mắn.\r\nTăng cường năng lượng tích cực:\r\n\r\nĐặt Snowman Sen Phật Bà trong nhà có thể giúp gia chủ cảm nhận được sự an lạc và thanh tịnh. Đây là một sản phẩm mang giá trị tinh thần cao, giúp gạt bỏ lo âu, căng thẳng và mang đến sự thư giãn, an tâm.\r\nLợi ích lâu dài:\r\nSự bền vững và giá trị tinh thần:\r\nSnowman Sen Phật Bà không chỉ là một món đồ trang trí mà còn là một tác phẩm nghệ thuật có giá trị tinh thần lâu dài. Với chất liệu bền bỉ, sản phẩm này có thể trở thành một phần không thể thiếu trong không gian sống của bạn, mang lại sự bình an và hạnh phúc lâu dài.\r\nTổng kết:\r\nSnowman Sen Phật Bà là một sản phẩm nghệ thuật thủ công độc đáo, mang giá trị tâm linh và thẩm mỹ sâu sắc. Kết hợp hình ảnh người tuyết dễ thương, hoa sen thuần khiết và Phật Bà Quan Âm từ bi, sản phẩm này không chỉ làm đẹp không gian sống mà còn đem lại sự bình an, may mắn và năng lượng tích cực cho gia chủ.', 10, 1),
(55, 'Giọt Nước Màu Sắc', 10, 2, 'img/kk1.jpg', 'Giọt Nước Màu Sắc là một tác phẩm nghệ thuật độc đáo, kết hợp giữa hình ảnh giọt nước và các sắc màu tươi sáng, mang lại cảm giác tươi mới, sống động và đầy cảm hứng. Với sự kết hợp hài hòa của màu sắc và hình ảnh, sản phẩm này không chỉ là một tác phẩm trang trí mà còn mang trong mình ý nghĩa sâu sắc về sự sống, sự biến đổi và sự tươi mới trong cuộc sống.\r\n\r\nĐặc điểm và chất liệu:\r\nChất liệu chế tác:\r\n\r\nGiọt Nước Màu Sắc có thể được làm từ các chất liệu như thủy tinh, nhựa, sứ, gốm, hoặc các vật liệu nhựa cao cấp có khả năng phản chiếu ánh sáng tốt, tạo nên sự lung linh cho tác phẩm. Các chi tiết được hoàn thiện tỉ mỉ, mang lại vẻ đẹp hoàn hảo và ấn tượng.\r\nHình dáng giọt nước:\r\n\r\nGiọt nước trong tác phẩm này có thể được thiết kế theo hình dạng mềm mại, tinh tế, như một giọt nước thực tế nhưng được tô điểm với các hiệu ứng màu sắc tươi sáng. Giọt nước mang một vẻ đẹp trong suốt, như những viên ngọc quý, tạo nên sự thanh thoát và nhẹ nhàng.\r\nMàu sắc sống động:\r\n\r\nCác màu sắc có thể được hòa trộn tinh tế, tạo nên những chuyển sắc đa dạng từ những gam màu nhẹ nhàng đến những sắc màu rực rỡ, như một bảng màu nghệ thuật sống động. Màu sắc không chỉ mang lại sự nổi bật mà còn gợi lên cảm xúc, sự năng động và sáng tạo.\r\nÝ nghĩa của Giọt Nước Màu Sắc:\r\nBiểu tượng của sự sống và sự chuyển động:\r\n\r\nGiọt nước tượng trưng cho sự sống, sự tinh khiết và sự liên tục của tự nhiên. Giọt nước là nguồn sống của mọi sự sống trên Trái Đất, và sự kết hợp với màu sắc thể hiện sự phát triển và chuyển động không ngừng của vạn vật trong vũ trụ.\r\nSự tươi mới và đổi mới:\r\n\r\nGiọt nước màu sắc thể hiện cho sự tươi mới, đổi mới và những khởi đầu mới mẻ. Màu sắc sặc sỡ trong tác phẩm là hình ảnh của sự thay đổi tích cực, sự sáng tạo không giới hạn, mang lại niềm hy vọng và năng lượng cho người chiêm ngưỡng.\r\nSự kết hợp giữa nghệ thuật và thiên nhiên:\r\n\r\nBằng cách kết hợp hình ảnh giọt nước với màu sắc sống động, sản phẩm này tạo ra một sự kết nối giữa nghệ thuật và thiên nhiên. Nó mang đến sự gần gũi với tự nhiên, với sự thay đổi màu sắc của thiên nhiên qua các mùa, và sự gợi nhắc về sự thanh tịnh, sự kỳ diệu của nước.\r\nỨng dụng và lợi ích:\r\nTrang trí nội thất:\r\n\r\nGiọt Nước Màu Sắc là một tác phẩm trang trí tuyệt vời cho phòng khách, phòng làm việc, hoặc bất kỳ không gian nào trong nhà. Sự kết hợp giữa màu sắc và hình ảnh giọt nước mang đến vẻ đẹp thanh thoát, tinh tế và đầy nghệ thuật.\r\nThích hợp cho các dịp lễ Tết:\r\n\r\nĐây là một món quà tặng độc đáo và ý nghĩa cho các dịp lễ Tết, sinh nhật hoặc các dịp đặc biệt. Món quà này không chỉ đẹp mắt mà còn mang lại thông điệp về sự sống, sự tươi mới và hy vọng cho người nhận.\r\nTạo không gian thư giãn:\r\n\r\nSự kết hợp màu sắc sống động của giọt nước có thể tạo ra một không gian thư giãn, dễ chịu và đầy cảm hứng. Đặt sản phẩm trong nhà sẽ mang lại sự an bình, xua tan căng thẳng và mang đến cảm giác vui vẻ, lạc quan.\r\nLợi ích lâu dài:\r\nTăng cường năng lượng tích cực:\r\n\r\nGiọt Nước Màu Sắc là một món đồ trang trí mang lại năng lượng tích cực cho không gian sống. Với sự hiện diện của nó, không gian trở nên tươi mới, rạng rỡ và tràn đầy sức sống.\r\nSự bền vững và giá trị thẩm mỹ:\r\n\r\nSản phẩm không chỉ mang lại giá trị về mặt thẩm mỹ mà còn có thể tồn tại lâu dài nhờ vào chất liệu chế tác bền bỉ. Đây là một món đồ trang trí đẹp mắt và có giá trị lâu dài cho không gian sống.\r\nTổng kết:\r\nGiọt Nước Màu Sắc là một tác phẩm nghệ thuật đầy màu sắc và ý nghĩa, thể hiện sự sống, sự chuyển động và sự tươi mới. Với thiết kế tinh tế và sự kết hợp màu sắc sống động, sản phẩm này mang đến vẻ đẹp thẩm mỹ độc đáo cho không gian sống. Đồng thời, nó cũng mang lại thông điệp về sự đổi mới, sự sáng tạo và hy vọng, là món quà tuyệt vời cho những ai yêu thích nghệ thuật và thiên nhiên.', 10, 1),
(56, 'Giọt Nước Đen Trắng', 10, 2, 'img/kk2.jpg', 'Giọt Nước Đen Trắng là một tác phẩm nghệ thuật độc đáo, kết hợp giữa sự đối lập của hai màu sắc cơ bản: đen và trắng, để tạo nên một biểu tượng của sự tương phản, cân bằng và sự hòa hợp giữa các yếu tố đối lập trong cuộc sống. Sự kết hợp này không chỉ thể hiện vẻ đẹp thẩm mỹ mà còn mang nhiều ý nghĩa sâu sắc về cuộc sống và nghệ thuật.\r\n\r\nĐặc điểm và chất liệu:\r\nChất liệu chế tác:\r\n\r\nGiọt Nước Đen Trắng có thể được làm từ các chất liệu như thủy tinh, gốm, sứ hoặc kim loại cao cấp, với bề mặt mịn màng và sắc nét, tạo nên vẻ đẹp tối giản nhưng đầy sức hút. Các chi tiết được hoàn thiện tỉ mỉ, giúp tôn lên sự tương phản mạnh mẽ giữa hai màu sắc.\r\nHình dáng giọt nước:\r\n\r\nHình dáng giọt nước có thể được thiết kế theo phong cách tối giản và hiện đại, với một phần được tô màu đen và phần còn lại là màu trắng. Sự chuyển tiếp giữa hai màu sắc này có thể được tạo ra một cách mềm mại hoặc sắc nét, tạo nên một tác phẩm nghệ thuật ấn tượng.\r\nMàu sắc đen và trắng:\r\n\r\nMàu đen tượng trưng cho sự huyền bí, mạnh mẽ, và sự hiện diện của bóng tối trong cuộc sống. Màu trắng đại diện cho sự thuần khiết, sự sáng suốt, và sự tinh tế. Sự kết hợp của hai màu sắc này tạo ra một sự cân bằng tuyệt vời giữa ánh sáng và bóng tối, giữa thiện và ác, tạo nên một thông điệp về sự hòa hợp của những yếu tố đối lập trong tự nhiên và cuộc sống.\r\nÝ nghĩa của Giọt Nước Đen Trắng:\r\nSự đối lập và cân bằng:\r\n\r\nGiọt nước đen trắng mang ý nghĩa của sự đối lập, nhưng đồng thời cũng thể hiện sự cân bằng giữa các yếu tố khác nhau trong cuộc sống. Đó là sự kết hợp của ánh sáng và bóng tối, của hy vọng và thử thách, của bình yên và hỗn loạn. Tác phẩm này khắc họa mối quan hệ giữa những yếu tố tưởng chừng như đối lập nhưng lại bổ sung và hoàn thiện nhau.\r\nSự kết hợp giữa nghệ thuật và tự nhiên:\r\n\r\nCũng giống như trong tự nhiên, nơi sự sống luôn tồn tại trong sự tương phản giữa ngày và đêm, giọt nước đen trắng mang đến thông điệp về sự liên kết giữa các yếu tố tự nhiên, xã hội và tâm linh. Nó khuyến khích con người nhìn nhận và chấp nhận sự đa dạng trong cuộc sống.\r\nTinh tế và tối giản:\r\n\r\nMàu sắc đen và trắng thể hiện vẻ đẹp tinh tế, tối giản và thanh thoát. Tác phẩm này không cần quá nhiều chi tiết phức tạp để thể hiện ý nghĩa, mà chỉ cần sự đối lập mạnh mẽ của hai màu sắc để tạo ra một ấn tượng sâu sắc và nổi bật.\r\nỨng dụng và lợi ích:\r\nTrang trí nội thất:\r\n\r\nGiọt Nước Đen Trắng là một món đồ trang trí lý tưởng cho không gian sống hiện đại, tạo ra sự cân bằng và vẻ đẹp tối giản nhưng ấn tượng. Sản phẩm này có thể được đặt trong phòng khách, phòng làm việc hoặc bất kỳ không gian nào cần sự nổi bật và tinh tế.\r\nThích hợp cho các dịp lễ Tết:\r\n\r\nĐây là một món quà tặng hoàn hảo cho những ai yêu thích nghệ thuật và cái đẹp đơn giản. Với ý nghĩa về sự đối lập và hòa hợp, món quà này mang đến sự sâu sắc và truyền cảm hứng cho người nhận.\r\nTạo không gian thanh thoát:\r\n\r\nGiọt Nước Đen Trắng có thể tạo ra một không gian thanh thoát và yên bình. Nó giúp làm dịu không khí, mang lại sự tĩnh lặng và thư giãn cho người chiêm ngưỡng, đồng thời giúp không gian trở nên trang nhã và đầy phong cách.\r\nLợi ích lâu dài:\r\nTạo cảm giác về sự hòa hợp:\r\n\r\nVới sự kết hợp giữa đen và trắng, Giọt Nước Đen Trắng giúp tạo ra cảm giác về sự hòa hợp và cân bằng trong không gian sống, giúp con người cảm thấy bình an và dễ chịu.\r\nSự bền vững và giá trị thẩm mỹ:\r\n\r\nSản phẩm có thể tồn tại lâu dài nhờ vào chất liệu bền bỉ, đồng thời mang lại giá trị thẩm mỹ cao cho không gian sống. Đây là một món đồ trang trí không bao giờ lỗi thời, phù hợp với nhiều phong cách và xu hướng nội thất.\r\nTổng kết:\r\nGiọt Nước Đen Trắng là một tác phẩm nghệ thuật tinh tế và sâu sắc, mang ý nghĩa về sự đối lập và cân bằng giữa các yếu tố trong cuộc sống. Với chất liệu và thiết kế tối giản, sản phẩm này không chỉ đẹp mắt mà còn tạo ra thông điệp về sự hòa hợp trong những mối quan hệ tưởng chừng như trái ngược. Đây là một món đồ trang trí lý tưởng cho những ai yêu thích nghệ thuật, sự tĩnh lặng và vẻ đẹp thanh thoát trong không gian sống.', 10, 1),
(57, 'Giọt Nước Dây Treo', 10, 2, 'img/kk3.jpg', 'Giọt Nước Dây Treo là một sản phẩm nghệ thuật độc đáo, kết hợp giữa hình dáng giọt nước với thiết kế dây treo, tạo nên sự hòa quyện giữa tính thẩm mỹ và tính thực dụng. Đây là một món đồ trang trí đẹp mắt, mang lại sự thanh thoát và hiện đại cho không gian sống.\r\n\r\nĐặc điểm và chất liệu:\r\nChất liệu chế tác:\r\n\r\nGiọt Nước Dây Treo có thể được làm từ các chất liệu như thủy tinh trong suốt, acrylic, hoặc kim loại nhẹ, giúp tạo ra vẻ ngoài sáng bóng và mượt mà. Chất liệu này mang lại sự tinh tế, bền bỉ và có thể được trưng bày trong nhiều không gian khác nhau.\r\nHình dáng giọt nước:\r\n\r\nSản phẩm được thiết kế theo hình dáng giọt nước, tượng trưng cho sự tinh khiết và mượt mà. Giọt nước có thể được chế tác với các đường cong mềm mại, mang lại vẻ đẹp tự nhiên và thanh thoát.\r\nDây treo:\r\n\r\nDây treo được thiết kế nhẹ nhàng và chắc chắn, có thể làm từ các chất liệu như sợi dây nylon, kim loại mảnh hoặc dây da, tạo điểm nhấn cho sản phẩm. Dây treo có thể điều chỉnh độ dài, cho phép người sử dụng treo ở nhiều vị trí và chiều cao khác nhau.\r\nMàu sắc:\r\n\r\nGiọt nước có thể có màu trong suốt, đục hoặc có các lớp phủ màu nhẹ, tùy thuộc vào thiết kế và sở thích. Màu sắc của giọt nước mang lại vẻ đẹp tươi sáng, thanh thoát, dễ dàng kết hợp với nhiều phong cách trang trí khác nhau.\r\nÝ nghĩa của Giọt Nước Dây Treo:\r\nBiểu tượng của sự thuần khiết và tự nhiên:\r\n\r\nGiọt nước đại diện cho sự thuần khiết, trong sáng và tinh tế. Nó cũng tượng trưng cho sự sống, sự tươi mới và vẻ đẹp của tự nhiên. Sự kết hợp của giọt nước với dây treo tạo ra một hình ảnh mềm mại và huyền bí.\r\nSự cân bằng và nhẹ nhàng:\r\n\r\nGiọt nước dây treo mang đến sự cân bằng trong không gian, vừa có vẻ đẹp tối giản, vừa đầy ý nghĩa. Món đồ này tạo cảm giác nhẹ nhàng và thanh thoát cho người nhìn, giúp xua tan căng thẳng và mang lại cảm giác thư thái.\r\nTính linh hoạt trong trang trí:\r\n\r\nVì có dây treo, sản phẩm có thể được treo ở nhiều vị trí khác nhau trong không gian, từ trần nhà, cửa sổ, đến các khu vực trưng bày như kệ tủ, bàn làm việc, hay góc phòng khách. Đây là món đồ trang trí linh hoạt, dễ dàng thay đổi vị trí để tạo điểm nhấn cho không gian.\r\nỨng dụng và lợi ích:\r\nTrang trí không gian sống:\r\n\r\nGiọt Nước Dây Treo là một món đồ trang trí lý tưởng cho các không gian như phòng khách, phòng ngủ, phòng ăn hoặc phòng làm việc. Sản phẩm này tạo nên một không gian sống tươi mới và thanh thoát, thích hợp với những không gian có phong cách hiện đại, tối giản hoặc cổ điển.\r\nQuà tặng ý nghĩa:\r\n\r\nĐây là món quà lý tưởng dành tặng cho những người yêu thích nghệ thuật và trang trí. Với ý nghĩa về sự thuần khiết và cân bằng, Giọt Nước Dây Treo sẽ là món quà đầy ý nghĩa cho các dịp đặc biệt như sinh nhật, lễ kỷ niệm, hoặc các sự kiện quan trọng.\r\nTạo không gian thư giãn:\r\n\r\nSản phẩm này giúp tạo ra không gian yên bình, dễ chịu, giúp người dùng thư giãn và giảm căng thẳng sau một ngày dài làm việc. Giọt Nước Dây Treo mang lại vẻ đẹp tự nhiên và nhẹ nhàng, giúp làm dịu không khí và tạo cảm giác thư thái trong không gian sống.\r\nLợi ích lâu dài:\r\nTạo điểm nhấn tinh tế:\r\n\r\nGiọt Nước Dây Treo sẽ là điểm nhấn tinh tế trong không gian sống, với sự kết hợp giữa tính thẩm mỹ và tính linh hoạt. Món đồ này sẽ giúp không gian trở nên sống động hơn, đồng thời mang đến vẻ đẹp nhẹ nhàng và trang nhã.\r\nDễ dàng bảo trì:\r\n\r\nVới chất liệu dễ lau chùi và bảo quản, Giọt Nước Dây Treo không đòi hỏi quá nhiều công chăm sóc, giúp người sử dụng tiết kiệm thời gian và công sức.\r\nKhả năng kết hợp cao:\r\n\r\nSản phẩm này dễ dàng kết hợp với các món đồ trang trí khác trong nhà, tạo ra một không gian thống nhất và hài hòa. Giọt Nước Dây Treo là món đồ trang trí linh hoạt có thể thay đổi theo sở thích và phong cách của từng gia đình.\r\nTổng kết:\r\nGiọt Nước Dây Treo là một tác phẩm nghệ thuật tinh tế, mang ý nghĩa về sự thuần khiết và cân bằng trong cuộc sống. Sản phẩm này không chỉ là một món đồ trang trí đẹp mắt, mà còn là một biểu tượng của sự tự nhiên và thanh thoát. Với thiết kế đơn giản nhưng ấn tượng, Giọt Nước Dây Treo sẽ là sự lựa chọn hoàn hảo để làm đẹp không gian sống và mang đến cảm giác thư giãn cho người sử dụng.', 10, 1),
(58, 'Đại Dương Đa Sắc', 10, 2, 'img/kk4.jpg', 'Đại Dương Đa Sắc là một tác phẩm nghệ thuật độc đáo, lấy cảm hứng từ vẻ đẹp huyền bí và sống động của đại dương. Sản phẩm này thể hiện sự phong phú và đa dạng của hệ sinh thái biển, với các sắc màu rực rỡ và tinh tế, mang đến một không gian sống động và đầy cảm hứng.\r\n\r\nĐặc điểm và chất liệu:\r\nChất liệu chế tác:\r\n\r\nĐại Dương Đa Sắc có thể được chế tác từ nhiều chất liệu khác nhau như thủy tinh, acrylic, hoặc gốm sứ, giúp mang lại vẻ ngoài bóng bẩy và mượt mà. Các chất liệu này không chỉ tạo nên vẻ đẹp thẩm mỹ mà còn đảm bảo độ bền vững theo thời gian.\r\nThiết kế sắc màu:\r\n\r\nĐược tạo ra từ sự kết hợp của nhiều sắc màu tươi sáng như xanh biển, xanh lá cây, cam, vàng và các sắc độ khác nhau của nước biển, sản phẩm thể hiện sự biến chuyển màu sắc tự nhiên trong đại dương. Các màu sắc này được pha trộn một cách nghệ thuật, tạo cảm giác như sóng biển đang vỗ về với những chuyển động nhẹ nhàng và nhịp nhàng.\r\nHình dáng và kết cấu:\r\n\r\nĐại Dương Đa Sắc có thể được thiết kế dưới dạng hình tròn, hình oval, hoặc các hình dạng tự do giống như sóng biển, giúp tái hiện lại hình ảnh của đại dương mênh mông và vô tận. Kết cấu của sản phẩm được chăm chút tỉ mỉ, mang lại cảm giác sống động và chân thực.\r\nChi tiết trang trí:\r\n\r\nBên cạnh màu sắc và hình dáng, sản phẩm còn có thể được trang trí bằng các họa tiết như các con sóng, hạt cát, hoặc các sinh vật biển nhỏ xinh như sao biển, san hô, tạo nên một sự kết hợp hoàn hảo, vừa mang tính thẩm mỹ cao, vừa tạo ra sự gần gũi với thiên nhiên.\r\nÝ nghĩa của Đại Dương Đa Sắc:\r\nBiểu tượng của sự sống và sự đa dạng:\r\n\r\nĐại dương là biểu tượng của sự sống phong phú, đa dạng và đầy màu sắc. Sự kết hợp của nhiều màu sắc và hình dáng trong sản phẩm này thể hiện sự phong phú của hệ sinh thái biển, đồng thời phản ánh sự đa dạng và sự sống động không ngừng của thiên nhiên.\r\nSự kết nối với thiên nhiên:\r\n\r\nSản phẩm này mang đến một cảm giác gắn kết với thiên nhiên, đặc biệt là với đại dương mênh mông và kỳ diệu. Nó nhắc nhở chúng ta về vẻ đẹp và sự quan trọng của việc bảo vệ môi trường biển và hệ sinh thái đại dương.\r\nMang lại sự thư giãn và bình yên:\r\n\r\nNhờ vào màu sắc và thiết kế, Đại Dương Đa Sắc tạo ra một không gian thư giãn, dễ chịu, giúp người nhìn cảm thấy bình yên và tĩnh lặng như khi đứng trước biển cả rộng lớn. Đây là một món đồ trang trí lý tưởng để mang lại cảm giác thư giãn cho người sử dụng.\r\nỨng dụng và lợi ích:\r\nTrang trí không gian sống:\r\n\r\nĐại Dương Đa Sắc là món đồ trang trí lý tưởng cho không gian phòng khách, phòng ngủ, hay các khu vực nghỉ ngơi trong ngôi nhà. Màu sắc tươi sáng của sản phẩm sẽ làm cho không gian trở nên sinh động và tràn đầy sức sống.\r\nQuà tặng ý nghĩa:\r\n\r\nĐây là món quà hoàn hảo cho những ai yêu thích biển cả, sự tự do và vẻ đẹp thiên nhiên. Đại Dương Đa Sắc cũng là món quà tuyệt vời cho các dịp đặc biệt như sinh nhật, kỷ niệm, hoặc lễ tết.\r\nTạo không gian thư giãn và nghệ thuật:\r\n\r\nVới thiết kế sinh động và sắc màu ấn tượng, sản phẩm không chỉ có giá trị trang trí mà còn mang đến một không gian nghệ thuật, giúp người nhìn có thể thư giãn và tận hưởng sự tươi mới.\r\nLợi ích lâu dài:\r\nTạo điểm nhấn nổi bật:\r\n\r\nĐại Dương Đa Sắc là món đồ trang trí độc đáo, giúp tạo điểm nhấn nổi bật trong không gian sống. Sự đa dạng về màu sắc và hình dáng của nó làm cho sản phẩm trở thành trung tâm chú ý trong mỗi không gian.\r\nDễ dàng bảo quản:\r\n\r\nChất liệu chế tác của sản phẩm giúp nó dễ dàng bảo trì và lau chùi. Dù ở trong không gian ẩm ướt hay khô ráo, sản phẩm vẫn giữ được vẻ đẹp nguyên vẹn và sáng bóng.\r\nKhả năng kết hợp cao:\r\n\r\nSản phẩm dễ dàng kết hợp với các món đồ trang trí khác trong nhà, từ các đồ nội thất hiện đại đến các vật trang trí cổ điển. Điều này giúp tạo ra một không gian sống hài hòa và thống nhất.\r\nTổng kết:\r\nĐại Dương Đa Sắc là món đồ trang trí tuyệt vời mang lại vẻ đẹp tự nhiên, sự sống động và thư giãn cho không gian sống. Với thiết kế sáng tạo, màu sắc tươi tắn và ý nghĩa sâu sắc, sản phẩm này sẽ là một phần không thể thiếu trong không gian của những người yêu thích thiên nhiên và vẻ đẹp đại dương.', 10, 1),
(59, 'Cây Không Khí AT001', 10, 2, 'img/kk5.jpg', 'Cây Không Khí AT001 là một sản phẩm độc đáo và hữu ích, kết hợp giữa công nghệ và thiên nhiên để mang lại không gian sống trong lành, thoáng đãng. Đây là một thiết bị thông minh giúp cải thiện chất lượng không khí trong không gian sống của bạn, đồng thời tạo ra cảm giác thư giãn và dễ chịu.\r\n\r\nĐặc điểm và tính năng nổi bật:\r\nChức năng lọc không khí:\r\n\r\nCây Không Khí AT001 được trang bị hệ thống lọc hiện đại, giúp loại bỏ các bụi bẩn, vi khuẩn, và các tác nhân gây hại trong không khí như phấn hoa, mùi hôi, khói thuốc. Điều này giúp tạo ra một không gian sống trong lành và sạch sẽ.\r\nCông nghệ Ion âm:\r\n\r\nSản phẩm sử dụng công nghệ ion âm để tạo ra các ion âm trong không khí, giúp làm sạch và tái tạo không khí. Ion âm có khả năng hấp thụ các hạt bụi và các chất ô nhiễm, từ đó giảm thiểu tác động của các yếu tố gây dị ứng và cải thiện sức khỏe cho người sử dụng.\r\nThiết kế cây xanh tự nhiên:\r\n\r\nCây Không Khí AT001 có thiết kế mô phỏng cây xanh tự nhiên, với các lá cây được tạo hình tinh tế và giống thật, mang đến vẻ đẹp tự nhiên cho không gian. Sản phẩm không chỉ có tác dụng lọc không khí mà còn làm đẹp thêm không gian sống của bạn, mang lại cảm giác thư thái, dễ chịu.\r\nDễ sử dụng và bảo trì:\r\n\r\nCây Không Khí AT001 có thiết kế đơn giản và dễ sử dụng, chỉ cần cắm điện và bật công tắc là bạn có thể tận hưởng không gian sạch và trong lành. Việc bảo trì sản phẩm cũng rất đơn giản, chỉ cần thay bộ lọc định kỳ để duy trì hiệu suất tối ưu.\r\nTiết kiệm năng lượng:\r\n\r\nĐược thiết kế với công nghệ tiết kiệm năng lượng, Cây Không Khí AT001 hoạt động hiệu quả mà không tiêu tốn quá nhiều điện năng, giúp bạn tiết kiệm chi phí sử dụng điện hàng tháng.\r\nĐộ ồn thấp:\r\n\r\nCây Không Khí AT001 hoạt động êm ái và gần như không gây tiếng ồn, tạo không gian yên tĩnh và thoải mái cho người sử dụng.\r\nLợi ích của Cây Không Khí AT001:\r\nCải thiện sức khỏe:\r\n\r\nViệc sử dụng Cây Không Khí AT001 giúp cải thiện chất lượng không khí, làm giảm các tác nhân gây dị ứng và bệnh tật. Đặc biệt, sản phẩm có thể hữu ích cho những người có vấn đề về hô hấp, hen suyễn hay các bệnh lý liên quan đến không khí ô nhiễm.\r\nTạo không gian sống trong lành:\r\n\r\nCây Không Khí AT001 giúp tạo ra không gian sống trong lành, sạch sẽ và tươi mới, đặc biệt là trong các khu vực có không khí ô nhiễm hoặc khô hanh.\r\nTăng cường năng lượng và sự thư giãn:\r\n\r\nViệc sử dụng cây không khí giúp cải thiện cảm giác thư giãn, giảm căng thẳng, đồng thời mang lại không gian sống năng động và đầy sức sống.\r\nTính thẩm mỹ cao:\r\n\r\nSản phẩm mang lại vẻ đẹp tự nhiên và sang trọng, là một món đồ trang trí đẹp mắt cho không gian sống của bạn, phù hợp với nhiều loại không gian như phòng khách, phòng ngủ, văn phòng làm việc, hoặc phòng ăn.\r\nThân thiện với môi trường:\r\n\r\nCây Không Khí AT001 không chỉ giúp làm sạch không khí mà còn thân thiện với môi trường. Nó sử dụng công nghệ tiên tiến để giảm thiểu tác động tiêu cực đến môi trường và bảo vệ sức khỏe cộng đồng.\r\nỨng dụng và sử dụng:\r\nTrang trí không gian sống:\r\n\r\nCây Không Khí AT001 không chỉ là một thiết bị lọc không khí mà còn là món đồ trang trí tuyệt vời cho các không gian sống như phòng khách, phòng ngủ, hoặc nơi làm việc.\r\nQuà tặng ý nghĩa:\r\n\r\nĐây là món quà rất ý nghĩa dành cho những người thân yêu, bạn bè, hoặc đồng nghiệp, đặc biệt là những người quan tâm đến sức khỏe và chất lượng không khí trong cuộc sống hàng ngày.\r\nDễ dàng di chuyển và sử dụng:\r\n\r\nNhờ thiết kế nhỏ gọn và dễ di chuyển, Cây Không Khí AT001 có thể được sử dụng ở nhiều không gian khác nhau, từ nhà ở cho đến văn phòng, trường học, bệnh viện, hoặc các khu vực công cộng khác.\r\nTổng kết:\r\nCây Không Khí AT001 là sản phẩm lý tưởng cho những ai mong muốn cải thiện chất lượng không khí trong không gian sống, đồng thời mang lại một điểm nhấn trang trí đẹp mắt và thanh thoát. Với khả năng lọc không khí, công nghệ ion âm và thiết kế tinh tế, sản phẩm này sẽ là một phần không thể thiếu trong mỗi gia đình hoặc văn phòng hiện đại.', 10, 1),
(60, 'Cây Không Khí', 10, 2, 'img/kk6.jpg', 'Cây Không Khí là một thiết bị thông minh, kết hợp giữa công nghệ và thiên nhiên, nhằm cải thiện chất lượng không khí trong không gian sống. Đây là một giải pháp hiện đại giúp không gian sống của bạn trở nên trong lành, thoáng đãng và dễ chịu.\r\n\r\nĐặc điểm nổi bật của Cây Không Khí:\r\nLọc không khí hiệu quả:\r\n\r\nCây Không Khí được trang bị bộ lọc hiện đại có khả năng loại bỏ bụi bẩn, vi khuẩn, mùi hôi và các tác nhân gây ô nhiễm trong không khí. Điều này giúp không gian sống trở nên trong lành hơn.\r\nCông nghệ ion âm:\r\n\r\nSản phẩm sử dụng công nghệ ion âm, giúp cân bằng không khí, giảm thiểu tác động của các yếu tố gây dị ứng và cải thiện sức khỏe người sử dụng.\r\nThiết kế giống cây xanh tự nhiên:\r\n\r\nCây Không Khí có thiết kế mô phỏng hình dáng cây xanh thật, mang lại vẻ đẹp tự nhiên cho không gian sống. Thiết kế này không chỉ có tác dụng lọc không khí mà còn làm đẹp thêm căn phòng của bạn.\r\nTiết kiệm năng lượng:\r\n\r\nCây Không Khí hoạt động hiệu quả mà không tiêu tốn quá nhiều năng lượng, giúp tiết kiệm chi phí điện năng.\r\nĐộ ồn thấp:\r\n\r\nMáy hoạt động êm ái và không gây ra tiếng ồn, tạo cảm giác thoải mái và yên tĩnh trong không gian sống.\r\nLợi ích của Cây Không Khí:\r\nCải thiện sức khỏe:\r\n\r\nViệc sử dụng Cây Không Khí giúp giảm thiểu các tác nhân gây dị ứng và bệnh hô hấp, mang lại một môi trường trong lành và khỏe mạnh.\r\nTạo không gian sống trong lành:\r\n\r\nCây Không Khí giúp thanh lọc không khí, đặc biệt trong các khu vực có không khí ô nhiễm, khô hanh hoặc có mùi khó chịu.\r\nTăng cường thư giãn và giảm căng thẳng:\r\n\r\nVới thiết kế giống cây xanh, sản phẩm mang lại không gian thư giãn, dễ chịu, giúp giảm căng thẳng và mệt mỏi.\r\nTrang trí không gian:\r\n\r\nCây Không Khí là món đồ trang trí tinh tế, mang lại vẻ đẹp tự nhiên cho không gian sống của bạn, phù hợp cho phòng khách, phòng ngủ, hoặc văn phòng.\r\nỨng dụng:\r\nTrang trí nội thất: Sản phẩm phù hợp với nhiều không gian sống như phòng khách, phòng ngủ, văn phòng làm việc, hoặc phòng học.\r\nQuà tặng: Là món quà ý nghĩa cho gia đình, bạn bè, đồng nghiệp, đặc biệt cho những ai yêu thích sức khỏe và thiên nhiên.\r\nCây Không Khí là giải pháp tuyệt vời cho những ai muốn cải thiện chất lượng không khí trong không gian sống, đồng thời mang lại sự thư giãn và vẻ đẹp tự nhiên cho căn phòng.', 10, 1),
(61, 'Biển Xanh Nhiệt Đới', 10, 2, 'img/product_673cc1d825f894.14345485.jpg', 'Biển Xanh Nhiệt Đới là một sản phẩm trang trí độc đáo, mang đậm hơi thở của thiên nhiên nhiệt đới, tạo nên một không gian tươi mới và đầy màu sắc. Sản phẩm này không chỉ là món đồ trang trí mà còn có thể mang lại cảm giác thư giãn, gần gũi với biển cả và thiên nhiên hoang dã.\r\n\r\nĐặc điểm nổi bật của Biển Xanh Nhiệt Đới:\r\nMàu sắc tươi sáng:\r\n\r\nBiển Xanh Nhiệt Đới sử dụng gam màu xanh biển chủ đạo kết hợp với các sắc màu nhiệt đới như vàng, cam, và xanh lá, mang đến một không gian sống động và tràn đầy sức sống.\r\nHình ảnh sinh động:\r\n\r\nThiết kế của Biển Xanh Nhiệt Đới mô phỏng lại cảnh biển nhiệt đới với sóng biển vỗ về, cát trắng mịn màng và những tán lá xanh mướt của các loài cây nhiệt đới, giúp mang lại cảm giác thư giãn, gần gũi với thiên nhiên.\r\nChất liệu cao cấp:\r\n\r\nSản phẩm được làm từ chất liệu gỗ, acrylic hoặc các vật liệu bền đẹp khác, giúp sản phẩm không chỉ bền lâu mà còn có độ hoàn thiện cao.\r\nKích thước phù hợp:\r\n\r\nBiển Xanh Nhiệt Đới có nhiều kích thước khác nhau, phù hợp với nhiều không gian từ phòng khách, phòng làm việc đến không gian ngoài trời như ban công hay sân vườn.\r\nLợi ích của Biển Xanh Nhiệt Đới:\r\nTạo không gian thư giãn:\r\n\r\nVới thiết kế mang đậm tinh thần của biển cả, Biển Xanh Nhiệt Đới sẽ tạo ra một không gian thư giãn, giúp giảm căng thẳng và mệt mỏi, mang lại cảm giác dễ chịu, bình yên.\r\nTrang trí sống động:\r\n\r\nĐây là món đồ trang trí lý tưởng cho những ai yêu thích biển cả và thiên nhiên. Nó không chỉ làm đẹp không gian mà còn tạo điểm nhấn mạnh mẽ, thu hút sự chú ý của mọi người.\r\nLàm quà tặng ý nghĩa:\r\n\r\nBiển Xanh Nhiệt Đới là món quà tuyệt vời cho những người yêu thiên nhiên, yêu biển cả hoặc muốn mang một phần hơi thở của thiên nhiên vào không gian sống của mình.\r\nTạo cảm hứng sáng tạo:\r\n\r\nMàu sắc và thiết kế tươi mới của Biển Xanh Nhiệt Đới giúp kích thích sự sáng tạo và năng lượng tích cực trong công việc và học tập.\r\nỨng dụng:\r\nTrang trí nội thất: Thích hợp cho các không gian sống như phòng khách, phòng ngủ, hoặc phòng làm việc.\r\nKhông gian ngoài trời: Có thể sử dụng trang trí ban công, sân vườn hoặc các khu vực ngoài trời khác.\r\nQuà tặng: Là món quà đặc biệt cho những ai yêu thích biển, thiên nhiên và không gian sống gần gũi với thiên nhiên.\r\nBiển Xanh Nhiệt Đới là lựa chọn lý tưởng để mang không gian biển cả vào ngôi nhà của bạn, tạo nên một môi trường sống năng động và thư giãn, giúp bạn tận hưởng những giây phút tuyệt vời với thiên nhiên.\r\n', 10, 1),
(62, 'Cây Đồng Tiền', 10, 1, 'img/cmn1.jpg', 'Cây Đồng Tiền là một loại cây trang trí nổi bật với hình dáng đặc trưng và màu sắc xanh mướt, tượng trưng cho sự phát tài, phát lộc và thịnh vượng. Loài cây này được yêu thích trong phong thủy và được sử dụng rộng rãi trong các không gian sống và làm việc.\r\n\r\nĐặc điểm nổi bật của Cây Đồng Tiền:\r\nHình dáng đặc trưng:\r\n\r\nCây Đồng Tiền có lá tròn, dày và mọng nước, thường có màu xanh tươi mát. Hình dáng của lá giống như đồng tiền cổ, tượng trưng cho sự giàu có và may mắn.\r\nLá cây mướt mát:\r\n\r\nLá cây có màu xanh sáng bóng và hình tròn, mọc đối xứng nhau, tạo nên sự hài hòa, dễ nhìn và rất dễ chăm sóc.\r\nChăm sóc dễ dàng:\r\n\r\nCây Đồng Tiền dễ dàng thích nghi với nhiều điều kiện môi trường khác nhau, từ trong nhà cho đến ngoài trời. Nó không yêu cầu quá nhiều ánh sáng và nước, giúp tiết kiệm thời gian chăm sóc.\r\nKích thước nhỏ gọn:\r\n\r\nCây Đồng Tiền thường có kích thước nhỏ gọn, dễ dàng đặt trên bàn làm việc, kệ sách, hoặc các không gian nhỏ khác mà không chiếm nhiều diện tích.\r\nLợi ích của Cây Đồng Tiền:\r\nMang lại may mắn và tài lộc:\r\n\r\nTheo phong thủy, Cây Đồng Tiền mang lại sự thịnh vượng, tài lộc và may mắn cho gia chủ. Vì hình dáng lá giống đồng tiền, cây được cho là giúp thu hút tài chính và cải thiện vận khí.\r\nLàm đẹp không gian sống:\r\n\r\nCây Đồng Tiền là một lựa chọn tuyệt vời để trang trí bàn làm việc, phòng khách, hoặc phòng ngủ. Nó mang đến không gian xanh mát, tươi mới và đầy sức sống.\r\nGiảm căng thẳng và tạo không gian thư giãn:\r\n\r\nViệc đặt cây trong nhà không chỉ giúp không gian thêm sinh động mà còn có tác dụng thư giãn, giảm căng thẳng và giúp tăng cường năng lượng tích cực.\r\nDễ chăm sóc:\r\n\r\nCây Đồng Tiền không đòi hỏi chăm sóc phức tạp. Chỉ cần đảm bảo đủ ánh sáng và tưới nước đều đặn, cây có thể phát triển khỏe mạnh.\r\nỨng dụng:\r\nTrang trí nội thất: Cây Đồng Tiền thích hợp để trang trí trong nhà, đặc biệt là các không gian như phòng khách, phòng làm việc, hoặc phòng ngủ.\r\nQuà tặng ý nghĩa: Là món quà phong thủy rất được yêu thích, đặc biệt là trong các dịp tân gia, sinh nhật hay các dịp lễ quan trọng.\r\nChăm sóc sức khỏe: Cây Đồng Tiền giúp cải thiện không khí trong phòng, hấp thụ khí CO2 và thải ra oxy, giúp không gian sống trong lành hơn.\r\nCây Đồng Tiền không chỉ mang lại sự tươi mới cho không gian sống mà còn là biểu tượng của sự phát đạt và thịnh vượng. Với những đặc điểm dễ chăm sóc và ý nghĩa phong thủy sâu sắc, cây là lựa chọn tuyệt vời cho những ai muốn tạo ra một môi trường sống may mắn và hạnh phúc.\r\n', 10, 1);
INSERT INTO `product` (`id`, `name`, `saleoff`, `category`, `imagiUrl`, `short_descripsion`, `inStock`, `isAvailable`) VALUES
(63, 'Cây Mini Hồng Xinh', 10, 1, 'img/cmn2.jpg', 'Cây Mini Hồng Xinh là một loại cây trang trí nhỏ gọn, đẹp mắt, với những bông hoa hồng nhỏ nhắn và màu sắc tươi sáng, rất phù hợp để trang trí trong không gian sống hoặc làm quà tặng. Đây là một loại cây mang lại cảm giác dễ chịu và đầy sức sống, làm cho không gian trở nên tươi mới và lãng mạn hơn.\r\n\r\nĐặc điểm nổi bật của Cây Mini Hồng Xinh:\r\nHoa đẹp và nhỏ gọn:\r\n\r\nCây Mini Hồng Xinh sở hữu những bông hoa hồng nhỏ xinh với màu sắc đa dạng, từ hồng nhạt đến đỏ tươi, tạo nên vẻ đẹp dịu dàng và thu hút.\r\nHoa hồng mini có mùi hương nhẹ nhàng, mang lại cảm giác dễ chịu và thư giãn.\r\nKích thước nhỏ gọn:\r\n\r\nCây Mini Hồng Xinh có kích thước nhỏ, dễ dàng đặt trên bàn làm việc, kệ sách, hay những không gian nhỏ như góc phòng khách, phòng ngủ.\r\nNhờ kích thước nhỏ gọn, cây không chiếm nhiều diện tích, rất phù hợp với những không gian hạn chế.\r\nLá cây xanh mướt:\r\n\r\nCây có lá màu xanh tươi, mịn màng, với hình dáng thon dài, tạo nên sự hài hòa với những bông hoa nhỏ xinh.\r\nDễ chăm sóc:\r\n\r\nCây Mini Hồng Xinh rất dễ chăm sóc, không đòi hỏi quá nhiều công sức. Cây cần ánh sáng nhẹ và tưới nước đều đặn để phát triển khỏe mạnh.\r\nLợi ích của Cây Mini Hồng Xinh:\r\nMang lại vẻ đẹp lãng mạn và tươi mới:\r\n\r\nCây Mini Hồng Xinh là một trong những cây trang trí yêu thích vì vẻ đẹp lãng mạn của những bông hoa hồng nhỏ. Cây sẽ làm cho không gian sống trở nên ấm áp và sinh động hơn.\r\nGiảm căng thẳng và tạo không gian thư giãn:\r\n\r\nHoa hồng không chỉ đẹp mà còn có tác dụng giảm căng thẳng, tạo cảm giác thoải mái và thư giãn. Việc đặt cây trong phòng sẽ giúp tăng cường năng lượng tích cực và cải thiện tâm trạng.\r\nQuà tặng ý nghĩa:\r\n\r\nVới vẻ đẹp xinh xắn và ý nghĩa của hoa hồng, Cây Mini Hồng Xinh là món quà hoàn hảo cho những dịp như sinh nhật, kỷ niệm, tân gia, hoặc những dịp lễ đặc biệt.\r\nHoa hồng còn được xem là biểu tượng của tình yêu, sự quan tâm và tôn trọng.\r\nThích hợp với không gian nhỏ:\r\n\r\nCây Mini Hồng Xinh rất thích hợp để trang trí trong các không gian nhỏ như bàn làm việc, phòng ngủ, hoặc các góc trong phòng khách. Cây giúp làm đẹp không gian mà không chiếm quá nhiều diện tích.\r\nCải thiện không khí:\r\n\r\nNhư các loại cây khác, Cây Mini Hồng Xinh cũng giúp cải thiện không khí trong phòng, hấp thụ khí CO2 và thải ra oxy, giúp tạo ra một môi trường sống trong lành và dễ chịu.\r\nỨng dụng:\r\nTrang trí nội thất: Cây Mini Hồng Xinh thích hợp để trang trí trên bàn làm việc, kệ sách, hay góc phòng, giúp không gian sống thêm phần sinh động và lãng mạn.\r\nQuà tặng: Đây là món quà tuyệt vời cho những người thân yêu, bạn bè hoặc đối tác trong các dịp đặc biệt.\r\nLàm đẹp không gian: Cây giúp làm mới không gian sống, tạo ra bầu không khí dễ chịu và thanh thoát.\r\nCây Mini Hồng Xinh không chỉ mang lại vẻ đẹp lãng mạn cho không gian sống mà còn là món quà đầy ý nghĩa, biểu tượng cho tình yêu và sự quan tâm. Với kích thước nhỏ gọn và dễ chăm sóc, cây là lựa chọn hoàn hảo cho những ai yêu thích hoa và muốn mang một phần vẻ đẹp của thiên nhiên vào ngôi nhà của mình.', 10, 1),
(64, 'Cây Trầ Bà Sữa', 10, 1, 'img/cmn3.jpg', 'Cây Trầu Bà Sữa (hay còn gọi là Trầu Bà Sữa hoặc Pothos Golden) là một loại cây cảnh rất phổ biến trong các không gian nội thất nhờ vào vẻ đẹp đơn giản, dễ chăm sóc và khả năng sinh trưởng mạnh mẽ. Cây thuộc họ Ráy (Araceae) và thường được trồng để trang trí cho các không gian như văn phòng, phòng khách, hay khu vực ban công.\r\n\r\nĐặc điểm nổi bật của Cây Trầu Bà Sữa:\r\nLá cây màu sắc tươi sáng:\r\n\r\nCây Trầu Bà Sữa có lá màu xanh lá kết hợp với các vệt vàng sáng, tạo ra một màu sắc rất bắt mắt và nổi bật. Các vệt màu vàng này thường xuất hiện ở phần rìa lá hoặc các phần giữa lá, tạo thành hình ảnh mát mẻ và hài hòa cho cây.\r\nTính dễ sinh trưởng:\r\n\r\nTrầu Bà Sữa là một loại cây cảnh dễ sống và phát triển mạnh mẽ, đặc biệt là trong môi trường trong nhà với ánh sáng vừa phải. Cây có thể chịu được môi trường thiếu ánh sáng nhưng sẽ phát triển tốt nhất khi có ánh sáng gián tiếp.\r\nCây có thể leo hoặc trồng trong chậu treo:\r\n\r\nTrầu Bà Sữa có khả năng leo, bám vào các dây thừng hoặc giá đỡ, do đó rất thích hợp trồng trong giỏ treo hoặc để cây leo dọc theo các giá đỡ trong không gian sống.\r\nKích thước nhỏ gọn:\r\n\r\nVới kích thước nhỏ và khả năng phát triển trong không gian hạn chế, cây phù hợp để trang trí trong các căn phòng có diện tích khiêm tốn hoặc trên bàn làm việc, kệ sách.\r\nLợi ích của Cây Trầu Bà Sữa:\r\nCải thiện không khí:\r\n\r\nTrầu Bà Sữa có khả năng lọc không khí, hấp thụ các chất độc hại như formaldehyde và benzene, giúp không gian sống trong lành và tươi mát hơn. Đây là một trong những lý do khiến cây này trở thành lựa chọn phổ biến cho những người yêu thích cây xanh trong nhà.\r\nDễ chăm sóc:\r\n\r\nCây Trầu Bà Sữa không đòi hỏi quá nhiều công chăm sóc. Cây có thể sống trong điều kiện ánh sáng yếu, cần tưới nước vừa phải và không yêu cầu thay đất quá thường xuyên. Do đó, cây rất thích hợp cho những người bận rộn hoặc không có nhiều kinh nghiệm chăm sóc cây.\r\nTrang trí không gian:\r\n\r\nCây Trầu Bà Sữa là một lựa chọn lý tưởng để trang trí trong nhà, đặc biệt là trong các không gian như phòng khách, văn phòng, hoặc phòng làm việc. Cây giúp tạo không gian xanh mát, tăng vẻ đẹp tự nhiên cho ngôi nhà.\r\nTăng tính thẩm mỹ:\r\n\r\nVới lá cây màu sắc tươi sáng và hình dáng thanh thoát, Trầu Bà Sữa mang lại vẻ đẹp nhẹ nhàng, tự nhiên, giúp không gian sống thêm phần sinh động và thoải mái.\r\nỨng dụng của Cây Trầu Bà Sữa:\r\nTrang trí nội thất:\r\n\r\nCây Trầu Bà Sữa có thể được trồng trong chậu nhỏ để trang trí trên bàn làm việc, kệ sách, hoặc các góc nhỏ trong phòng khách, giúp làm đẹp không gian sống.\r\nGiỏ treo:\r\n\r\nCây có thể được trồng trong giỏ treo, giúp tiết kiệm diện tích và tạo vẻ đẹp thanh thoát, nhẹ nhàng cho không gian.\r\nQuà tặng:\r\n\r\nTrầu Bà Sữa là một món quà tuyệt vời cho những người yêu cây cảnh hoặc muốn làm mới không gian sống của mình.\r\nLọc không khí:\r\n\r\nNhờ khả năng thanh lọc không khí, Trầu Bà Sữa rất phù hợp để trồng trong các văn phòng, phòng ngủ, hoặc bất kỳ không gian nào cần làm sạch không khí.\r\nCây Trầu Bà Sữa không chỉ đẹp mà còn mang lại nhiều lợi ích cho không gian sống của bạn. Với khả năng lọc không khí, dễ chăm sóc, và vẻ đẹp thanh thoát, cây này là một lựa chọn tuyệt vời cho những ai yêu thích cây cảnh nhưng không có nhiều thời gian chăm sóc.', 10, 1),
(65, 'Cây DGA Huyết Dụ', 10, 1, 'img/cmn4.jpg', 'Cây DGA Huyết Dụ (hay còn gọi là Huyết Dụ hoặc Cây Đinh Lăng Huyết Dụ) là một loại cây cảnh phổ biến, được ưa chuộng trong việc trang trí không gian sống và làm cảnh. Cây này thuộc họ Araliaceae, có tên khoa học là Polyscias scutellaria. Với vẻ ngoài bắt mắt và nhiều công dụng, cây DGA Huyết Dụ đã trở thành lựa chọn yêu thích của nhiều người yêu cây xanh.\r\n\r\nĐặc điểm nổi bật của Cây DGA Huyết Dụ:\r\nLá cây màu sắc đặc trưng:\r\n\r\nCây DGA Huyết Dụ có lá màu xanh đậm, bóng mượt, với những vệt đỏ hoặc màu huyết dụ (đỏ tía) đặc trưng. Điều này làm cây trở nên nổi bật và thu hút sự chú ý, đặc biệt khi có ánh sáng chiếu vào, tạo ra hiệu ứng màu sắc đẹp mắt.\r\nTính dễ chăm sóc:\r\n\r\nCây Huyết Dụ rất dễ chăm sóc và sinh trưởng mạnh mẽ trong các điều kiện khác nhau. Cây có thể sống tốt trong ánh sáng gián tiếp và không đòi hỏi phải tưới nước quá nhiều, chỉ cần duy trì độ ẩm vừa phải là cây sẽ phát triển tốt.\r\nKích thước nhỏ gọn:\r\n\r\nCây có thân thẳng, lá mọc thành từng chùm, rất thích hợp để trang trí trong các không gian nhỏ như bàn làm việc, kệ sách, hay những góc phòng cần làm điểm nhấn.\r\nCây có tính linh hoạt trong trang trí:\r\n\r\nCây DGA Huyết Dụ có thể được trồng trong các chậu đất sét, chậu gốm hoặc chậu treo. Bởi cây có khả năng sinh trưởng và phát triển tốt trong chậu nhỏ, nên rất thích hợp cho không gian sống hạn chế.\r\nLợi ích của Cây DGA Huyết Dụ:\r\nCải thiện không khí:\r\n\r\nGiống như nhiều loại cây khác, cây DGA Huyết Dụ có khả năng lọc không khí, hấp thụ các chất độc hại như formaldehyde, benzene, và các khí độc khác. Điều này giúp không gian sống trong lành và sạch sẽ hơn.\r\nDễ chăm sóc:\r\n\r\nCây không yêu cầu quá nhiều công chăm sóc, chỉ cần tưới nước định kỳ và cung cấp đủ ánh sáng là cây có thể sinh trưởng khỏe mạnh. Điều này làm cây trở thành lựa chọn lý tưởng cho những người bận rộn hoặc không có nhiều kinh nghiệm chăm sóc cây.\r\nTăng tính thẩm mỹ:\r\n\r\nCây DGA Huyết Dụ có vẻ đẹp rất thu hút với lá màu sắc đặc trưng. Sự kết hợp giữa màu xanh lá cây và màu đỏ huyết dụ tạo nên một bức tranh màu sắc nổi bật, làm tươi mới và sinh động không gian.\r\nỨng dụng của Cây DGA Huyết Dụ:\r\nTrang trí nội thất:\r\n\r\nCây DGA Huyết Dụ rất thích hợp để trang trí trong các không gian sống như phòng khách, phòng làm việc, hoặc các góc nhỏ trong nhà. Cây có thể được đặt trên bàn, kệ sách, hoặc để làm điểm nhấn cho các khu vực ít được chú ý.\r\nGiỏ treo:\r\n\r\nVới khả năng phát triển mạnh mẽ và dễ dàng leo bám vào các giá đỡ, cây có thể được trồng trong giỏ treo để tiết kiệm diện tích và tạo ra không gian xanh mát, hài hòa.\r\nQuà tặng:\r\n\r\nCây DGA Huyết Dụ là món quà rất thích hợp cho những người yêu thích cây cảnh hoặc muốn làm mới không gian sống. Sự kết hợp giữa vẻ đẹp và ý nghĩa phong thủy của cây khiến đây là một lựa chọn quà tặng lý tưởng.\r\nLọc không khí:\r\n\r\nNhờ khả năng lọc không khí, cây DGA Huyết Dụ rất phù hợp để trồng trong các văn phòng, phòng ngủ, hoặc những không gian cần làm sạch không khí.\r\nPhong thủy của Cây DGA Huyết Dụ:\r\nCây DGA Huyết Dụ không chỉ được yêu thích vì vẻ đẹp mà còn có ý nghĩa phong thủy đặc biệt. Cây mang lại may mắn và tài lộc cho gia chủ, giúp gia đình luôn khỏe mạnh, bình an. Ngoài ra, cây cũng được cho là có khả năng xua đuổi tà khí, mang lại sự thịnh vượng và bình yên cho ngôi nhà.\r\n\r\nCây DGA Huyết Dụ không chỉ giúp cải thiện không gian sống mà còn mang lại những lợi ích về sức khỏe và phong thủy. Với vẻ đẹp đặc trưng và tính dễ chăm sóc, cây này là lựa chọn lý tưởng cho những ai yêu thích cây xanh nhưng không có nhiều thời gian chăm sóc.\r\n', 10, 1),
(66, 'Cây Tiểu Cảnh Để Bàn', 10, 1, 'img/cmn5.jpg', 'Cây Tiểu Cảnh Để Bàn là một loại cây cảnh nhỏ gọn, thường được trồng trong các chậu nhỏ hoặc các tiểu cảnh mini, thích hợp để trang trí bàn làm việc, bàn học, hoặc các không gian nhỏ trong gia đình. Cây không chỉ làm đẹp không gian mà còn giúp mang lại sự tươi mới, thư giãn, và có thể cải thiện chất lượng không khí trong phòng.\r\n\r\nĐặc điểm nổi bật của Cây Tiểu Cảnh Để Bàn:\r\nKích thước nhỏ gọn:\r\n\r\nCây Tiểu Cảnh Để Bàn có kích thước nhỏ, dễ dàng đặt trên bàn làm việc, bàn học hoặc các kệ trang trí mà không chiếm nhiều diện tích. Đây là sự lựa chọn hoàn hảo cho những không gian nhỏ hoặc nơi cần trang trí tinh tế.\r\nDễ chăm sóc:\r\n\r\nNhững cây tiểu cảnh này thường rất dễ chăm sóc. Chúng yêu cầu ít nước và ánh sáng, chỉ cần tưới nước vừa phải và cung cấp ánh sáng gián tiếp là cây sẽ phát triển khỏe mạnh.\r\nĐa dạng chủng loại:\r\n\r\nCây Tiểu Cảnh Để Bàn có thể bao gồm nhiều loại cây nhỏ khác nhau, từ cây cảnh lá, cây succulents (cây mọng nước), đến các cây có hoa nhỏ. Mỗi loại cây mang lại một vẻ đẹp riêng và tạo nên sự đa dạng trong không gian.\r\nTạo cảm giác thư giãn:\r\n\r\nVới vẻ ngoài xanh mát và gần gũi với thiên nhiên, cây tiểu cảnh giúp tạo ra một không gian thư giãn, giảm căng thẳng và làm dịu đi sự mệt mỏi trong công việc hoặc học tập.\r\nLợi ích của Cây Tiểu Cảnh Để Bàn:\r\nTrang trí không gian:\r\n\r\nCây Tiểu Cảnh Để Bàn là lựa chọn lý tưởng để làm đẹp không gian làm việc, phòng ngủ hoặc phòng khách. Cây nhỏ gọn nhưng lại tạo nên điểm nhấn, mang lại vẻ sinh động cho không gian.\r\nCải thiện chất lượng không khí:\r\n\r\nGiống như nhiều loại cây khác, cây tiểu cảnh có khả năng lọc không khí, giúp hấp thụ các chất độc hại và cung cấp oxy, tạo ra không gian trong lành hơn.\r\nPhong thủy:\r\n\r\nTrong phong thủy, cây cảnh để bàn được cho là mang lại may mắn, tài lộc và sức khỏe cho gia chủ. Nhiều người tin rằng cây nhỏ này giúp tăng cường năng lượng tích cực, xua đuổi tà khí và mang lại bình an cho gia đình.\r\nỨng dụng của Cây Tiểu Cảnh Để Bàn:\r\nTrang trí bàn làm việc:\r\n\r\nMột cây tiểu cảnh nhỏ trên bàn làm việc giúp không gian làm việc trở nên sinh động và dễ chịu hơn. Cây cũng có thể giúp bạn cảm thấy thư giãn, tăng năng suất làm việc.\r\nQuà tặng ý nghĩa:\r\n\r\nCây Tiểu Cảnh Để Bàn là món quà thích hợp cho bạn bè, người thân hoặc đồng nghiệp trong các dịp sinh nhật, lễ tết, hoặc khi muốn gửi tặng một món quà mang ý nghĩa tốt đẹp.\r\nTrang trí trong không gian nhỏ:\r\n\r\nVới kích thước nhỏ, cây có thể được đặt trong những không gian hạn chế như phòng ngủ, phòng khách, hành lang hoặc các kệ sách. Mặc dù nhỏ nhưng chúng vẫn tạo ra không gian xanh mát và dễ chịu.\r\nCải thiện phong thủy:\r\n\r\nCây tiểu cảnh còn được sử dụng để cải thiện phong thủy, giúp gia chủ đón nhận năng lượng tích cực và mang lại sự thịnh vượng, bình an cho gia đình.\r\nCác loại Cây Tiểu Cảnh Để Bàn phổ biến:\r\nCây Sanh:\r\n\r\nCây Sanh là cây dễ chăm sóc, thích hợp cho tiểu cảnh để bàn, có tác dụng lọc không khí và mang lại sự thư giãn.\r\nCây Hành Tinh:\r\n\r\nLà một loại cây mọng nước (succulent), Cây Hành Tinh có vẻ ngoài nhỏ gọn và dễ chăm sóc, rất thích hợp để trang trí bàn làm việc hoặc bàn học.\r\nCây Kim Tiền:\r\n\r\nCây Kim Tiền thường được trồng trong các chậu nhỏ, là biểu tượng của sự may mắn và thịnh vượng. Đây là cây phong thủy rất được ưa chuộng.\r\nCây Sen Đá:\r\n\r\nCây Sen Đá là một loại cây mọng nước rất dễ trồng và chăm sóc, có thể phát triển tốt trong môi trường thiếu ánh sáng.\r\nCách chăm sóc Cây Tiểu Cảnh Để Bàn:\r\nÁnh sáng:\r\n\r\nĐảm bảo cây nhận đủ ánh sáng, nhưng tránh ánh sáng mặt trời trực tiếp vì có thể làm cây bị cháy lá. Ánh sáng gián tiếp là lý tưởng.\r\nTưới nước:\r\n\r\nCây Tiểu Cảnh Để Bàn không yêu cầu tưới nước quá nhiều. Tưới nước vừa đủ, khi đất bắt đầu khô là tốt nhất.\r\nKiểm tra sâu bệnh:\r\n\r\nThường xuyên kiểm tra cây để phát hiện sớm các dấu hiệu của sâu bệnh. Nếu có, cần xử lý kịp thời để bảo vệ cây.\r\nCây Tiểu Cảnh Để Bàn là một lựa chọn lý tưởng cho những không gian nhỏ, mang lại vẻ đẹp tự nhiên và không khí trong lành, đồng thời giúp tạo ra không gian làm việc, học tập hoặc nghỉ ngơi thư giãn.', 10, 1),
(67, 'Cây Môn Xanh Nhật Bản', 10, 1, 'img/cmn6.jpg', 'Cây Môn Xanh Nhật Bản (tên khoa học: Anthurium) là một loại cây cảnh phổ biến với vẻ đẹp đặc trưng và dễ chăm sóc, mang lại sự tươi mới và sang trọng cho không gian sống. Cây có nguồn gốc từ các khu vực nhiệt đới của Châu Mỹ, nhưng hiện nay đã được trồng phổ biến ở nhiều nơi, đặc biệt là ở Nhật Bản.\r\n\r\nĐặc điểm nổi bật của Cây Môn Xanh Nhật Bản:\r\nLá và hoa đặc biệt:\r\n\r\nCây Môn Xanh Nhật Bản nổi bật với lá có màu xanh sáng bóng và hình dáng đặc trưng, có thể phát triển dài và rộng, tạo nên vẻ đẹp sang trọng. Hoa của cây thường có màu sắc rực rỡ, với một phần lá bao quanh có màu đỏ, hồng, hoặc trắng.\r\nLá xanh bóng và bền:\r\n\r\nLá cây mịn màng, xanh tươi và bóng, giúp không gian trông tươi mới và dễ chịu. Cây có khả năng sinh trưởng tốt trong điều kiện ít ánh sáng, thích hợp cho cả không gian trong nhà.\r\nDễ chăm sóc:\r\n\r\nCây Môn Xanh Nhật Bản rất dễ chăm sóc, không yêu cầu quá nhiều công sức. Chỉ cần đảm bảo cung cấp đủ nước, ánh sáng vừa phải và môi trường thoáng mát, cây sẽ phát triển mạnh mẽ.\r\nLợi ích của Cây Môn Xanh Nhật Bản:\r\nTrang trí không gian:\r\n\r\nVới vẻ đẹp sang trọng và thanh lịch, cây môn xanh Nhật Bản là sự lựa chọn tuyệt vời để trang trí bàn làm việc, phòng khách, phòng ngủ, hoặc các không gian nội thất khác.\r\nCải thiện chất lượng không khí:\r\n\r\nCây có khả năng lọc không khí, hấp thụ các chất độc hại như formaldehyde, benzene, và toluene, giúp cải thiện chất lượng không khí trong nhà.\r\nPhong thủy:\r\n\r\nCây Môn Xanh Nhật Bản còn mang ý nghĩa phong thủy, biểu tượng của sự thịnh vượng, tài lộc và hạnh phúc. Nó được cho là mang lại may mắn và tài lộc cho gia chủ.\r\nỨng dụng của Cây Môn Xanh Nhật Bản:\r\nTrang trí trong không gian sống:\r\n\r\nCây Môn Xanh Nhật Bản có thể được trồng trong các chậu nhỏ để trang trí các không gian trong nhà như phòng khách, phòng ngủ, hoặc các văn phòng làm việc. Cây giúp tạo điểm nhấn, mang lại vẻ đẹp thanh thoát và tự nhiên cho không gian sống.\r\nQuà tặng ý nghĩa:\r\n\r\nVới vẻ đẹp và ý nghĩa phong thủy, cây môn xanh Nhật Bản là món quà tuyệt vời để tặng bạn bè, người thân trong các dịp lễ, sinh nhật hay những dịp đặc biệt.\r\nCải thiện không gian làm việc:\r\n\r\nCây Môn Xanh Nhật Bản có thể giúp cải thiện không gian làm việc, làm cho không gian trở nên dễ chịu hơn, giúp tăng sự sáng tạo và năng suất công việc.\r\nCách chăm sóc Cây Môn Xanh Nhật Bản:\r\nÁnh sáng:\r\n\r\nCây Môn Xanh Nhật Bản thích ánh sáng gián tiếp, không cần ánh sáng mặt trời trực tiếp. Nên đặt cây ở nơi có ánh sáng vừa phải, tránh nơi quá tối hay ánh sáng quá mạnh.\r\nTưới nước:\r\n\r\nCây cần được tưới nước đều đặn, nhưng không để nước đọng lại trong chậu, vì điều này có thể gây ra tình trạng thối rễ. Tưới nước khi lớp đất trên bề mặt khô đi là phù hợp.\r\nNhiệt độ và độ ẩm:\r\n\r\nCây phát triển tốt trong môi trường ấm áp và độ ẩm cao. Vì vậy, nếu trồng trong nhà, bạn có thể đặt cây gần cửa sổ để có đủ ánh sáng, đồng thời duy trì độ ẩm bằng cách phun nước vào không khí xung quanh cây hoặc dùng máy tạo độ ẩm.\r\nBón phân:\r\n\r\nCây Môn Xanh Nhật Bản có thể cần bón phân định kỳ (thường 1-2 lần/tháng) để thúc đẩy sự phát triển của lá và hoa.\r\nKiểm tra sâu bệnh:\r\n\r\nDù là cây dễ chăm sóc nhưng cây Môn Xanh Nhật Bản cũng cần được kiểm tra thường xuyên để phát hiện các loại sâu bệnh. Nếu thấy có dấu hiệu của bệnh, cần xử lý kịp thời để bảo vệ cây.\r\nKết luận:\r\nCây Môn Xanh Nhật Bản không chỉ là một cây cảnh đẹp mắt, mà còn có khả năng thanh lọc không khí và mang lại nhiều ý nghĩa phong thủy. Với đặc tính dễ chăm sóc và vẻ ngoài sang trọng, cây môn xanh Nhật Bản xứng đáng là lựa chọn tuyệt vời để trang trí không gian sống và làm việc của bạn.', 10, 1),
(68, 'Cây Môn Nhí Lá Tròn', 10, 1, 'img/cmn7.jpg', 'Cây Môn Nhí Lá Tròn (tên khoa học: Anthurium), còn được gọi là cây Môn mini hoặc Môn lá tròn, là một giống cây cảnh phổ biến, dễ chăm sóc và thích hợp để trang trí trong nhà. Cây này có nguồn gốc từ các vùng nhiệt đới, nhưng đã trở nên phổ biến trong các không gian sống nhờ vẻ đẹp thanh thoát và sự dễ chịu mà nó mang lại.\r\n\r\nĐặc điểm nổi bật của Cây Môn Nhí Lá Tròn:\r\nLá đặc trưng:\r\n\r\nCây có lá hình tròn, nhỏ và mịn màng, với màu xanh đậm bóng bẩy. Đặc biệt, các lá của cây môn nhí có kích thước nhỏ hơn so với các loại môn thông thường, tạo nên vẻ duyên dáng và dễ thương.\r\nHoa đặc biệt:\r\n\r\nCây môn nhí thường có hoa màu sắc tươi sáng, với cánh hoa mềm mại bao quanh phần nhụy vàng. Mặc dù hoa của cây khá nhỏ, nhưng chúng vẫn mang lại nét đẹp rất riêng, tạo điểm nhấn cho không gian trang trí.\r\nKích thước nhỏ gọn:\r\n\r\nVới kích thước nhỏ nhắn, cây môn nhí lá tròn rất phù hợp để trồng trong các chậu nhỏ hoặc trang trí bàn làm việc, phòng khách, phòng ngủ hay góc làm việc.\r\nLợi ích của Cây Môn Nhí Lá Tròn:\r\nTrang trí không gian sống:\r\n\r\nCây môn nhí lá tròn thường được sử dụng để trang trí các không gian nhỏ như bàn làm việc, kệ sách, bàn trà hay góc phòng. Với vẻ đẹp thanh thoát và nhỏ nhắn, cây giúp không gian trở nên tươi mới và gần gũi hơn.\r\nCải thiện không khí:\r\n\r\nNhư các loại cây môn khác, cây môn nhí lá tròn cũng có khả năng thanh lọc không khí, hấp thụ các chất độc hại như formaldehyde và benzene, giúp không gian trong lành hơn.\r\nPhong thủy tốt lành:\r\n\r\nCây môn lá tròn còn mang ý nghĩa phong thủy, tượng trưng cho sự thịnh vượng và tài lộc. Cây được cho là mang lại may mắn và hạnh phúc cho gia chủ.\r\nỨng dụng của Cây Môn Nhí Lá Tròn:\r\nTrang trí trong không gian sống:\r\n\r\nVới kích thước nhỏ và dễ chăm sóc, cây môn nhí lá tròn là lựa chọn lý tưởng để trang trí trong các không gian nội thất, như phòng khách, phòng ngủ, văn phòng làm việc, hoặc các kệ trang trí nhỏ.\r\nQuà tặng ý nghĩa:\r\n\r\nCây môn nhí lá tròn là món quà tuyệt vời cho những dịp đặc biệt như sinh nhật, lễ tết hoặc để tặng người thân, bạn bè. Cây mang lại không chỉ giá trị thẩm mỹ mà còn chứa đựng ý nghĩa phong thủy tốt lành.\r\nCải thiện không gian làm việc:\r\n\r\nCây môn nhí lá tròn có thể giúp tăng cường sự tập trung và năng suất làm việc, đồng thời làm cho không gian làm việc trở nên tươi mới và dễ chịu hơn.\r\nCách chăm sóc Cây Môn Nhí Lá Tròn:\r\nÁnh sáng:\r\n\r\nCây môn nhí lá tròn thích ánh sáng gián tiếp, không cần ánh sáng mặt trời trực tiếp. Vì vậy, bạn có thể đặt cây gần cửa sổ nhưng tránh ánh sáng trực tiếp chiếu vào.\r\nTưới nước:\r\n\r\nCây cần được tưới nước đều đặn, nhưng không để nước đọng lại trong chậu vì có thể gây thối rễ. Tưới khi lớp đất trên bề mặt khô và tránh tưới quá nhiều nước.\r\nNhiệt độ và độ ẩm:\r\n\r\nCây phát triển tốt trong môi trường ấm áp với nhiệt độ từ 18°C đến 25°C. Để cây phát triển khỏe mạnh, bạn cũng có thể phun sương cho cây nếu môi trường quá khô.\r\nBón phân:\r\n\r\nBón phân cho cây mỗi 1-2 tháng để thúc đẩy sự phát triển của cây, đặc biệt là vào mùa xuân và hè khi cây cần nhiều dinh dưỡng hơn.\r\nKiểm tra sâu bệnh:\r\n\r\nDù cây môn nhí lá tròn khá dễ chăm sóc, nhưng bạn cũng cần kiểm tra thường xuyên để phát hiện sâu bệnh và xử lý kịp thời nếu có.\r\nKết luận:\r\nCây Môn Nhí Lá Tròn là một sự lựa chọn tuyệt vời cho những ai yêu thích cây cảnh nhỏ gọn, dễ chăm sóc và mang lại vẻ đẹp tươi mới cho không gian sống. Với khả năng thanh lọc không khí và ý nghĩa phong thủy tích cực, cây môn nhí lá tròn không chỉ là một cây cảnh trang trí mà còn là món quà mang lại may mắn và tài lộc.', 10, 1),
(69, 'Cây Ngũ Gia Bì', 10, 1, 'img/cmn8.jpg', 'Cây Ngũ Gia Bì (tên khoa học: Schefflera arboricola), còn được gọi là cây Ngũ Gia Bì lá nhỏ hoặc Cây Ngũ Gia Bì mini, là một loại cây cảnh phổ biến trong các không gian sống, văn phòng, nhà ở và đặc biệt là trong các khu vực có diện tích nhỏ. Cây Ngũ Gia Bì có nguồn gốc từ các vùng nhiệt đới và cận nhiệt đới, nổi bật với lá hình ngôi sao và màu sắc tươi sáng.\r\n\r\nĐặc điểm nổi bật của Cây Ngũ Gia Bì:\r\nLá đặc trưng:\r\n\r\nCây có lá hình ngôi sao, chia thành nhiều chùm nhỏ (thường là 5 lá), với màu xanh bóng mượt. Lá của cây có thể có màu xanh đậm hoặc vàng sáng tùy vào giống cây, tạo cảm giác rất tươi mới và sinh động.\r\nThân cây:\r\n\r\nCây có thân gỗ cứng cáp, có thể phát triển thành cây bụi hoặc cây nhỏ nếu được trồng trong chậu. Cây có thể đạt chiều cao từ 30cm đến 2m tùy vào cách chăm sóc và môi trường sống.\r\nCây dễ chăm sóc:\r\n\r\nCây Ngũ Gia Bì rất dễ chăm sóc và phù hợp với nhiều không gian khác nhau. Với khả năng sinh trưởng nhanh và ít bị sâu bệnh, đây là một sự lựa chọn lý tưởng cho những ai muốn trang trí không gian mà không cần phải tốn quá nhiều thời gian chăm sóc.\r\nLợi ích của Cây Ngũ Gia Bì:\r\nTrang trí không gian sống:\r\n\r\nCây Ngũ Gia Bì là lựa chọn tuyệt vời để trang trí trong các không gian nhà ở, văn phòng, hành lang, hay sân vườn. Cây có thể trồng trong chậu nhỏ để làm cây trang trí trên bàn làm việc hoặc kệ sách, mang lại cảm giác xanh mát và tươi mới cho không gian.\r\nThanh lọc không khí:\r\n\r\nGiống như nhiều loại cây khác, cây Ngũ Gia Bì cũng có khả năng thanh lọc không khí, giúp giảm bớt các chất ô nhiễm trong môi trường sống. Nó có thể hấp thụ một số khí độc hại và cung cấp một không gian trong lành hơn cho con người.\r\nPhong thủy:\r\n\r\nCây Ngũ Gia Bì còn mang ý nghĩa phong thủy tốt lành. Với tên gọi \"Ngũ Gia Bì\", cây tượng trưng cho sự hòa hợp và phát triển bền vững, mang lại may mắn và tài lộc cho gia chủ. Đặc biệt, cây cũng giúp cân bằng năng lượng trong không gian sống.\r\nCách chăm sóc Cây Ngũ Gia Bì:\r\nÁnh sáng:\r\n\r\nCây Ngũ Gia Bì phát triển tốt dưới ánh sáng nhẹ nhàng hoặc ánh sáng gián tiếp. Cây có thể sống trong bóng râm, nhưng để cây phát triển tốt nhất, bạn nên đặt cây ở nơi có ánh sáng tự nhiên, tránh ánh sáng trực tiếp mạnh mẽ.\r\nTưới nước:\r\n\r\nCây cần được tưới nước đều đặn nhưng không để đất quá ẩm ướt, vì cây dễ bị thối rễ nếu bị ngập úng. Tưới nước khi đất cảm thấy khô, nhưng tránh để đất quá khô lâu ngày.\r\nNhiệt độ và độ ẩm:\r\n\r\nCây Ngũ Gia Bì thích hợp với nhiệt độ ấm áp từ 18°C đến 25°C. Độ ẩm của không khí không cần quá cao, nhưng nếu không gian quá khô, bạn có thể phun sương để cây phát triển tốt hơn.\r\nBón phân:\r\n\r\nĐể cây phát triển mạnh mẽ và khỏe mạnh, bạn có thể bón phân cho cây mỗi 1-2 tháng trong mùa sinh trưởng (mùa xuân và hè). Sử dụng phân hữu cơ hoặc phân bón cây cảnh chuyên dụng để bón cho cây.\r\nCắt tỉa:\r\n\r\nĐể cây giữ được hình dạng gọn gàng và phát triển mạnh mẽ, bạn có thể cắt tỉa những lá và cành khô, héo. Cắt tỉa giúp cây phát triển tốt và cũng tạo vẻ đẹp thẩm mỹ cho cây.\r\nỨng dụng của Cây Ngũ Gia Bì:\r\nTrang trí không gian:\r\n\r\nCây Ngũ Gia Bì có thể được trồng trong các chậu trang trí nhỏ hoặc đặt trong các góc phòng, văn phòng làm việc, phòng khách, phòng ngủ hay phòng họp. Với dáng cây nhỏ gọn và màu sắc tươi mới, cây mang lại không gian thư giãn và làm mới không gian sống.\r\nQuà tặng:\r\n\r\nCây Ngũ Gia Bì là món quà tuyệt vời để tặng bạn bè, người thân trong các dịp lễ, sinh nhật hay dịp đặc biệt. Món quà này không chỉ đẹp mà còn mang lại ý nghĩa phong thủy và tạo không gian xanh mát.\r\nCải thiện không khí trong văn phòng:\r\n\r\nVì cây dễ chăm sóc và thanh lọc không khí, cây Ngũ Gia Bì là lựa chọn lý tưởng để đặt trên bàn làm việc hay trong không gian văn phòng, giúp không gian làm việc trở nên dễ chịu và tăng cường sự sáng tạo, năng suất làm việc.\r\nKết luận:\r\nCây Ngũ Gia Bì là một trong những loại cây cảnh dễ chăm sóc và mang lại nhiều lợi ích, từ việc trang trí không gian sống đến cải thiện chất lượng không khí và phong thủy. Với vẻ đẹp tươi mới, cây Ngũ Gia Bì không chỉ giúp tạo điểm nhấn cho không gian mà còn mang lại may mắn và tài lộc cho gia chủ.\r\n', 10, 1),
(72, 'Cây dương xỉ', 10, 1, 'img/product_673a2a830ed644.54278460.jpg', 'Cây thực vật', 300, 1),
(74, 'Hoa', 4, 4, 'img/product_675d270d42c137.74287975.jpg', 'Hoa là một phần không thể thiếu của thiên nhiên, mang vẻ đẹp rực rỡ và đa dạng về hình dáng, màu sắc cũng như ý nghĩa. Mỗi loài hoa đều có nét đặc trưng riêng, từ sự thanh tao của hoa sen, sự kiêu sa của hoa hồng, đến sự mong manh của hoa anh đào hay sức sống mãnh liệt của hoa hướng dương. Hoa không chỉ làm đẹp cho không gian sống mà còn thể hiện tình cảm, cảm xúc và thông điệp mà con người muốn gửi gắm. Trong văn hóa, hoa là biểu tượng của sự yêu thương, hy vọng, và sự vươn lên giữa những thử thách của cuộc đời. Dù ở bất kỳ đâu, hoa luôn gợi lên niềm vui và sự bình yên trong tâm hồn.', 25, 1),
(75, 'Hoa Cẩm Tú Cầu', 4, 4, 'img/product_675d21b0d7b069.49267879.jpg', 'Hoa cẩm tú cầu (Hydrangea) là loài hoa nổi bật với vẻ đẹp dịu dàng, tinh tế và đa dạng về màu sắc. Cẩm tú cầu có thể thay đổi màu sắc tùy theo pH của đất, tạo nên một bức tranh màu sắc đẹp mắt và ấn tượng.\r\n\r\nĐặc điểm của hoa cẩm tú cầu:\r\nHình dáng: Hoa cẩm tú cầu mọc thành chùm lớn, gồm rất nhiều hoa nhỏ xếp chặt với nhau, tạo thành hình cầu lớn.\r\nMàu sắc: Hoa có nhiều màu sắc khác nhau như xanh dương, hồng, trắng, tím và đỏ. Màu sắc của hoa có thể thay đổi tuỳ theo độ pH của đất: nếu đất chua, hoa sẽ có màu xanh; nếu đất kiềm, hoa sẽ có màu hồng.\r\nThân cây: Cây cẩm tú cầu có thân mềm, cao khoảng 1-3m, và tán lá rộng.\r\nMùa nở: Hoa thường nở vào mùa hè và kéo dài đến mùa thu.\r\nÝ nghĩa của hoa cẩm tú cầu:\r\nBiểu tượng của sự biết ơn: Hoa cẩm tú cầu thường được tặng để thể hiện lòng biết ơn và cảm kích đối với người khác.\r\nTình bạn và sự chân thành: Cẩm tú cầu còn tượng trưng cho tình bạn, sự đoàn kết và lòng trung thành.\r\nSự thay đổi và tái sinh: Vì hoa có thể thay đổi màu sắc theo điều kiện môi trường, nó cũng là biểu tượng của sự thay đổi và phát triển trong cuộc sống.\r\nỨng dụng:\r\nTrang trí: Cẩm tú cầu là loài hoa được yêu thích trong trang trí nhà cửa, làm hoa cưới, hay trang trí các buổi tiệc.\r\nQuà tặng: Hoa cẩm tú cầu là món quà ý nghĩa để tặng trong các dịp đặc biệt như sinh nhật, lễ kỷ niệm, hay các sự kiện quan trọng.\r\nChăm sóc sức khỏe: Các bộ phận của cây cẩm tú cầu cũng được sử dụng trong y học cổ truyền để điều trị một số bệnh.\r\nHoa cẩm tú cầu không chỉ đẹp mà còn mang ý nghĩa sâu sắc, là biểu tượng của tình bạn, sự biết ơn và sự thay đổi, khiến nó trở thành loài hoa được yêu thích trong nhiều nền văn hóa.', 700, 1),
(76, 'Hoa Ly', 5, 4, 'img/product_675d227318db77.11700871.jpg', 'Hoa ly là một loài hoa đẹp, được yêu thích bởi vẻ thanh khiết và hương thơm quyến rũ. Với nhiều màu sắc như trắng, hồng, vàng, và đỏ, hoa ly thường xuất hiện trong các dịp lễ trọng đại hoặc dùng làm quà tặng ý nghĩa. Hoa tượng trưng cho sự tinh tế, cao quý và tình yêu sâu sắc. Ngoài ra, loài hoa này còn góp phần tạo điểm nhấn cho không gian sống và sự kiện. Hoa ly dễ chăm sóc, chỉ cần ánh sáng vừa đủ, đất tơi xốp và tưới nước hợp lý. Đây không chỉ là biểu tượng của cái đẹp mà còn mang lại cảm giác thư thái và an lành.', 50, 1),
(77, 'Hoa Anh Đào', 5, 4, 'img/product_675d23093152a2.86046138.jpg', 'Hoa anh đào, hay còn gọi là Sakura, là biểu tượng của mùa xuân và vẻ đẹp tinh tế của Nhật Bản. Loài hoa này thường nở vào tháng 3 và tháng 4, phủ sắc hồng hoặc trắng nhẹ khắp các công viên và đường phố. Với hình dáng nhỏ nhắn và cánh mỏng manh, hoa anh đào tượng trưng cho sự mong manh và ngắn ngủi của cuộc sống. Đây là dịp để người dân tổ chức lễ hội Hanami, ngắm hoa và tụ họp bạn bè, gia đình. Hoa anh đào không chỉ đẹp mà còn thể hiện tinh thần đoàn kết và khởi đầu mới. Bên cạnh đó, nó còn được sử dụng trong ẩm thực, như trà hoa anh đào hay bánh ngọt. Vẻ đẹp dịu dàng của hoa gợi nhắc con người trân trọng từng khoảnh khắc.', 30, 1),
(78, 'Hoa Linh Lan', 6, 4, 'img/product_675d2379643ff7.65906191.jpg', 'Hoa linh lan, còn gọi là lan chuông hay huệ chuông (tên khoa học: Convallaria majalis), là một loài hoa nhỏ nhắn, duyên dáng và mang hương thơm ngọt ngào. Hoa thường nở vào mùa xuân và được yêu thích bởi vẻ đẹp tinh khôi cùng ý nghĩa sâu sắc.  Đặc điểm của hoa linh lan: Hình dáng: Hoa nhỏ, hình chuông, màu trắng hoặc trắng kem, mọc thành chùm rủ trên thân mảnh mai. Hương thơm: Ngọt ngào, dễ chịu, thường được dùng để chiết xuất nước hoa. Mùa nở: Tháng 4 đến tháng 6, tuỳ thuộc vào điều kiện khí hậu. Ý nghĩa của hoa linh lan: Biểu tượng của sự trong sáng: Hoa tượng trưng cho sự tinh khiết và ngây thơ. Hạnh phúc trở lại: Thường được dùng để chúc mừng khởi đầu mới hoặc hạnh phúc sau những khó khăn. Lòng biết ơn: Được sử dụng trong các dịp tri ân, bày tỏ tình cảm chân thành. Ứng dụng: Trang trí: Phổ biến trong bó hoa cưới, lễ hội và trang trí không gian sống. Chiết xuất: Là nguyên liệu quý trong ngành nước hoa nhờ hương thơm thanh khiết. Y học cổ truyền: Có tác dụng trong một số bài thuốc thảo dược. Hoa linh lan không chỉ đẹp mà còn mang giá trị tinh thần và nghệ thuật, là biểu tượng cho những điều tốt đẹp và thuần khiết trong cuộc sống.', 36, 1),
(79, 'Hoa Hướng Dương', 10, 4, 'img/product_675d23d268c1a9.84540105.jpg', 'Hoa hướng dương, hay còn gọi là quỳ hoa tử (Helianthus annuus), là một loài hoa nổi bật với vẻ đẹp rực rỡ và đầy sức sống. Đúng như tên gọi, hoa luôn hướng về phía mặt trời, biểu trưng cho hy vọng, sự lạc quan và nghị lực sống.  Đặc điểm của hoa hướng dương: Hình dáng: Hoa lớn, có nhiều cánh vàng rực rỡ bao quanh phần nhụy tròn màu nâu hoặc đen. Thân cây: Cao, thẳng, lá to và có hình trái tim. Hướng hoa: Luôn quay về phía mặt trời nhờ hiện tượng quang hướng. Mùa nở: Thường từ mùa hè đến mùa thu. Ý nghĩa của hoa hướng dương: Sự lạc quan và hy vọng: Tượng trưng cho niềm tin vào một tương lai tươi sáng. Tình yêu trung thành: Hoa luôn hướng về mặt trời, như biểu hiện của tình yêu chân thành, bất diệt. Thành công và thịnh vượng: Thường xuất hiện trong các dịp chúc mừng, khai trương. Ứng dụng: Trang trí: Hoa được sử dụng để làm đẹp không gian sống, sự kiện và lễ hội. Quà tặng: Thích hợp để gửi tặng những lời chúc tốt đẹp đến bạn bè và người thân. Thực phẩm: Hạt hướng dương là một món ăn nhẹ phổ biến, chứa nhiều chất dinh dưỡng. Y học: Các bộ phận của cây được dùng trong đông y để hỗ trợ sức khỏe. Với vẻ đẹp rạng ngời và ý nghĩa tích cực, hoa hướng dương không chỉ làm say mê người yêu hoa mà còn là nguồn cảm hứng cho nhiều lĩnh vực nghệ thuật.', 50, 1),
(80, 'Hoa Tu Lip', 3, 4, 'img/product_675d2429d8ce25.40125236.jpg', 'Hoa tulip, hay còn gọi là uất kim hương (Tulipa), là một trong những loài hoa nổi tiếng và được yêu thích trên toàn thế giới. Với hình dáng thanh thoát và màu sắc đa dạng, tulip là biểu tượng của sự thanh lịch, tình yêu và sự tái sinh.  Đặc điểm của hoa tulip: Hình dáng: Hoa có hình dáng như chiếc chuông úp ngược, cánh hoa mịn màng và cân đối. Màu sắc: Đa dạng, từ đỏ, hồng, vàng, cam, trắng đến tím, thậm chí có hoa phối nhiều màu. Thời gian nở: Thường nở vào mùa xuân, từ tháng 3 đến tháng 5. Chiều cao: Từ 10 cm đến 70 cm, tùy loài. Ý nghĩa của hoa tulip: Tình yêu hoàn hảo: Đặc biệt là hoa tulip đỏ. Sự giàu sang, thịnh vượng: Tượng trưng cho đỉnh cao của sự thành công. Hy vọng và khởi đầu mới: Liên quan đến mùa xuân và sự sống mới. Màu sắc và ý nghĩa: Đỏ: Tình yêu sâu đậm. Vàng: Nụ cười, niềm vui. Trắng: Sự thuần khiết, tha thứ. Tím: Sự cao quý. Ứng dụng: Trang trí: Thích hợp cho các dịp lễ hội, trang trí nhà cửa và sự kiện. Quà tặng: Là món quà ý nghĩa dành cho người thân yêu, bạn bè. Du lịch: Những cánh đồng tulip rộng lớn ở Hà Lan, đặc biệt là Keukenhof, thu hút hàng triệu du khách mỗi năm. Hoa tulip không chỉ đẹp mà còn mang ý nghĩa sâu sắc về tình yêu và cuộc sống, là biểu tượng của vẻ đẹp tinh tế và niềm hy vọng trong lòng mỗi người.', 25, 1),
(81, 'Hoa Sen', 2, 4, 'img/product_675d2486583527.32663642.jpg', 'Hoa sen (Nelumbo nucifera) là biểu tượng cao quý trong văn hóa và tín ngưỡng nhiều quốc gia, đặc biệt là Việt Nam, Ấn Độ, và các nước Đông Nam Á. Với vẻ đẹp thanh khiết và sức sống mạnh mẽ, sen được ví như biểu tượng của sự thuần khiết và trí tuệ.  Đặc điểm của hoa sen: Hình dáng: Hoa có nhiều cánh xếp đều, nhụy vàng rực rỡ nằm ở trung tâm, tỏa hương dịu dàng. Màu sắc: Thường là màu hồng, trắng, đôi khi vàng nhạt. Thân cây: Mọc từ bùn lầy, vươn thẳng lên mặt nước, lá to bản tròn. Mùa nở: Từ tháng 6 đến tháng 8, là mùa sen đẹp nhất trong năm. Ý nghĩa của hoa sen: Sự thanh khiết: \"Gần bùn mà chẳng hôi tanh mùi bùn\", sen biểu trưng cho sự trong sáng, vượt lên khó khăn. Biểu tượng tâm linh: Trong Phật giáo, sen là biểu tượng của sự giác ngộ và trí tuệ. Tình yêu và lòng trung thành: Sen hồng gắn liền với sự tôn kính và lòng chân thành. Văn hóa Việt Nam: Hoa sen là quốc hoa, thể hiện tinh thần dân tộc giản dị mà cao đẹp. Ứng dụng: Trang trí: Được sử dụng trong các dịp lễ, sự kiện hoặc trang trí không gian sống. Ẩm thực: Các bộ phận của sen như hạt, củ, và lá được chế biến thành nhiều món ăn, trà sen, hoặc dùng làm thuốc. Mỹ phẩm: Chiết xuất từ hoa sen thường được dùng trong các sản phẩm dưỡng da. Hoa sen không chỉ là biểu tượng của vẻ đẹp thanh tao mà còn gắn liền với triết lý sống cao đẹp, gợi nhắc con người sống vươn lên và giữ lòng trong sáng giữa cuộc đời.', 80, 1),
(82, 'Hoa Hồng ', 5, 4, 'img/product_675d25b41e2a80.74064342.jpg', 'Hoa hồng (Rosa), được mệnh danh là \"nữ hoàng của các loài hoa,\" là biểu tượng của tình yêu và sự lãng mạn. Với vẻ đẹp kiêu sa và hương thơm quyến rũ, hoa hồng luôn chiếm vị trí đặc biệt trong trái tim của mọi người.  Đặc điểm của hoa hồng: Hình dáng: Hoa có nhiều lớp cánh xếp chồng, mềm mại và tỏa hương thơm ngát. Màu sắc: Đa dạng với các màu đỏ, hồng, trắng, vàng, cam, tím, đen, và xanh. Thân cây: Gai góc, mang ý nghĩa bảo vệ và vượt qua thử thách. Mùa nở: Hầu như quanh năm, nhưng đẹp nhất vào mùa xuân và mùa hè. Ý nghĩa của hoa hồng: Tình yêu: Hoa hồng đỏ tượng trưng cho tình yêu mãnh liệt và lãng mạn. Tình bạn và niềm vui: Hoa hồng vàng là biểu tượng của tình bạn, sự ấm áp. Sự thuần khiết: Hoa hồng trắng đại diện cho sự tinh khôi, chân thành. Lòng biết ơn: Hoa hồng hồng nhạt bày tỏ sự cảm kích và nhẹ nhàng. Sự bí ẩn: Hoa hồng tím tượng trưng cho sự mê hoặc và huyền bí. Ứng dụng: Trang trí: Hoa hồng được dùng phổ biến trong đám cưới, lễ kỷ niệm và trang trí nhà cửa. Quà tặng: Là món quà ý nghĩa dành cho người thân yêu trong các dịp đặc biệt. Chế biến: Hoa hồng còn được dùng trong ẩm thực và mỹ phẩm như trà hoa hồng, nước hoa, hoặc sản phẩm dưỡng da. Hoa hồng không chỉ là biểu tượng của tình yêu mà còn thể hiện sự đa dạng của cảm xúc, góp phần làm đẹp cuộc sống bằng hương sắc rực rỡ và ý nghĩa sâu sắc.', 150, 1);

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
