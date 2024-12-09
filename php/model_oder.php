<?php
class Orders extends DataAccessHelper
{
    // Lấy tất cả các đơn hàng
    static function getAllOrder()
    {
        // Chuẩn bị câu truy vấn để lấy tất cả các hàng từ bảng order
        $sql = self::$connection->prepare("SELECT * FROM `order`");
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
        $sql = self::$connection->prepare("SELECT * FROM `order` WHERE custom_id = ? ORDER BY createdate DESC ");
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
        $sql = self::$connection->prepare("SELECT * FROM `order` WHERE fullname = ?");
        $sql->bind_param('s', $fullname);
        $sql->execute();
        $result = $sql->get_result();
        $items = $result->fetch_assoc();
        return $items; // Trả về một mảng chứa các đơn hàng của khách hàng
    }
    // Lấy đơn hàng theo ID
    static function getOrder_ByID($id, $custom_id)
    {

        // Chuẩn bị câu truy vấn với tham số id
        $sql = self::$connection->prepare("SELECT * FROM `order` WHERE id = ? AND custom_id =?");
        $sql->bind_param('ii', $id, $custom_id);
        $sql->execute();
        $result = $sql->get_result();
        $items = $result->fetch_assoc();
        return $items; // Trả về một mảng chứa các đơn hàng của khách hàng
    }

    // Tạo đơn hàng mới với tên khách hàng và ID khách hàng
    static function create_oder($fullname, $custom_id, $phone, $address)
    {
        $createdate = date('Y-m-d H:i:s');
        // Chuẩn bị câu truy vấn để chèn dữ liệu vào bảng order
        $sql = self::$connection->prepare("INSERT INTO `order`(createdate, custom_id, fullname, phone, address) VALUES (?, ?, ?, ?, ?)");
        $sql->bind_param('sisss', $createdate, $custom_id, $fullname, $phone, $address);
        $sql->execute();
        return self::$connection->insert_id;
    }

    // hủy đơn hàng
    static function cancelOrder($orderId)
    {
        $sql = self::$connection->prepare("UPDATE `order` SET sttOrder = 5 WHERE id = ?");
        $sql->bind_param('i', $orderId);
        return $sql->execute(); // Thực thi truy vấn và trả về kết quả
    }
}
