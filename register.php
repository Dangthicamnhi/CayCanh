<?php
include 'header.php';

if (isset($_POST["btn_register"])) {
    $fullname = $_POST["fullname"];
    $username = $_POST["email"];
    $password = $_POST["password"];
    $confirm_password = $_POST["confirm_password"];
    $role = "client"; // Mặc định tài khoản đăng ký là người dùng

    // Loại bỏ các ký tự không hợp lệ
    $fullname = strip_tags($fullname);
    $fullname = addslashes($fullname);
    $username = strip_tags($username);
    $username = addslashes($username);
    $password = strip_tags($password);
    $password = addslashes($password);
    $confirm_password = strip_tags($confirm_password);
    $confirm_password = addslashes($confirm_password);

    // Kiểm tra các trường dữ liệu có được nhập đầy đủ không
    if (empty($fullname) || empty($username) || empty($password) || empty($confirm_password)) {
        echo "Vui lòng nhập đầy đủ thông tin!";
        return;
    }

    // Kiểm tra mật khẩu khớp
    if ($password !== $confirm_password) {
        echo "Mật khẩu xác nhận không khớp!";
        return;
    }

    // Kiểm tra tài khoản đã tồn tại trong cơ sở dữ liệu
    $sql_check = "SELECT * FROM account WHERE username = '$username'";
    $query_check = $db->executeQuery($sql_check);
    if (mysqli_num_rows($query_check) > 0) {
        echo "Email đã được sử dụng. Vui lòng sử dụng email khác!";
        return;
    }

    // Mã hóa mật khẩu trước khi lưu
    $hashed_password = password_hash($password, PASSWORD_BCRYPT);

    // Lưu tài khoản vào cơ sở dữ liệu
    $sql_insert = "INSERT INTO account (fullname, username, passwords, role) VALUES ('$fullname', '$username', '$hashed_password', '$role')";
    if ($db->executeQuery($sql_insert)) {
        echo "Đăng ký tài khoản thành công!
         <script>
            location.href = 'index.php';
        </script>";
    } else {
        echo "Đăng ký tài khoản thất bại. Vui lòng thử lại!";
    }

    $db->close();
}
?>

<div class="container" style="padding: 50px;">
    <h2 class="text-center">Đăng ký tài khoản</h2>
    <form action="register.php" method="POST">
        <div class="form-group">
            <label for="fullname">Họ và tên:</label>
            <input type="text" class="form-control" id="fullname" name="fullname" required>
        </div>
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" class="form-control" id="email" name="email" required>
        </div>
        <div class="form-group">
            <label for="password">Mật khẩu:</label>
            <input type="password" class="form-control" id="password" name="password" required>
        </div>
        <div class="form-group">
            <label for="confirm_password">Xác nhận mật khẩu:</label>
            <input type="password" class="form-control" id="confirm_password" name="confirm_password" required>
        </div>
        <button type="submit" name="btn_register" class="btn btn-primary btn-block">Đăng ký</button>
    </form>
</div>
<?php
include 'footer.php';
?>