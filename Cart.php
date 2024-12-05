<?php
include 'php/model_cart.php';

if (isset($_GET['add_cart'])) {
	if (isset($_SESSION['account'])) {
		$product_id = $_GET['add_cart'];
		$query = $db->executeQuery('SELECT p.* , activePrice(p.id) as price FROM product p WHERE id =' . $product_id);
		$pro = mysqli_fetch_assoc($query);
		if ($pro) {
			addToCart($product_id, 1);
		}
	} else {
		header("Location: login.php");
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
if (isset($_SESSION['cart'])) {
	foreach ($_SESSION['cart'] as $product_id) {
		$count_cart++;
	}
}
