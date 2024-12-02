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

if (!isset($_SESSION['account'])) {
    header('Location: ../../index.php');
    exit(); // Dùng exit sau khi chuyển hướng
}

if (isset($_POST["create_category"])) {
    $namect = $_POST["name"];
    if (isset($_FILES['image']) && $_FILES['image']['error'] == 0) {
        $originName = basename($_FILES['image']['name']);
        $pathSave = "../../";
        $imageFileType = strtolower(pathinfo($originName, PATHINFO_EXTENSION));
        $newFileName = 'img/' . uniqid('category_', true) . '.' . $imageFileType;

        $move = $pathSave . $newFileName;
        $typeAccept = ['jpg', 'jpeg', 'png'];

        if (in_array($imageFileType, $typeAccept)) {
            if (move_uploaded_file($_FILES['image']['tmp_name'], $move)) {

                // Chuẩn bị và thực thi câu truy vấn SQL để thêm loại sản phẩm
                $sql = "INSERT INTO category( name, image)
                        VALUES ('$namect', '$newFileName')";

                if ($db->executeNonQuery($sql)) {
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
    header("Location: viewcategory.php");
    exit(); // Dùng exit sau khi chuyển hướng
}

if (isset($_POST['edit_category'])) {
    $id_category = $_GET["cat_edit_id"];
    $name = $_POST['name'];

    $cat_id = $_GET['cat_edit_id'];
    //SELECT `id`, `name`, `image` FROM `category` WHERE 1
    $query = $db->executeQuery('SELECT id, name, image  FROM category c WHERE id =' . $id_category);
    $cat = mysqli_fetch_assoc($query);
    // Kiểm tra các trường bắt buộc
    if (empty($name)) {
        $_SESSION['error'] = "Vui lòng điền đầy đủ thông tin!";
        header("Location: Category.php?cat_edit_id=$id_category");
        exit();
    }

    // Xử lý ảnh tải lên
    if (!empty($_FILES['image']['name'])) {
        $allowedFileTypes = ['image/jpeg', 'image/png', 'image/gif'];
        $maxFileSize = 5 * 1024 * 1024; // 5MB

        if (!in_array($_FILES['image']['type'], $allowedFileTypes)) {
            $_SESSION['error'] = "Vui lòng chọn ảnh có định dạng jpg, png hoặc gif!";
            header("Location: Category.php?cat_edit_id=$id_category");
            exit();
        }
        if ($_FILES['image']['size'] > $maxFileSize) {
            $_SESSION['error'] = "Ảnh tải lên không được vượt quá 5MB!";
            header("Location: Category.php?cat_edit_id=$id_category");
            exit();
        }
        $oldImagePath =  "../../" . $cat['image'];

        $imagePath = 'img/' . uniqid('category_', true) . '.' . pathinfo($_FILES['image']['name'], PATHINFO_EXTENSION);
        if (!move_uploaded_file($_FILES['image']['tmp_name'], "../../" . $imagePath)) {
            $_SESSION['error'] = "Có lỗi xảy ra khi tải ảnh lên!";
            header("Location: Category.php?cat_edit_id=$id_category");
            exit();
        }
        unlink($oldImagePath);
    } else {

        $sql = "SELECT * FROM category WHERE id = $id_category";
        $query = $db->executeQuery($sql);
        $value = mysqli_fetch_assoc($query);
        $imagePath = $value['image'];
    }

    // Cập nhật thông tin sản phẩm
    $updateQuery = "UPDATE category SET 
        name ='$name', 
        image ='$imagePath'
        WHERE id = $id_category";


    if ($db->executeNonQuery($updateQuery)) {
        $_SESSION['success'] = "Loại Sản phẩm đã được cập nhật thành công!";
        header("Location: viewcategory.php");
        exit();
    } else {
        $_SESSION['error'] = "Có lỗi xảy ra, vui lòng thử lại!";
        header("Location: Category.php?cat_edit_id=$id_category");
        exit();
    }
}

if (isset($_POST["delete_category"])) {
    $id_category = $_POST["id_category"];
    // $sql_price_product = "DELETE FROM pricelist WHERE productID = $id_category";
    $sql_category = "DELETE FROM category WHERE id = $id_category";

    if ($db->executeNonQuery($sql_category)) {
        $_SESSION["DelSS"] = "Xóa thành công";
    } else {
        $_SESSION["DelErr"] = "Có lỗi trong quá trình xóa";
    }

    header("Location: viewcategory.php");
    exit(); // Dùng exit sau khi chuyển hướng
}

if (isset($_GET['cat_edit_id'])) {
    $cat_id = $_GET['cat_edit_id'];
    $query = $db->executeQuery('SELECT id, name, image  FROM category c WHERE id =' . $cat_id);
    $result_cat = mysqli_fetch_assoc($query); ?>
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
                            <?php
                            if ($_SESSION['fullname'])
                                echo $_SESSION['fullname'] ?>
                            <i class="fa fa-user fa-fw"></i> <i class="fa fa-caret-down"></i>
                        </a>
                        <ul class="dropdown-menu dropdown-user">
                            <li><a href="login.html"><i class="fa fa-sign-out fa-fw"></i> Logout</a>
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
                                    <input value="<?php echo $result_cat['name'] ?>" type="text" class="form-control" name="name" id="name" aria-describedby="helpId" placeholder="" />
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
                                        <img style="width: 300px; height:300px" id="preview_img" src="../../<?php echo $result_cat['image'] ?>" alt="<?php echo $result_cat['image'] ?>" class="preview-img" />
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


                                <button
                                    type="submit" name="edit_category"
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
                    $sqlChar = "SELECT p.category, sum( d.quantity * p.price) tprice FROM cart_detail d JOIN product p ON d.id_category = p.id GROUP BY p.category ";
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
