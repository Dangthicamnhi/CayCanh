<?php
session_start();
include "php/connectDB.php";
if (isset($_SESSION['account'])) {
    if ($_POST['checkoutAccess']) {
        if ($_SESSION['cart']) {
            echo "abc";
        }
    }
} else {
    header("Location: login.php");
}
