<?php
class Account_info extends DataAccessHelper
{
    static function getAccountInfo($id)
    {
        $sql = self::$connection->prepare("SELECT * FROM account_info WHERE id_user = ? AND active = 1");
        $sql->bind_param("i", $id); // 'i' -> id là integer
        $sql->execute(); // Thực thi câu truy vấn

        $result = $sql->get_result();
        $info = $result->fetch_assoc(); // Lấy kết quả duy nhất
        return $info; // Trả về thông tin danh mục
    }
    static function getAccountAllInfoById($id)
    {
        $sql = self::$connection->prepare("SELECT * FROM account_info WHERE id_user = ? ORDER BY active DESC , createdate DESC");
        $sql->bind_param("i", $id); // 'i' -> id là integer
        $sql->execute(); // Thực thi câu truy vấn

        $result = array();
        $result = $sql->get_result()->fetch_all(MYSQLI_ASSOC);
        return $result; // Trả về thông tin danh mục
    }

    static function createAccountInfo($id_account, $phone, $address)
    {
        $sql = self::$connection->prepare("INSERT INTO account_info(phone, address, id_user) VALUES (?,?,?)");
        $sql->bind_param('ssi', $phone, $address, $id_account);
        return $sql->execute();
    }
    static function setDefaultAddress($userId, $addressId)
    {
        // Đặt tất cả các địa chỉ của user này không phải mặc định
        $sql =  self::$connection->prepare("UPDATE account_info SET active= 0 WHERE id_user = ?");
        $sql->bind_param("i", $userId);
        $sql->execute();
        $sql->close();

        // Đặt địa chỉ được chọn làm mặc định
        $sql = self::$connection->prepare("UPDATE account_info SET active= 1 WHERE id = ? AND id_user = ?");
        $sql->bind_param("ii", $addressId, $userId);
        $sql->execute();
        return $sql->close();
    }
}
