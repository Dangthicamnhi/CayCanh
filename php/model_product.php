<?php
class Product extends DataAccessHelper
{
    function getAllProduct()
    {
        $sql = self::$connection->prepare("SELECT p.* , activePrice(p.id) as price FROM product p ");
        $sql->execute();
        $items = array();
        $items = $sql->get_result()->fetch_all(MYSQLI_ASSOC);
        $sql->close(); // Đóng statement
        return $items; //return an array
    }
    // Lấy sản phẩm theo id
    function getProductById($id)
    {
        $sql = self::$connection->prepare("SELECT p.* , activePrice(p.id) as price FROM product p WHERE id = ?");
        $sql->bind_param("i", $id);
        $sql->execute();

        $result = $sql->get_result();
        $items = $result->fetch_assoc(); // Lấy kết quả duy nhất

        $sql->close();
        return $items;
    }
}