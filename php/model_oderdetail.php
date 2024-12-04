<?php
class OrderDetail extends DataAccessHelper
{
    // Lấy tất cả các chi tiết đơn hàng
    static function getAllOrder()
    {
        // Chuẩn bị câu truy vấn để lấy tất cả các hàng từ bảng orders_detail
        $sql = self::$connection->prepare("SELECT * FROM orders_detail");
        $sql->execute();
        $items = array();
        // Lấy kết quả dưới dạng mảng kết hợp
        $items = $sql->get_result()->fetch_all(MYSQLI_ASSOC);
        return $items; // Trả về một mảng chứa các chi tiết đơn hàng
    }

    // Lấy chi tiết đơn hàng theo ID đơn hàng
    static function getOrder_ByOrderId($orderId)
    {
        // Chuẩn bị câu truy vấn với tham số orderId
        $sql = self::$connection->prepare("SELECT * FROM orders_detail WHERE id_orders = ?");
        $sql->bind_param('i', $orderId);
        $sql->execute();
        $items = array();
        // Lấy kết quả dưới dạng mảng kết hợp
        $items = $sql->get_result()->fetch_all(MYSQLI_ASSOC);
        return $items; // Trả về một mảng chứa các chi tiết đơn hàng theo ID
    }

    // Lấy chi tiết đơn hàng theo ID sản phẩm và ID đơn hàng
    static function getOrder_Product($id_product, $orderId)
    {
        // Chuẩn bị câu truy vấn với tham số id_product  và orderId
        $sql = self::$connection->prepare("SELECT * FROM orders_detail WHERE id_product  = ? AND id_orders = ?");
        $sql->bind_param('ii', $id_product, $orderId);
        $sql->execute();
        $items = array();
        // Lấy kết quả dưới dạng mảng kết hợp
        $items = $sql->get_result()->fetch_all(MYSQLI_ASSOC);
        return $items; // Trả về một mảng chứa các chi tiết đơn hàng theo sản phẩm và ID đơn hàng
    }

    // Thêm chi tiết đơn hàng mới
    static function insertOrder($orderId, $id_product, $quantity, $price)
    {
        // Chuẩn bị câu truy vấn để chèn dữ liệu vào bảng orders_detail
        $sql = self::$connection->prepare("INSERT INTO orders_detail(id_orders, id_product , quantity, price) VALUES (?,?,?,?)");
        $sql->bind_param('iiii', $orderId, $id_product, $quantity, $price);
        return $sql->execute(); // Thực thi truy vấn và trả về kết quả
    }

    // Cập nhật chi tiết giỏ hàng (số lượng và giá) theo ID đơn hàng và sản phẩm
    static function updateCart($orderId, $id_product, $quantity, $price)
    {
        // Chuẩn bị câu truy vấn để cập nhật bảng orders_detail
        $sql = self::$connection->prepare("UPDATE orders_detail SET quantity = $quantity, price = $price WHERE id_product  = $id_product  AND id_orders = $orderId");
        return $sql->execute(); // Thực thi truy vấn và trả về kết quả
    }

    // Xóa sản phẩm khỏi đơn hàng theo ID sản phẩm và ID đơn hàng
    static function removeProduct_ById($orderId, $id_product)
    {
        // Chuẩn bị câu truy vấn để xóa sản phẩm khỏi bảng orders_detail
        $sql = self::$connection->prepare("DELETE FROM orders_detail WHERE id_product  = $id_product  AND id_orders = $orderId");
        return $sql->execute(); // Thực thi truy vấn và trả về kết quả
    }

    // Xóa tất cả chi tiết đơn hàng theo ID đơn hàng
    static function removeAll_ByOrderId($orderId)
    {
        // Chuẩn bị câu truy vấn để xóa tất cả các chi tiết thuộc đơn hàng cụ thể
        $sql = self::$connection->prepare("DELETE FROM orders_detail WHERE id_orders = $orderId");
        return $sql->execute(); // Thực thi truy vấn và trả về kết quả
    }

    // Xóa tất cả các chi tiết đơn hàng
    static function removeAll()
    {
        // Chuẩn bị câu truy vấn để xóa tất cả các chi tiết đơn hàng
        $sql = self::$connection->prepare("DELETE FROM orders_detail");
        return $sql->execute(); // Thực thi truy vấn và trả về kết quả
    }
}