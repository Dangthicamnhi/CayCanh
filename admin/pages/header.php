<?php
@session_start();
include "../../php/connectDB.php";

if (!isset($_SESSION['account'])) {
    header('Location: ../../index.php');
}
$db = new DataAccessHelper;
$db->connect();
include "account.php";
$id_user = $_SESSION['account'];
$sql = "SELECT * FROM account WHERE id = '$id_user'";
$result = $db->executeQuery($sql);
$user = mysqli_fetch_assoc($result);

?>
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

                <a class="navbar-brand GreenBrand" href="../../index.php">RainBow Garden</a>

            </div>
            <!-- /.navbar-header -->

            <ul class="nav navbar-top-links navbar-right ">
                <li class="dropdown">

                    <a class="dropdown-toggle fn-bran-light" data-toggle="dropdown" href="#">
                        <?php echo $user['fullname'] ?>
                        <i class="fa fa-user fa-fw"></i> <i class="fa fa-caret-down"></i>
                    </a>
                    <ul class="dropdown-menu dropdown-user">
                        <li><a href="../../login.php"><i class="fa fa-sign-out fa-fw"></i>Logout</a>
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
                            <a href="viewuser.php"><i class="fa fa-table fa-fw"></i> Danh sách Người Dùng</a>
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