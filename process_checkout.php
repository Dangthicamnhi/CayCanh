<?php
@session_start();
include "php/connectDB.php";
include "php/model_oder.php";
include "php/model_oderdetail.php";
include "php/model_product.php";
$db = new DataAccessHelper();
$db->connect();

if (isset($_SESSION['account'])) {
    $user_id = $_SESSION['account'];
    if (isset($_POST['checkoutAccess'])) {
        if ($_SESSION['cart']) {
            $fullname = $_POST['name'];
            $phone = $_POST['phone'];
            $address = $_POST['address'];
            $oder_id = Orders::create_oder($fullname, $user_id, $phone, $address);
            if ($oder_id) {
                foreach ($_SESSION['cart'] as $product_id => $quantity) {
                    $get_product = Product::getProductById($product_id);
                    if ($get_product) {
                        echo $oder_id . "<br>";
                        echo $get_product['id'] . "<br>";
                        echo $quantity . "<br>";
                        echo $get_product['price'] . "<br>";
                        OrderDetail::insertOrder($oder_id, $get_product['id'], $quantity, $get_product['price']);
                    }
                }
                header("Location: hoadon.php?id=$oder_id");
                unset($_SESSION['cart']);
                exit;
            }
        } else {
            header("Location: login.php");
            exit;
        }
    }
    if (isset($_GET['cancel'])) {
        $id = $_GET['cancel'];
        $oder = Orders::getOrder_ByID($id);
        if ($oder['custom_id'] == $user_id) {
            if (Orders::cancelOrder($id)) {
                $_SESSION['success'] = "Đã hủy đơn hàng!";
            } else {
                $_SESSION['error'] = "Không thể thực hiện thao tác!";
            }
            header("Location: hoadon.php?id=$id");
            exit;
        } else {
            $_SESSION['error'] = "Không thể thực hiện thao tác!";
            header("Location: profile.php");
            exit;
        }
    }
} else {
    header("Location: login.php");
    exit;
}
