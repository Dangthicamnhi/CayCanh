<?php
include 'header.php';

$id = $_SESSION['account'];
$user = Account::getAccount($id);
$user_info = Account_info::getAccountInfoActive($id);
?>

<style>
    h2,
    h3 {
        color: #007bff;
        text-align: center;
        margin-bottom: 20px;
    }

    form label {
        display: block;
        font-weight: bold;
        margin-bottom: 5px;
    }


    input[type="text"],
    textarea {
        width: 100%;
        padding: 10px;
        border: 1px solid #ddd;
        border-radius: 4px;
        margin-bottom: 20px;
        font-size: 16px;
        box-sizing: border-box;
    }

    input[type="text"]:focus,
    textarea:focus {
        /* border-color: #007bff; */
        outline: none;
        box-shadow: 0 0 4px rgba(0, 123, 255, 0.3);
    }

    /* Bảng thông tin giỏ hàng */
    .table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 20px;
    }

    /* Định dạng tổng tiền và nút thanh toán */
    thead tr:last-child th {
        text-align: center;
        font-size: 16px;
        color: #007bff;
    }

    a.btn {
        display: inline-block;
        padding: 10px 20px;
        /* background-color: #007bff; */
        color: #fff;
        text-align: center;
        text-decoration: none;
        border-radius: 4px;
        font-weight: bold;
    }

    .mmm {
        text-align: center;
    }

    .mm-price-display {
        display: flex;
        justify-content: space-between;
    }
</style>
<header>
    <div id="carouselExampleIndicators" class="carousel slide" data-ride="carousel">
        <div class="carousel-inner" role="listbox">
            <div class="carousel-item active" style="background-image: url('img/bg-1.jpg')">
                <div class="carousel-caption d-none d-md-block">
                    <h1 style="text-shadow: 1px 1px 2px black">Kiểm tra giỏ hàng trước khi thanh toán.</h1>
                    <p>Đảm bảo mọi sản phẩm đều chính xác trước khi xác nhận đơn hàng.</p>
                </div>

            </div>

        </div>
</header>

<!-- Page Content -->
<div class="container">

    <!-- Page Content -->
    <div class="container">
        <?php
        if (!empty($_SESSION['cart'])) : ?>
            <div class="table-responsive py-5">
                <h2>Thông tin khách hàng</h2>
                <form action="process_checkout.php" method="POST">
                    <label for="name">Tên khách hàng:</label>
                    <input type="text" id="name" name="name" value="<?php echo $user['fullname'] ?>" required>
                    <br><br>
                    <label for="number">Số điện thoại:</label>
                    <input type="text" id="phone" name="phone" value="<?php echo $user_info ?  $user_info['phone'] : "" ?>" required>
                    <br><br>

                    <label for="address">Địa chỉ:</label>
                    <textarea id="address" name="address" rows="4" required><?php echo $user_info ?  $user_info['address'] : "" ?></textarea>
                    <br><br>

                    <h3>Thông tin giỏ hàng</h3>
                    <table class="table table-primary">
                        <div class="" id="product-list"></div>
                        <script>
                            // Lấy danh sách sản phẩm
                            var products = ProductManager.getAllProducts();

                            // Xuất danh sách ra màn hình
                            var productListDiv = document.getElementById("product-list");
                            products.forEach(function(product) {
                                var productItem = document.createElement("div");
                                productItem.innerHTML = `ID: ${product.id}, Name: ${product.name}, Price: $${product.price}`;
                                productListDiv.appendChild(productItem);
                            });
                        </script>
                        <?php
                        if (isset($_POST['submitCart'])) {
                            $id_p = $_POST['id'];
                            $new_quan = $_POST['new_quantity'];
                            updateCart($id_p, $new_quan);
                        }
                        ?>
                        <thead>
                            <tr>
                                <th>Tên SP</th>
                                <th></th>
                                <th>Loại</th>
                                <th>Đơn Giá</th>
                                <th>Số lượng</th>
                                <th>Giảm giá</th>
                                <th>Thành tiền</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $tongTien = 0;

                            foreach ($_SESSION['cart'] as $productId => $quantity) :
                                $get_product = Product::getProductById($productId);

                                if (!$get_product) {
                                    echo "<tr><td colspan='7'>Sản phẩm ID {$productId} không tồn tại.</td></tr>";
                                    continue;
                                }

                                $get_cate = Category::getCategoryById($get_product['category'])['name'] ?? 'Unknown';
                            ?>

                                <tr>
                                    <td scope="col"><?php echo htmlspecialchars($get_product['name'] ?? 'Không rõ'); ?></td>
                                    <td class="mmm" scope="col">
                                        <img style="width: 50px;" src="<?php echo htmlspecialchars($get_product['imagiUrl'] ?? 'default.png'); ?>" alt="<?php echo htmlspecialchars($get_product['name'] ?? 'No Image'); ?>">
                                    </td>
                                    <td class="mmm" scope="col"><?php echo htmlspecialchars($get_cate); ?></td>
                                    <td class="mmm mm-price-display" scope="col"><span><?php echo number_format($get_product['price'] ?? 0); ?></span> <span>Đồng</span> </td>
                                    <td class="mmm" scope="col"><?php echo (int) $quantity; ?></td>
                                    <td class="mmm" scope="col"><?php echo $get_product['saleoff'] ?? 0; ?>%</td>

                                    <?php
                                    $saleoff = ($get_product['price'] ?? 0) * ($get_product['saleoff'] ?? 0) / 100;
                                    $thanhTien = (($get_product['price'] ?? 0) * $quantity) - $saleoff;
                                    $tongTien += $thanhTien;
                                    ?>
                                    <td class="mmm" scope="col"><?php echo number_format($thanhTien); ?> Đồng</td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                        <thead>
                            <tr>
                                <th colspan="5">Tổng tiền :</th>
                                <th colspan="2"><?php echo number_format($tongTien); ?> Đồng</th>
                            </tr>
                            <tr>
                                <th colspan="7">
                                    <input type="submit" class="btn btn-primary" name="checkoutAccess" value="Thanh toán">
                                </th>
                            </tr>
                        </thead>

                    </table>
            </div>
        <?php else : ?>
            <tr>
                <td colspan="7">Giỏ hàng trống.</td>
            </tr>
        <?php endif; ?>

    </div>
    <!-- /.container -->
</div>
<?php
include 'footer.php';
?>