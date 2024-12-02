<?php
class Category extends DataAccessHelper
{
    function getAllCategory()
    {
        $sql = self::$connection->prepare("SELECT * FROM category");
        $sql->execute();
        $items = array();
        $items = $sql->get_result()->fetch_all(MYSQLI_ASSOC);
        return $items; //return an array
    }
    function getCategoryById($id)
    {
        $sql = self::$connection->prepare("SELECT * FROM category WHERE id = ?");
        $sql->bind_param("i", $id); // 'i' -> id là integer
        $sql->execute(); // Thực thi câu truy vấn

        $result = $sql->get_result();
        $category = $result->fetch_assoc(); // Lấy kết quả duy nhất

        $sql->close(); // Đóng statement
        return $category; // Trả về thông tin danh mục
    }
}
