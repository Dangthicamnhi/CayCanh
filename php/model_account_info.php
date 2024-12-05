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
    static function createAccountInfo($id_account, $phone, $address) {}
}
