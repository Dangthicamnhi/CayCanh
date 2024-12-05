<?php
class Account extends DataAccessHelper
{
    static function getAccount($id)
    {
        $sql = self::$connection->prepare("SELECT * FROM account WHERE id = ?");
        $sql->bind_param("i", $id); // 'i' -> id là integer
        $sql->execute(); // Thực thi câu truy vấn

        $result = $sql->get_result();
        $user = $result->fetch_assoc(); // Lấy kết quả duy nhất
        return $user; // Trả về thông tin danh mục
    }
    static function isAdmin($id)
    {
        $sql = self::$connection->prepare("SELECT role FROM account WHERE id = ?");
        $sql->bind_param("i", $id); // 'i' -> id là integer
        $sql->execute(); // Thực thi câu truy vấn
        $result = $sql->get_result();
        $user = $result->fetch_assoc(); // Lấy kết quả duy nhất
        return $user['role'] === 'admin';
    }
}
