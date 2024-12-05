<?php
include 'header.php';

if (isset($_POST["btn_reset_password"])) {
    $username = $_POST["email"];
    $new_password = $_POST["new_password"];
    $confirm_password = $_POST["confirm_password"];

    // Loại bỏ các ký tự không hợp lệ
    $username = strip_tags($username);
    $username = addslashes($username);
    $new_password = strip_tags($new_password);
    $new_password = addslashes($new_password);
    $confirm_password = strip_tags($confirm_password);
    $confirm_password = addslashes($confirm_password);

    // Kiểm tra các trường dữ liệu có được nhập đầy đủ không
    if (empty($username) || empty($new_password) || empty($confirm_password)) {
        echo "Vui lòng nhập đầy đủ thông tin!";
        return;
    }

    // Kiểm tra mật khẩu khớp
    if ($new_password !== $confirm_password) {
        echo "Mật khẩu xác nhận không khớp!";
        return;
    }

    // Kiểm tra tài khoản có tồn tại hay không
    $sql_check = "SELECT * FROM account WHERE username = '$username'";
    $query_check = $db->executeQuery($sql_check);
    if (mysqli_num_rows($query_check) == 0) {
        echo "Email không tồn tại!";
        return;
    }

    // Mã hóa mật khẩu mới
    $hashed_password = password_hash($new_password, PASSWORD_BCRYPT);

    // Cập nhật mật khẩu
    $sql_update = "UPDATE account SET passwords = '$hashed_password' WHERE username = '$username'";
    if ($db->executeQuery($sql_update)) {
        echo "Đổi mật khẩu thành công!  <script>
            location.href = 'login.php';
        </script>";
    } else {
        echo "Đổi mật khẩu thất bại. Vui lòng thử lại!";
    }

    $db->close();
}
?>

<div class="container" style="padding: 50px;">
    <h2 class="text-center">Đổi mật khẩu</h2>
    <form action="reset_password.php" method="POST">
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" class="form-control" id="email" name="email" required>
        </div>
        <div class="form-group">
            <label for="new_password">Mật khẩu mới:</label>
            <input type="password" class="form-control" id="new_password" name="new_password" required>
        </div>
        <div class="form-group">
            <label for="confirm_password">Xác nhận mật khẩu:</label>
            <input type="password" class="form-control" id="confirm_password" name="confirm_password" required>
        </div>
        <button type="submit" name="btn_reset_password" class="btn btn-primary btn-block">Đổi mật khẩu</button>
    </form>
</div>
<?php
include 'footer.php';
