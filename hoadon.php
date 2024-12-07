<?php
include 'header.php';
?>
<!-- tinh trang hd
 Chờ xác nhận -> dc phép hủy
 đang vận chuyển
 đang giao hàng
 đã giao hàng -->
<?php if (isset($_GET['id'])) {
    $idOrder = $_GET['id'];
    $order = Orders::getOrder_ByID($idOrder);
    $id_user = $_SESSION['account'];
    if ($order['custom_id'] != $id_user) {
        echo " <script>
            location.href = 'profile.php';
        </script>";
    }
    $STTOrders = STTOrder::getStartNormal();
?>
    <div class="container py-5">
        <?php if (isset($_SESSION['success'])) {
            $success = $_SESSION['success'];
            unset($_SESSION['success']); ?>
            <div class="alert alert-warning" role="alert"><?php echo $success ?> </div>
        <?php } ?>
        <?php if (isset($_SESSION['error'])) {
            $error = $_SESSION['error'];
            unset($_SESSION['error']); ?>
            <div class="alert alert-warning" role="alert"><?php echo $error ?> </div>
        <?php } ?>
        <?php if ($order['sttOrder'] != 5) { ?>
            <div class="row justify-content-center align-items-center g-2 py-3">
                <?php foreach ($STTOrders as $stt): ?>
                    <div <?php echo $order['sttOrder'] >= $stt['sttID'] ? 'style="color: green;"' :  "" ?>class="col text-center"><?php echo $stt['sttName'] ?></div>
                <?php endforeach ?>
            </div>
        <?php } else { ?>
            <div class="text-center text-danger">Đơn hàng đã hủy</div>
        <?php } ?>
        <div class=" row justify-content-center ">
            <div class="col-4">
                <div
                    class="card border-primary">
                    <div class="card-body">
                        <h4 class="card-title">Thông tin người nhận</h4>
                        <p class="card-text">
                            <label>Tên người nhận: </label> <?php echo $order['fullname'] ?>
                        </p>
                        <p class="card-text">
                            <label>Số ĐT: </label> <?php echo $order['phone'] ?>
                        </p>
                        <p class="card-text">
                            <label>Địa chỉ: </label> <?php echo $order['address'] ?>
                        </p>
                        <?php if ($order['sttOrder'] == 1) { ?>
                            <a href="process_checkout.php?cancel=<?php echo $order['id'] ?>" onclick="alertDeleter()" type="button" class="btn btn-danger">Hủy đơn hàng</a>
                        <?php } ?>

                        <script>
                            function alertDeleter() {
                                confirm("Bạn có muốn hủy đơn hàng?");
                            }
                        </script>

                    </div>
                </div>

            </div>
            <div class="col-8">
                <div
                    class="card border-primary">
                    <div class="card-body">
                        <h4 class="card-title">Sản phẩm đơn hàng</h4>
                        <div
                            class="table-responsive">
                            <table class="table ">
                                <thead>
                                    <tr>
                                        <th style="width: 25%;" scope="col">Sản phẩm</th>
                                        <th style="width: 25%;" scope="col"></th>
                                        <th style="width: 25%;" scope="col">Đơn giá</th>
                                        <th style="width: 25%;" scope="col">Thành tiền</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <?php $getOderDetail = OrderDetail::getOrder_ByOrderId($order['id']);
                                    $totalOrder = 0;
                                    foreach ($getOderDetail as $value) :
                                        $pro = Product::getProductById($value['id_product']);
                                        $totalDetail = $value['price'] * $value['quantity'];
                                        $totalOrder += $totalDetail; ?>
                                        <tr class="">
                                            <td> <img src="<?php echo $pro['imagiUrl'] ?>" style="width: 100%;" alt=""> </td>
                                            <td>
                                                <a href=""> <?php echo $pro['name'] ?>
                                                    <span>x<?php echo $value['quantity'] ?></span>
                                                </a>
                                            </td>
                                            <td><?php echo number_format($value['price'], 0) ?> <span>VNĐ</span></td>
                                            <td><?php echo number_format($totalDetail, 0) ?> <span>VNĐ</span></td>
                                        </tr>
                                    <?php endforeach ?>

                                </tbody>
                                <thead>
                                    <tr>
                                        <th style="width: 25%;" scope="col"></th>
                                        <th style="width: 25%;" scope="col"></th>
                                        <th style="width: 25%;" scope="col">Tổng tiền: </th>
                                        <th style="width: 25%;" scope="col"><?php echo number_format($totalOrder, 0) ?> <span>VNĐ</span></th>
                                    </tr>
                                </thead>
                            </table>
                        </div>


                    </div>
                </div>

            </div>
        </div>
    </div>
<?php } ?>
<?php
include 'footer.php';
?>