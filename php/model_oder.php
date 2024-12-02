<?php
class Order extends DataAccessHelper
{
    // Lấy tất cả các đơn hàng
    static function getAllOrder()
    {
        // Chuẩn bị câu truy vấn để lấy tất cả các hàng từ bảng orders
        $sql = self::$connection->prepare("SELECT * FROM orders");
        $sql->execute();
        $items = array();
        // Lấy kết quả dưới dạng mảng kết hợp
        $items = $sql->get_result()->fetch_all(MYSQLI_ASSOC);
        return $items; // Trả về một mảng chứa tất cả các đơn hàng
    }

    // Lấy đơn hàng theo ID khách hàng
    static function getOrder_ByCustomerId($customerId)
    {
        // Chuẩn bị câu truy vấn với tham số customerId
        $sql = self::$connection->prepare("SELECT * FROM orders WHERE custom_id = ? ORDER BY createdate DESC ");
        $sql->bind_param('i', $customerId);
        $sql->execute();
        $items = array();
        // Lấy kết quả dưới dạng mảng kết hợp
        $items = $sql->get_result()->fetch_all(MYSQLI_ASSOC);
        return $items; // Trả về một mảng chứa các đơn hàng của khách hàng
    }
    // Lấy đơn hàng theo Full name
    static function getOrder_ByFullName($fullname)
    {
        // Chuẩn bị câu truy vấn với tham số fullname
        $sql = self::$connection->prepare("SELECT * FROM orders WHERE fullname = ?");
        $sql->bind_param('s', $fullname);
        $sql->execute();
        $result = $sql->get_result();
        $items = $result->fetch_assoc();
        return $items; // Trả về một mảng chứa các đơn hàng của khách hàng
    }
    // Lấy đơn hàng theo ID
    static function getOrder_ByID($id)
    {
        // Chuẩn bị câu truy vấn với tham số id
        $sql = self::$connection->prepare("SELECT * FROM orders WHERE id = ?");
        $sql->bind_param('s', $id);
        $sql->execute();
        $result = $sql->get_result();
        $items = $result->fetch_assoc();
        return $items; // Trả về một mảng chứa các đơn hàng của khách hàng
    }
    // Thêm đơn hàng mới với ID khách hàng
    static function insertOrder($customerid)
    {

        // Chuẩn bị câu truy vấn để chèn dữ liệu vào bảng orders
        $sql = self::$connection->prepare("INSERT INTO orders(custom_id) VALUES (?)");
        $sql->bind_param('i', $customerid);
        return $sql->execute(); // Thực thi truy vấn và trả về kết quả
    }

    // Tạo đơn hàng mới với tên khách hàng và ID khách hàng
    static function create_oder($fullname, $custom_id)
    {
        $createdate = date('Y-m-d H:i:s');
        // Chuẩn bị câu truy vấn để chèn dữ liệu vào bảng orders
        $sql = self::$connection->prepare("INSERT INTO orders(fullname, custom_id, createdate) VALUES (?, ?, ?)");
        $sql->bind_param('sis', $fullname, $custom_id, $createdate);
        return $sql->execute(); // Thực thi truy vấn và trả về kết quả
    }

    // Xóa đơn hàng theo ID khách hàng (phần này bị comment và có lỗi)
    // static function deleteOrderID($customerid)
    // {
    //     // Có lỗi cú pháp trong câu truy vấn DELETE
    //     // Cần sửa lại thành: DELETE FROM orders WHERE customerid = ?
    //     $sql = self::$connection->prepare("DELETE FROM orders WHERE id = ?");
    //     $sql->bind_param("i", $customerid);
    //     $sql->execute();
    // }
}
