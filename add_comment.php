<?php
include 'header.php';

// Kiểm tra trạng thái đăng nhập
if (!isset($_SESSION['account'])) {
    header("Location: login.php");
    exit();
}

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $product_id = ($_POST['product_id']);
    echo $_SESSION['account']['id'] . "vao day";
    $user_id = ($_SESSION['account']['id']);
    $user_name = htmlspecialchars($_SESSION['account']['fullname']);
    $comment_content = htmlspecialchars($_POST['comment_content']);
    $createdate = date("Y-m-d H:i:s");

    // Chuẩn bị câu truy vấn
    $stmt = $conn->prepare("INSERT INTO comments (product_id, user_id, user_name, comment_content, createdate) 
                            VALUES (?, ?, ?, ?, ?)");
    $stmt->bind_param("iisss", $product_id, $user_id, $user_name, $comment_content, $createdate);

    // Thực thi câu truy vấn
    if ($stmt->execute()) {
        header("Location: sanpham.php?id=$product_id");
        exit();
    } else {
        echo "Đã xảy ra lỗi khi thêm bình luận. Vui lòng thử lại sau.";
    }
    $stmt->close();
}
