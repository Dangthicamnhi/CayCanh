<?php
@session_start();

include 'header.php';


// Kiểm tra trạng thái đăng nhập
if (!isset($_SESSION['account'])) {
    header("Location: login.php");
    exit();
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $product_id = ($_POST['product_id']);
    // echo $_SESSION['account']['id'] . "vao day";
    $user_id = ($_SESSION['account']);
    $user_name = Account::getAccount($user_id)['fullname'];
    $comment_content = htmlspecialchars($_POST['comment_content']);
    $createdate = date("Y-m-d H:i:s");

    // Chuẩn bị câu truy vấn
    $sql = "INSERT INTO comments (product_id, user_id, user_name, comment_content) 
                            VALUES ($product_id, $user_id, '$user_name', '$comment_content')";
    // Thực thi câu truy vấn
    if ($db->executeQuery($sql)) {
        echo " <script>
        location.href = 'ChiTietSanPham.php?id=$product_id';
        </script>";
        exit();
    } else {
        echo "Đã xảy ra lỗi khi thêm bình luận. Vui lòng thử lại sau.";
    }
}
