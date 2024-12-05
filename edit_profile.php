<?php
include 'header.php';

// Lấy thông tin tài khoản
$id = $_SESSION['account'];
$sql = "SELECT * FROM account WHERE id = '$id'";
$result = $db->executeQuery($sql);
$user = mysqli_fetch_assoc($result);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Xử lý cập nhật thông tin
    $fullname = $_POST['fullname'];
    $email = $_POST['username'];
    $password = $_POST['password'];
    $hashed_password = password_hash($password, PASSWORD_DEFAULT); // Mã hóa mật khẩu mới

    $update_sql = "UPDATE account SET fullname = '$fullname', username = '$email', passwords = '$hashed_password' WHERE id = '$id'";
    if ($db->executeNonQuery($update_sql)) {
        $_SESSION['success'] = "Cập nhật thông tin thành công!";
        echo " <script>
            location.href = 'profile.php';
        </script>";
        exit();
    } else {
        $_SESSION['error'] = "Cập nhật thất bại. Vui lòng thử lại.";
    }
}
?>

<div class="container">
    <h2 class="mt-4">Chỉnh Sửa Thông Tin</h2>
    <?php
    if (isset($_SESSION['success'])) {
        echo "<div class='alert alert-success'>" . $_SESSION['success'] . "</div>";
        unset($_SESSION['success']);
    }
    if (isset($_SESSION['error'])) {
        echo "<div class='alert alert-danger'>" . $_SESSION['error'] . "</div>";
        unset($_SESSION['error']);
    }
    ?>
    <form method="POST" action="" style="padding: 20px;">
        <div class="form-group">
            <label for="fullname">Họ và tên:</label>
            <input type="text" name="fullname" class="form-control" id="fullname" value="<?php echo htmlspecialchars($user['fullname']); ?>" required>
        </div>
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" name="username" class="form-control" id="email" value="<?php echo htmlspecialchars($user['username']); ?>" required>
        </div>
        <div class="form-group">
            <label for="password">Mật khẩu mới:</label>
            <input type="password" name="password" class="form-control" id="password" required>
        </div>
        <button type="submit" class="btn btn-primary">Cập nhật</button>
    </form>
    <a href="profile.php" class="btn btn-secondary mt-3">Quay lại</a>
</div>
<?php
include "footer.php";
