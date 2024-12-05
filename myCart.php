<?php
include 'header.php';
?>

<!-- Page Content -->
<div class="container">

    <div class="table-responsive py-5">
        <?php if (!empty($_SESSION['cart'])) : ?>
            <table
                class="table table-primary">
                <thead>
                    <tr>
                        <th style="width: 10%;" scope="col">Tên</th>
                        <th style="width: 10%;" scope="col"></th>
                        <th style="width: 10%;" scope="col">Loại</th>
                        <th style="width: 10%;" scope="col">Giá</th>
                        <th style="width: 10%;" scope="col">Số lượng</th>
                        <th style="width: 10%;" scope="col">
                            <a href="?clearCart" class="btn">Clear</a>
                        </th>
                    </tr>
                </thead>
                <tbody>

                    <?php
                    foreach ($_SESSION['cart'] as $productId => $quantity) :
                        $get_product = $products->getProductById($productId);
                        $get_cate = $categorys->getCategoryById($get_product['category'])['name'];

                    ?>
                        <tr>
                            <td scope="col"> <?php echo $get_product['name'] ?> </td>
                            <td scope="col">
                                <img style="width: 50px;" src="<?php echo $get_product['imagiUrl'] ?>" alt="<?php echo $get_product['name'] ?>">
                            </td>
                            <td scope="col"><?php echo $get_cate ?></td>

                            <td scope="col"><?php echo $get_product['price'] ?></td>
                            <td scope="col">
                                <form action="" method="post">
                                    <input type="hidden" name="id" value="<?php echo $get_product['id'] ?>">
                                    <input min="1" style="max-width: 50px;" type="number" value="<?php echo $quantity ?>" name="new_quantity" id="new_quantity">
                                    <input type="submit" name="submitCart" value="submit">
                                </form>
                            </td>

                            <td scope="col">
                                <a href="?remove_Cart=<?php echo $get_product['id'] ?>" class="btn">
                                    <i class="fa-solid fa-trash"></i>
                                </a>
                            </td>
                        </tr>
                    <?php
                    endforeach;
                    ?>

                </tbody>
                <thead>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th></th>
                    <th><a href="checkout.php" class="btn">Thanh Toán</a></th>
                </thead>
            </table>
        <?php else :
            echo "Giỏ hàng trống.";
        endif; ?>
    </div>
</div>
<!-- /.row -->
<?php
include 'footer.php';
?>