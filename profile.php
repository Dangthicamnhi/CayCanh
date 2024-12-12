<?php
include 'header.php';
// Lấy thông tin tài khoản
$id = $_SESSION['account'];
$sql = "SELECT * FROM account WHERE id = '$id'";
$result = $db->executeQuery($sql);
$user = mysqli_fetch_assoc($result);
$user_info = Account_info::getAccountInfoActive($id_user);
?>

<div class="container" style="padding: 20px;">
    <h2 class="mt-4">Thông Tin Tài Khoản</h2>
    <?php if ($user && $user_info): ?>
        <table class="table table-bordered">
            <tr>
                <th>Họ và tên:</th>
                <td><?php echo htmlspecialchars($user['fullname']); ?></td>
            </tr>
            <tr>
                <th>Email:</th>
                <td><?php echo htmlspecialchars($user['username']); ?></td>
            </tr>
            <tr>
                <th>Số Điện Thoại:</th>
                <td><?php echo $user_info['phone'] ?></td>
            </tr>
            <tr>
                <th>Địa Chỉ:</th>
                <td><?php echo $user_info['address'] ?></td>
            </tr>
            <tr>
                <th>Vai trò:</th>
                <td><?php echo htmlspecialchars($user['role']); ?></td>
            </tr>
        </table>
    <?php else: ?>

        <table class="table table-bordered">
            <tr>
                <th>Họ và tên:</th>
                <td><?php echo htmlspecialchars($user['fullname']); ?></td>
            </tr>
            <tr>
                <th>Email:</th>
                <td><?php echo htmlspecialchars($user['username']); ?></td>
            </tr>
            <tr>
                <th>Số Điện Thoại:</th>
                <td><?php echo isset($user_info['phone']) ? ($user_info['phone']) : 'Không có dữ liệu'; ?></td>
            </tr>
            <tr>
                <th>Địa Chỉ:</th>
                <td><?php echo isset($user_info['address']) ? ($user_info['address']) : 'Không có dữ liệu'; ?></td>
            </tr>
            <tr>
                <th>Vai trò:</th>
                <td><?php echo htmlspecialchars($user['role']); ?></td>
            </tr>
        </table>
        <p>Vui lòng thêm Địa Chi Và Số Điện Thoại.</p>
    <?php endif; ?>

    <a href="edit_profile.php" class="btn btn-primary">Chỉnh sửa thông tin</a>

    <a href="edit_address.php" class="btn btn-primary">Chỉnh sửa địa chỉ</a>
    <h2 class="mt-4">Lịch sử mua hàng</h2>
    <!-- xem dc don hang da mua, da huy -->
    <?php $order_form_user = Orders::getOrder_ByCustomerId($id_user);
    if ($order_form_user) {
        foreach ($order_form_user as $value) { ?>
            <?php $getOderDetail = OrderDetail::getOrder_ByOrderId($value['id']);
            $totalOrder = 0;
            foreach ($getOderDetail as $value_detail) {
                $pro = Product::getProductById($value_detail['id_product']);
                $totalDetail = $value_detail['price'] * $value_detail['quantity'];
                $totalOrder += $totalDetail;
            }
            $stt = STTOrder::getSTTOrderById($value['sttOrder']); ?>
            <div class="card">
                <div class="card-body">
                    <h4 class="card-title"><a href="hoadon.php?id=<?php echo $value['id'] ?>">Ngày mua: <?php echo $value['createdate'] ?></a></h4>
                    <p><span>Tình trạng: </span><?php echo isset($stt['sttName']) ? $stt['sttName'] : "Chưa xác định"; ?></p>
                    <p class="card-text">Tổng giá: <?php echo number_format($totalOrder) ?> <span>VNĐ</span></p>
                </div>
            </div>
    <?php }
    } ?>
</div>
<?php
include 'footer.php';
