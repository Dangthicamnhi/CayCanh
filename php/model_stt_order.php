<?php
class STTOrder extends DataAccessHelper
{
    static function getAllSTTOrder()
    {
        $sql = self::$connection->prepare("SELECT * FROM sttorder");
        $sql->execute();
        $items = array();
        $items = $sql->get_result()->fetch_all(MYSQLI_ASSOC);
        $sql->close(); // Đóng statement
        return $items; //return an array
    }
    static function getStartNormal()
    {
        $sql = self::$connection->prepare("SELECT * FROM sttorder where sttID != 5");
        $sql->execute();
        $items = array();
        $items = $sql->get_result()->fetch_all(MYSQLI_ASSOC);
        $sql->close(); // Đóng statement
        return $items; //return an array
    }
}
