<?php
include 'header.php';
// Lấy thông tin tài khoản
$id = $_SESSION['account'];
$sql = "SELECT * FROM account WHERE id = '$id'";
$result = $db->executeQuery($sql);
$user = mysqli_fetch_assoc($result);
$user_info = Account_info::getAccountInfo($id);
?>

<div class="container" style="padding: 20px;">
    <h2 class="mt-4">Thông Tin Tài Khoản</h2>
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
    <a href="edit_profile.php" class="btn btn-primary">Chỉnh sửa thông tin</a>

    <a href="edit_address.php" class="btn btn-primary">Chỉnh sửa địa chỉ</a>
    <h2 class="mt-4">Lịch sử mua hàng</h2>
    <!-- xem dc don hang da mua, da huy -->
</div>
<?php
include 'footer.php';
