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


if (isset($_POST["create_product"])) {
	$namepd = $_POST["name"];
	$pricepd = $_POST["price"];
	$saleoffpr = $_POST["saleoff"];
	$categorypr = $_POST["category"];
	$short_descripsionppr = $_POST["short_descripsion"];
	$inStockpr = $_POST["inStock"];
	$isAvailablepr = $_POST["isAvailable"];

	if (isset($_FILES['image']) && $_FILES['image']['error'] == 0) {
		$originName = basename($_FILES['image']['name']);
		$pathSave = "../../";
		$imageFileType = strtolower(pathinfo($originName, PATHINFO_EXTENSION));
		$newFileName = 'img/' . uniqid('product_', true) . '.' . $imageFileType;

		$move = $pathSave . $newFileName;
		$typeAccept = ['jpg', 'jpeg', 'png'];

		if (in_array($imageFileType, $typeAccept)) {
			if (move_uploaded_file($_FILES['image']['tmp_name'], $move)) {

				// Chuẩn bị và thực thi câu truy vấn SQL để thêm sản phẩm
				$sql = "INSERT INTO product( name, saleoff, category, imagiUrl, short_descripsion, inStock, isAvailable)
                        VALUES ('$namepd',$saleoffpr,$categorypr,'$newFileName','$short_descripsionppr',$inStockpr,$isAvailablepr)";

				if ($db->executeNonQuery($sql)) {
					$lastid = $db->lastIdInsert();
					$sql = "INSERT INTO pricelist(productID, price, startdate, enddate) VALUES ($lastid,$pricepd,now(),'2025-1-1');";
					$db->executeNonQuery($sql);
					$_SESSION["success"] = "Thêm thành công!";
				} else {
					$_SESSION["error"] = "Có lỗi trong quá trình thêm!";
				}
			} else {
				$_SESSION["error"] = "Thêm ảnh không thành công!";
			}
		} else {
			$_SESSION['error'] = "Yêu cầu file là ảnh!";
		}
	}
	header("Location: viewproduct.php");
	exit(); // Dùng exit sau khi chuyển hướng
}

if (isset($_POST['edit_product'])) {
	$id_product = $_GET["pro_edit_id"];
	$name = $_POST['name'];
	$price = $_POST['price'];
	$category = $_POST['category'];
	$saleoff = $_POST['saleoff'];

	$description = $_POST['short_descripsion']; //htmlspecialchars
	$stock = $_POST['inStock'];

	$pro_id = $_GET['pro_edit_id'];
	$query = $db->executeQuery('SELECT p.* , activePrice(p.id) as price FROM product p WHERE id =' . $id_product);
	$pro = mysqli_fetch_assoc($query);
	// Kiểm tra các trường bắt buộc
	if (empty($name) || empty($category) || empty($description)) {
		$_SESSION['error'] = "Vui lòng điền đầy đủ thông tin!";
		header("Location: Changeproduct.php?pro_edit_id=$id_product");
		exit();
	}

	// Kiểm tra giá trị số hợp lệ
	if (!is_numeric($price) || $price < 0) {
		$_SESSION['error'] = "Giá phải là một số dương hợp lệ!";
		header("Location: Changeproduct.php?pro_edit_id=$id_product");
		exit();
	}
	if (!is_numeric($stock) || $stock < 0) {
		$_SESSION['error'] = "Số lượng trong kho phải là số và không được nhỏ hơn 0!";
		header("Location: Changeproduct.php?pro_edit_id=$id_product");
		exit();
	}

	// Xử lý ảnh tải lên
	if (!empty($_FILES['image']['name'])) {
		$allowedFileTypes = ['image/jpeg', 'image/png', 'image/gif'];
		$maxFileSize = 5 * 1024 * 1024; // 5MB

		if (!in_array($_FILES['image']['type'], $allowedFileTypes)) {
			$_SESSION['error'] = "Vui lòng chọn ảnh có định dạng jpg, png hoặc gif!";
			header("Location: Changeproduct.php?pro_edit_id=$id_product");
			exit();
		}
		if ($_FILES['image']['size'] > $maxFileSize) {
			$_SESSION['error'] = "Ảnh tải lên không được vượt quá 5MB!";
			header("Location: Changeproduct.php?pro_edit_id=$id_product");
			exit();
		}
		$oldImagePath =  "../../" . $pro['imagiUrl'];

		$imagePath = 'img/' . uniqid('product_', true) . '.' . pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
		if (!move_uploaded_file($_FILES['image']['tmp_name'], "../../" . $imagePath)) {
			$_SESSION['error'] = "Có lỗi xảy ra khi tải ảnh lên!";
			header("Location: Changeproduct.php?pro_edit_id=$id_product");
			exit();
		}
		unlink($oldImagePath);
	} else {

		$sql = "SELECT p.*, activePrice(p.id) as price FROM product p WHERE id = $id_product";
		$query = $db->executeQuery($sql);
		$value = mysqli_fetch_assoc($query);
		$imagePath = $value['imagiUrl'];
	}

	// Cập nhật thông tin sản phẩm
	$updateQuery = "UPDATE product SET 

        name='$name', 
        category='$category', 
        saleoff='$saleoff', 
        imagiUrl='$imagePath', 
        short_descripsion='$description', 
        inStock='$stock' 
        WHERE id='$id_product'";

	if ($db->executeNonQuery($updateQuery)) {
		$startdate = date('Y-m-d'); // Ngày hiện tại
		$enddate = date('Y-m-d', strtotime('+1 year')); // Ngày hiện tại + 1 năm
		$sql = "INSERT INTO pricelist( productID, price, startdate, enddate) VALUES ($id_product,$price,now(),'$enddate')";
		if ($db->executeNonQuery($sql)) {
			$_SESSION['success'] = "Sản phẩm đã được cập nhật thành công!";
			header("Location: viewproduct.php");
			exit();
		} else {
			$_SESSION['error'] = "Có lỗi xảy ra khi thêm giá, vui lòng thử lại!";
			header("Location: Changeproduct.php?pro_edit_id=$id_product");
			exit();
		}
	} else {
		$_SESSION['error'] = "Có lỗi xảy ra, vui lòng thử lại!";
		header("Location: Changeproduct.php?pro_edit_id=$id_product");
		exit();
	}
}

if (isset($_POST["delete_product"])) {
	$id_product = $_POST["id_product"];
	$sql_price_product = "DELETE FROM pricelist WHERE productID = $id_product";
	$sql_product = "DELETE FROM product WHERE id = $id_product";

	if ($db->executeNonQuery($sql_price_product) && $db->executeNonQuery($sql_product)) {
		$_SESSION["DelSS"] = "Xóa thành công";
	} else {
		$_SESSION["DelErr"] = "Có lỗi trong quá trình xóa";
	}

	header("Location: viewproduct.php");
	exit(); // Dùng exit sau khi chuyển hướng
}

if (isset($_GET['pro_edit_id'])) {
	$pro_id = $_GET['pro_edit_id'];
	$query = $db->executeQuery('SELECT p.* , activePrice(p.id) as price FROM product p WHERE id =' . $pro_id);
	$result_pro = mysqli_fetch_assoc($query); ?>
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
			<nav class="navbar navbar-default navbar-static-top bg-dark" role="navigation" style="    margin-bottom: 0px">
				<div class="navbar-header.">

					<a class="navbar-brand" href="../../index.php">RainBow Garden</a>

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
									<input value="<?php echo $result_pro['name'] ?>" type="text" class="form-control" name="name" id="name" aria-describedby="helpId" placeholder="" />
								</div>
								<div class="mb-3">
									<label for="price" class="form-label">Price</label>
									<input value="<?php echo $result_pro['price'] ?>"
										type="text" class="form-control" name="price"
										id="price" aria-describedby="helpId" placeholder="" />
								</div>
								<div class="mb-3">
									<label for="category" class="form-label">Category</label>
									<select
										class="form-select form-select-lg"
										name="category"
										id="category">
										<option>Select one</option>
										<?php
										$query = $db->executeQuery("SELECT * FROM category");
										$result = mysqli_fetch_all($query, MYSQLI_ASSOC);

										?>
										<?php foreach ($result as $value) : ?>
											<option class="form-control" <?php echo $value['id'] == $result_pro['category'] ? 'selected' : '' ?>
												value="<?php echo $value['id'] ?>" style="text-transform: capitalize;">
												<?php echo $value['name'] ?></option>
										<?php endforeach; ?>
									</select>
								</div>
								<div class="mb-3">
									<label for="image" class="form-label">Image</label>
									<input
										type="file"
										class="form-control"
										name="image"
										id="image"
										placeholder=""
										aria-describedby="fileHelpId" accept="image/png, image/jpeg, image/jpg" />
									<div class="">
										<img style="width: 300px; height:300px" id="preview_img" src="../../<?php echo $result_pro['imagiUrl'] ?>" alt="<?php echo $result_pro['imagiUrl'] ?>" class="preview-img" />
									</div>
								</div>
								<script>
									const inputFile = document.querySelector('#image')
									const imagePreview = document.querySelector('#preview_img')

									inputFile.addEventListener('change', (e) => {
										if (e.target.files.length) {
											const src = URL.createObjectURL(e.target.files[0]);
											imagePreview.src = src;
										}
									});
								</script>

								<div class="mb-3">
									<label for="saleoff" class="form-label">Saleoff</label>
									<input value="<?php echo $result_pro['saleoff'] ?>" type="text" class="form-control" name="saleoff" id="saleoff" aria-describedby="helpId" placeholder="" />
								</div>
								<div class="mb-3">
									<label for="short_descripsion" class="form-label">Short Descripsion</label>
									<textarea class="form-control" name="short_descripsion" id="short_descripsion" rows="3"><?php echo $result_pro['short_descripsion'] ?></textarea>
								</div>

								<div class="mb-3">
									<label for="inStock" class="form-label">Stock</label>
									<input value="<?php echo $result_pro['inStock'] ?>" type="number" min="0" class="form-control" name="inStock" id="inStock" aria-describedby="helpId" placeholder="" />
								</div>
								<button
									type="submit" name="edit_product"
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
		<footer class="py-5 bg-dark">
			<div class="container">
				<p class="m-0 text-center text-white" style="color: #a1e6a1 !important">Rainbow Graden là nhóm các bạn trẻ năng động được thành lập từ môn Phát triển ứng dụng web. Với mới mong muốn mang đến cuộc sống nhiều màu xanh hơn. </p>
			</div>
			<!-- /.container -->

		</footer>
		<!-- /#wrapper -->

		<!-- jQuery -->
		<script src="../vendor/jquery/jquery.min.js"></script>

		<!-- Bootstrap Core JavaScript -->
		<script src="../vendor/bootstrap/js/bootstrap.min.js"></script>

		<!-- Metis Menu Plugin JavaScript -->
		<script src="../vendor/metisMenu/metisMenu.min.js"></script>

		<!-- Morris Charts JavaScript -->
		<script src="../vendor/raphael/raphael.min.js"></script>
		<script src="../vendor/morrisjs/morris.min.js"></script>
		<script src="../data/morris-data.js"></script>

		<!-- Custom Theme JavaScript -->
		<script src="../dist/js/sb-admin-2.js"></script>
		<script type="text/javascript">
			Morris.Bar({
				element: 'bar-tt',
				data: [{
						y: '2020',
						a: 100,
						b: 90
					},
					{
						y: '2021',
						a: 75,
						b: 65
					},
					{
						y: '2022',
						a: 50,
						b: 40
					},
					{
						y: '2023',
						a: 75,
						b: 65
					},
					{
						y: '2024',
						a: 50,
						b: 70
					}
				],
				xkey: 'y',
				ykeys: ['a', 'b'],
				labels: ['Series A', 'Series B']
			});
		</script>>
		<script type="text/javascript">
			Morris.Donut({
				element: 'morris-donut-chart',
				data: [
					<?php
					$sqlChar = "SELECT p.category, sum( d.quantity * p.price) tprice FROM cart_detail d JOIN product p ON d.id_product = p.id GROUP BY p.category ";
					$CharCart = $db->executeQuery($sqlChar);
					$i = 0;
					$ttMor[] = "100";
					$ttMor[] = "100";
					$ttMor[] = "100";
					/*while($row=mysqli_fetch_assoc($CharCart))
    {
       $ttMor[]=$row["tprice"];
   }*/
					?> {
						label: "Download Sales",
						value: 12
					},
					{
						label: "In-Store Sales",
						value: 30
					},
					{
						label: "Mail-Order Sales",
						value: 20
					}
				]
			});
		</script>
	</body>

	</html>


<?php }
