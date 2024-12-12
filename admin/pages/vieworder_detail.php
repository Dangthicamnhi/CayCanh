<?php include 'header.php';

if (isset($_SESSION["error"])) {
    echo "<script>alert('{$_SESSION['error']}');</script>";
    unset($_SESSION['error']);
}
if (isset($_SESSION["success"])) {
    echo "<script>alert('{$_SESSION['success']}');</script>";
    unset($_SESSION['success']);
}
if (isset($_SESSION["DelSS"])) {
    echo "<script>alert('{$_SESSION['DelSS']}');</script>";
    unset($_SESSION['DelSS']);
}
if (isset($_SESSION["DelErr"])) {
    echo "<script>alert('{$_SESSION['DelErr']}');</script>";
    unset($_SESSION['DelErr']);
}
?>
<div id="page-wrapper">
    <?php if (isset($_GET['id'])) {

        $id_order = $_GET['id'];
        if (isset($_POST['change_stt'])) {
            $id_status = $_POST['sttFilter'];
            if (Orders::changOrderStatus($id_order, $id_status)) {
                $_SESSION['success'] = "Thay đổi tình trạng thành công.";
            } else {
                $_SESSION['error'] = "Lỗi! Không thay đổi được tình trạng đơn hàng.";
            }
            echo " <script>
            location.href = 'vieworder_detail.php?id=$id_order';
            </script>";
            exit;
        }
        $order = Orders::getOrder_ByID_Admin($id_order);
        $order_detail = OrderDetail::getOrder_ByOrderId($id_order);
        if ($order) { ?>
            <h1>Thông tin đơn hàng</h1>
            <div class="mb-3">
                <div class="card">
                    <div class="card-body">
                        <h4 class="card-title">Ngày: <?php echo $order['createdate'] ?></h4>
                        <p class="card-text">Người nhận: <?php echo $order['fullname'] ?></p>
                        <p class="card-text">SDT: <?php echo $order['phone'] ?></p>
                        <p class="card-text">Địa chỉ: <?php echo $order['address'] ?></p>
                        <form action="" method="POST">
                            <div class="mb-3">
                                <label for="sttFilter" class="form-label">Tình trạng:</label>
                                <select name="sttFilter" id="sttFilter">
                                    <?php $sttOrder = STTOrder::getAllSTTOrder();
                                    $sttSelect = $order['sttOrder'];
                                    if (isset($_GET['stt'])) {
                                        $sttSelect = $_GET['stt'];
                                        echo '<option value="0">ALL</option>';
                                    } else {
                                        echo '<option value="0" selected >ALL</option>';
                                    }
                                    foreach ($sttOrder as $stt) { ?>
                                        <option value="<?php echo $stt['sttID'] ?>" <?php echo $stt['sttID'] == $sttSelect ? "selected" : "" ?>><?php echo $stt['sttName'] ?></option>
                                    <?php } ?>
                                </select>
                            </div>
                            <input type="submit" name="change_stt" class="btn btn-primary" value="Lưu">
                        </form>
                    </div>
                </div>
            </div>
            <div
                class="table-responsive">
                <table
                    class="table table-primary">
                    <thead>
                        <tr>
                            <th style="width: 25%;" scope="col">Sản phẩm</th>
                            <th style="width: 25%;" scope="col"></th>
                            <th style="width: 25%;" scope="col">Đơn giá</th>
                            <th style="width: 25%;" scope="col">Thành tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php $totalOrder = 0;
                        foreach ($order_detail as $value) :
                            $pro = Product::getProductById($value['id_product']);
                            $totalDetail = $value['price'] * $value['quantity'];
                            $totalOrder += $totalDetail; ?>
                            <tr class="">
                                <td> <img src="../../<?php echo $pro['imagiUrl'] ?>" style="width: 100px;" alt=""> </td>
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

    <?php }
    } ?>
</div>
<?php
include 'footer.php';
