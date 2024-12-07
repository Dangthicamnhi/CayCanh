<?php

include "../../php/connectDB.php";
@session_start();
if (!isset($_SESSION['account'])) {
	header('Location: ../../index.php');
}

if (isset($_SESSION["error"])) {
	echo "<script>alert('{$_SESSION['error']}');</script>";
	unset($_SESSION['error']);
}
if (isset($_SESSION["sussect"])) {
	echo "<script>alert('{$_SESSION['sussect']}');</script>";
	unset($_SESSION['sussect']);
}
if (isset($_SESSION["DelSS"])) {
	echo "<script>alert('{$_SESSION['DelSS']}');</script>";
	unset($_SESSION['DelSS']);
}
if (isset($_SESSION["DelErr"])) {
	echo "<script>alert('{$_SESSION['DelErr']}');</script>";
	unset($_SESSION['DelErr']);
}
// Đảm bảo đối tượng được khởi tạo đúng
$db = new DataAccessHelper();
$db->connect(); // Kiểm tra kết nối

include "account.php";
$id_user = $_SESSION['account'];
$sql = "SELECT * FROM account WHERE id = '$id_user'";
$result = $db->executeQuery($sql);
$user = mysqli_fetch_assoc($result);

if (!isset($_SESSION['account'])) {
	header('Location: ../../index.php');
	exit(); // Dùng exit sau khi chuyển hướng
}


if (isset($_POST["create_account"])) {
	$role = isset($_POST['role']) ? $_POST['role'] : null;  // Kiểm tra có tồn tại 'role' không
	$emali = $_POST['username'];
	$name = $_POST['fullname'];

	if (empty($name) || empty($emali) || is_null($role)) {
		echo "Vui lòng nhập đầy đủ thông tin!";
		return;
	}
	// Lưu tài khoản vào cơ sở dữ liệu
	$sql = "INSERT INTO account(role, username, fullname) VALUES ($role, '$emali', '$name')";
	if ($db->executeNonQuery($sql)) {
		$_SESSION["success"] = "Thêm thành công!";
	} else {
		$_SESSION["error"] = "Có lỗi trong quá trình thêm!";
	}
	echo "<script>location.href = 'viewuser.php';</script>";
	exit();
}

if (isset($_POST["delete_account"])) {
	$id_account = $_POST["id_account"];
	$sql_account = "DELETE FROM account WHERE id = $id_account";

	if ($db->executeNonQuery($sql_account)) {
		$_SESSION["DelSS"] = "Xóa thành công";
	} else {
		$_SESSION["DelErr"] = "Có lỗi trong quá trình xóa";
	}
	// header("Location: viewaccount.php");
	echo " <script>
            location.href = 'viewuser.php';
        </script>";
	exit(); // Dùng exit sau khi chuyển hướng
}

if (isset($_POST['edit_account'])) {
	$id_account = $_GET["acc_edit_id"];
	$role = isset($_POST['role']) ? $_POST['role'] : null;  // Kiểm tra có tồn tại 'role' không
	$email = $_POST['username'];
	$name = $_POST['fullname'];

	$acc_id = $_GET['acc_edit_id'];
	$query = $db->executeQuery("SELECT role, username, fullname FROM account WHERE id='$acc_id'");

	$pro = mysqli_fetch_assoc($query);
	// Kiểm tra các trường bắt buộc
	if (empty($name) || empty($email)) {
		$_SESSION['error'] = "Vui lòng điền đầy đủ thông tin!";
		header("Location: User.php?acc_edit_id=$id_account");
		exit();
	}
	// Cập nhật thông tin sản phẩm
	$updateQuery = "UPDATE account SET 

        fullname='$name', 
        username='$email', 
        role='$role'
        WHERE id='$id_account'";

	if ($db->executeNonQuery($updateQuery)) {

		$_SESSION['success'] = "Đã được cập nhật thành công!";
		echo "<script>location.href = 'viewuser.php';</script>";
		exit();
	} else {
		$_SESSION['error'] = "Có lỗi xảy ra, vui lòng thử lại!";
		header("Location: User.php?acc_edit_id=$id_account");
		exit();
	}
}



if (isset($_GET['acc_edit_id'])) {
	$acc_id = $_GET['acc_edit_id'];
	$query = $db->executeQuery('SELECT role, username, fullname FROM account WHERE id =' . $acc_id);
	$result_acc = mysqli_fetch_assoc($query); ?>
	<!DOCTYPE html>
	<html lang="en">

	<head>

		<meta charset="utf-8">
		<meta http-equiv="X-UA-Compatible" content="IE=edge">
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta name="description" content="">
		<meta name="author" content="">

		<title>Admin - RainbowGarden</title>
		<link rel="shortcut icon" href="../../img/logo.ico" />
		<!-- Bootstrap Core CSS -->
		<link href="../vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

		<!-- MetisMenu CSS -->
		<link href="../vendor/metisMenu/metisMenu.min.css" rel="stylesheet">

		<!-- Custom CSS -->
		<link href="../dist/css/sb-admin-2.css" rel="stylesheet">

		<!-- Morris Charts CSS -->
		<link href="../vendor/morrisjs/morris.css" rel="stylesheet">

		<!-- Custom Fonts -->
		<link href="../vendor/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">

		<link href="../css/customerad.css" rel="stylesheet" type="text/css">
		<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
		<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
		<!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

	</head>

	<body>
		<style type="text/css">
			a {
				color: #4b9249;
			}

			a:hover {
				color: #0f3a0e;
			}
		</style>

		<div id="wrapper">

			<!-- Navigation -->
			<nav class="navbar navbar-default navbar-static-top bg-dark" role="navigation" style="margin-bottom: 0px">
				<div class="navbar-header.">

					<a class="navbar-brand" href="../../index.php">Đến giao diện người dùng</a>

				</div>
				<!-- /.navbar-header -->

				<ul class="nav navbar-top-links navbar-right ">
					<li class="dropdown">
						<a class="dropdown-toggle fn-bran-light" data-toggle="dropdown" href="#">
							<?php echo $user['fullname'] ?>
							<i class="fa fa-user fa-fw"></i> <i class="fa fa-caret-down"></i>
						</a>
						<ul class="dropdown-menu dropdown-user">
							<li><a href="login.php"><i class="fa fa-sign-out fa-fw"></i> Logout</a>
							</li>
						</ul>
						<!-- /.dropdown-user -->
					</li>


				</ul>
				<!-- /.navbar-top-links -->

				<div class="navbar-default sidebar" role="navigation">
					<div class="sidebar-nav navbar-collapse">
						<ul class="nav" id="side-menu">
							<li class="sidebar-search">

								<!-- /input-group -->
							</li>
							<li>
								<a href="index.php"><i class="fa fa-dashboard fa-fw"></i> Bảng điều khiển</a>
							</li>

							<li>
								<a href="#"><i class="fa fa-bar-chart-o fa-fw"></i> Thống kê<span class="fa arrow"></span></a>
								<ul class="nav nav-second-level">
									<?php
									$query = $db->executeQuery("SELECT * FROM category");
									$result = mysqli_fetch_all($query, MYSQLI_ASSOC);

									?>
									<?php foreach ($result as $value) : ?>
										<li>
											<a href="thongke?category=<?php echo $value['id'] ?>"><?php echo $value['name'] ?></a>
										</li>
									<?php endforeach; ?>

								</ul>
								<!-- /.nav-second-level -->
							</li>
							<li>
								<a href="viewproduct.php"><i class="fa fa-table fa-fw"></i> Danh sách sản phẩm</a>
							</li>
							<li>
								<a href="viewcategory.php"><i class="fa fa-table fa-fw"></i> Danh sách Loại sản phẩm</a>
							</li>
							<li>
								<a href="viewuser.php"><i class="fa fa-table fa-fw"></i> Danh Người Dùng</a>
							</li>
							<li>
								<a href="Gopy.php"><i class="fa fa-comments fa-fw"></i> Góp ý từ khách hàng</a>
							</li>

						</ul>


						<!-- /.nav-second-level -->

					</div>
					<!-- /.sidebar-collapse -->
				</div>
				<!-- /.navbar-static-side -->
			</nav>

			<div id="page-wrapper">
				<div class="row">
					<div class="col-lg-12">
						<h1 class="page-header">Bảng điều khiển</h1>
					</div>
					<!-- /.col-lg-12 -->
				</div>
				<!-- /.row -->
				<div class="row">
					<div class="col-lg-3 col-md-6">
						<div class="container">
							<form action="" method="post" enctype="multipart/form-data">
								<div class="mb-3">
									<label for="name" class="form-label">Name</label>
									<input value="<?php echo $result_acc['fullname'] ?>"
										type="text" class="form-control" name="fullname"
										id="fullname" aria-describedby="helpId" placeholder="" />
								</div>
								<div class="mb-3">
									<label for="email" class="form-label">Email</label>
									<input value="<?php echo $result_acc['username'] ?>"
										type="email" class="form-control" name="username"
										id="username" aria-describedby="emailHelpId"
										placeholder="abc@gmail.com" />
								</div>
								<div class="mb-3">
									<label for="role" class="form-label">Vai Trò</label>
									<input value="<?php echo $result_acc['role'] ?>"
										type="text" class="form-control" name="role"
										id="role" aria-describedby="helpId" placeholder="" />
								</div>
								<button
									type="submit" name="edit_account"
									class="btn btn-primary">
									Submit
								</button>

							</form>
						</div>
					</div>


				</div>

			</div>
			<!-- /.row -->
		</div>
		<!-- /#page-wrapper -->

		</div>

		include ' footer.php ';


	<?php }
