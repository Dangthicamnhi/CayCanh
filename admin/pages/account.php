<?php
// include "../../php/connectDB.php";
// @session_start();
$fullname_ac = "admin";
$username_ac = "CamNhi";
if (isset($_POST["btn_submit"])) {

	$username = $_POST["email"];
	$password = $_POST["password"];

	$username = strip_tags($username);
	$username = addslashes($username);

	$sql = "select * from account where username = '$username'";
	$db = new DataAccessHelper;
	$db->connect();
	$query = $db->executeQuery($sql);
	$num_rows = mysqli_num_rows($query);
	echo $num_rows;
	if ($num_rows != 0) {
		$row = mysqli_fetch_assoc($query);
		if (password_verify($password, $row['passwords'])) {
			$id_ac = $row["id"];
			$username_ac = $row["username"];
			$fullname_ac = $row["fullname"];

			$_SESSION['account'] = $id_ac;
			if ($row["role"] == "admin") {
				header('Location: admin/pages/index.php');
			} else {
				header('Location: index.php');
			}
		}
	} else {
		header('Location: login.php');
	}
}
