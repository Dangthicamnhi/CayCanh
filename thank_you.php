<?php

include 'header.php';
?>

<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f4f4f9;
        color: #333;
        text-align: center;
        margin: 0;
        padding: 0;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        box-sizing: border-box;
    }

    h1 {
        font-size: 2.5em;
        color: #4CAF50;
        margin-bottom: 20px;
    }

    p {
        font-size: 1.2em;
        margin-bottom: 30px;
        color: #555;
    }

    a {
        font-size: 1.1em;
        color: #fff;
        background-color: #4CAF50;
        padding: 12px 30px;
        text-decoration: none;
        border-radius: 5px;
        transition: background-color 0.3s ease;
    }

    a:hover {
        background-color: #45a049;
    }

    /* Responsive design */
    @media screen and (max-width: 600px) {
        h1 {
            font-size: 2em;
        }

        p {
            font-size: 1em;
        }

        a {
            font-size: 1em;
            padding: 10px 20px;
        }
    }
</style>

<?php
if (isset($_POST["send_feedback"])) {
    $name_fb = $_POST["name_fb"];
    $phone = $_POST["phone_fb"];
    $email = $_POST['email_fb'];
    $message = $_POST["message_fb"];
    if ($db->executeNonQuery("call sp_themFeedback('$name_fb','$phone','$email','$message')")) { ?>
        <h1>Cảm ơn bạn đã gửi phản hồi!</h1>
        <p>Chúng tôi sẽ phản hồi bạn sớm nhất có thể.</p>
        <a href="index.php">Quay lại trang chủ</a>
<?php } else {
        $_SESSION["success"] = "thêm thành công";
    }
}
?>

<?php
include 'footer.php';
?>