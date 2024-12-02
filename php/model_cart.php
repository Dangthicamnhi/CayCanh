<?php
if (!isset($_SESSION['cart'])) {
    $_SESSION['cart'] = array();
}
function addToCart($productId, $quantity)
{
    // Kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
    if (isset($_SESSION['cart'][$productId])) {
        // Nếu có, tăng số lượng
        $_SESSION['cart'][$productId] += $quantity;
    } else {
        // Nếu chưa có, thêm mới
        $_SESSION['cart'][$productId] = $quantity;
    }
}
function updateCart($productId, $newQuantity)
{
    if (isset($_SESSION['cart'][$productId])) {
        if ($newQuantity > 0) {
            $_SESSION['cart'][$productId] = $newQuantity;
        } else {
            // Xóa sản phẩm khỏi giỏ nếu số lượng là 0
            unset($_SESSION['cart'][$productId]);
        }
    }
}
function removeFromCart($productId)
{
    if (isset($_SESSION['cart'][$productId])) {
        unset($_SESSION['cart'][$productId]);
    }
}
function clearCart()
{
    unset($_SESSION['cart']);
}
