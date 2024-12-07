<?php
@session_start();
include "php/connectDB.php";
include "php/model_category.php";
include "php/model_product.php";
include "php/model_oder.php";
include "php/model_oderdetail.php";
include 'php/model_account.php';
include 'php/model_account_info.php';
include 'php/model_stt_order.php';
$db = new DataAccessHelper;
$db->connect();
include "admin/pages/account.php";

include('Cart.php');
if (isset($_SESSION['account'])) {
    json_encode(["status" => "success", "message" => "User is logged in"]);
} else {
    json_encode(["status" => "error", "message" => "User is not logged in"]);
}
if (isset($_POST['submitCart'])) {
    $id_p = $_POST['id'];
    $new_quan = $_POST['new_quantity'];
    updateCart($id_p, $new_quan);
    // Redirect để tránh việc nộp lại form
    header("Location: " . $_SERVER['PHP_SELF']);
    exit;
}
?>
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Rainbow Garden</title>
    <link rel="shortcut icon" href="img/logo.ico" />
    <!-- Bootstrap core CSS -->
    <link href="vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom styles for this template -->
    <link href="css/modern-business.css" rel="stylesheet">
    <link href="css/icon-fonts.min.css" rel="stylesheet">

    <link href="css/settings.css" rel="stylesheet">
    <link href="css/grid-and-effects.css" rel="stylesheet">
    <link href="css/custom.css" rel="stylesheet">
    <link href="css/styles.css" rel="stylesheet">


    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.1/css/all.min.css">


    <style>
        #pg-4680-1,
        #pl-4680 .panel-grid-cell .so-panel:last-child {
            margin-bottom: 0px;

        }

        a {
            color: #4b9249;

        }

        a:hover {
            color: #a1e6a1 !important;
        }
    </style>

</head>

<body>

    <!-- Navigation -->
    <nav class="navbar fixed-top navbar-expand-lg navbar-dark bg-dark fixed-top">
        <div class="container">
            <a class="navbar-brand GreenBrand" href="index.php"><img src="img/logobn.png">RainBow Garden</a>
            <button class="navbar-toggler navbar-toggler-right" type="button" data-toggle="collapse" data-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarResponsive">
                <ul class="navbar-nav ml-auto">
                    <?php
                    $query = $db->executeQuery("SELECT * FROM category");
                    $result = mysqli_fetch_all($query, MYSQLI_ASSOC);
                    ?>
                    <?php foreach ($result as $value) : ?>
                        <li class="nav-item">
                            <a class="nav-link" href="loaicay?category=<?php echo $value['id'] ?>"><?php echo $value['name'] ?></a>
                        </li>
                    <?php endforeach; ?>

                    <li>
                        <form class="input-with-submit header-search" method="GET">
                            <div class="input-group">
                                <input type="text" class="form-control" placeholder="Tìm thứ gì đó?" name="tukhoa">
                                <span class="input-group-button">
                                    <button class="btn btn-default" style="background-color: #4b9249" type="submit">
                                        <i class="fa fa-search"></i>
                                    </button>

                                </span>
                            </div>
                        </form>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link" href="lienhe.php">
                            Liên hệ
                        </a>
                    </li>
                    <li style="width: 40px !important; height: 40px; padding-left: 3px;">
                        <span class="my-cart-icon">
                            <span class=" navRbcart">
                                <a href="myCart.php">
                                    <i class="fa fa-shopping-cart shopping_bg add-to-cart my-cart-btn" id="MyCartbn"
                                        aria-hidden="true"></i>
                                </a>
                            </span>
                            <span class="badge badge-notify my-cart-badge"><?php echo $count_cart ?></span>
                        </span>
                    </li>

                    <li class="dropdown navRbaccount">
                        <a class=" fn-bran-light" data-toggle="dropdown" href="#">
                            <i class="fa fa-user fa-fw"></i> <i class="fa fa-caret-down"></i>
                        </a>
                        <ul class="dropdown-menu dropdown-user">
                            <?php
                            if (!isset($_SESSION['account'])) {
                            ?>
                                <li><a href="login.php"><i class="fa fa-sign-in fa-fw"></i> Đăng nhập</a>
                                </li>
                                <li><a href="register.php"><i class="fa fa-user fa-fw"></i> Tạo tài khoản</a>
                                </li>

                            <?php
                            }
                            if (isset($_SESSION['account'])) {
                                $id_user = $_SESSION['account']
                            ?>
                                <li><a href="profile.php"><i class="fa fa-user fa-fw"></i> Tài khoản</a>
                                </li>
                                <?php
                                if (Account::isAdmin($id_user)) {
                                ?>
                                    <li><a href="admin/pages/index.php"><i class="fa fa-gear fa-fw"></i> Đến trang admin</a>
                                    </li>
                                <?php
                                }
                                ?>
                                <li class="divider"></li>
                                <li><a href="php/logout.php"><i class="fa fa-sign-out fa-fw"></i> Đăng xuất</a>
                                </li>
                            <?php
                            } ?>

                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>