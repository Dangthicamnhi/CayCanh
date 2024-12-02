<?php
include 'php/model_cart.php';

if (isset($_GET['add_cart'])) {
	if (isset($_SESSION['account']) || isset($_SESSION['customer'])) {
		$product_id = $_GET['add_cart'];
		$query = $db->executeQuery('SELECT p.* , activePrice(p.id) as price FROM product p WHERE id =' . $product_id);
		$pro = mysqli_fetch_assoc($query);
		if ($pro) {
			addToCart($product_id, 1);
		}
	} else {
		header("Location: admin/pages/login.html");
	}
}

if (isset($_GET['remove_Cart'])) {
	$product_id = $_GET['remove_Cart'];
	if ($products->getProductById($product_id)) {
		removeFromCart($product_id);
	}
}

if (isset($_GET['clearCart'])) {
	clearCart();
}
$count_cart = 0;
foreach ($_SESSION['cart'] as $product_id) {
	$count_cart++;
}
