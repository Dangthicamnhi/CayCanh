<?php
include 'header.php';
if (isset($_POST['add_address'])) {
    $phone = $_POST['phone'];
    $address = $_POST['address'];
    if (!ctype_digit($phone)) {
        $error_phone = "Yêu cầu là số điện thoại!";
    } else {
        if ($id_new_info = Account_info::createAccountInfo($id_user, $phone, $address)) {

            if (isset($_POST['default_address'])) {
                Account_info::setDefaultAddress($id_user, $id_new_info);
            }
            echo " <script>
                location.href = 'edit_address.php';
            </script>";
        }
    }
}
if (isset($_POST['update_address'])) {
    $id = $_POST['update_address'];
    $phone = $_POST['phone'];
    $address = $_POST['address'];
    if (!ctype_digit($phone)) {
        $error_phone = "Yêu cầu là số điện thoại!";
    } else {
        if ($id_new_info = Account_info::updateAddress($id, $id_user, $phone, $address)) {
            echo " <script>
                location.href = 'edit_address.php';
            </script>";
        }
    }
}
if (isset($_GET['delete_address'])) {
    $id = $_GET['delete_address'];
    if (Account_info::deleteAddress($id, $id_user)) {
        $_SESSION['success'] = "Đã xóa địa chỉ.";
    } else {
        $_SESSION['error'] = "Không thể xóa địa chỉ";
    }
    echo " <script>
    location.href = 'edit_address.php';
</script>";
}
if (isset($_GET['default_address'])) {
    $id = $_GET['default_address'];
    if (Account_info::setDefaultAddress($id_user, $id)) {
        $_SESSION['success'] = "Đã chọn địa chỉ mặc định mới";
    } else {
        $_SESSION['error'] = "Lỗi địa chỉ";
    }
    echo " <script> location.href = 'edit_address.php'; </script>";
}
?>
<div class="container my-5">

    <?php if (isset($_GET['create_address'])) { ?>
        <h2>Thêm địa chỉ mới</h2>
        <form action="" method="post">
            <div class="mb-3">
                <label for="phone" class="form-label">Phone</label>
                <input type="text" class="form-control" name="phone" id="phone" aria-describedby="helpId" required />
                <?php if (isset($error_phone)) { ?>
                    <p class="form-text text-danger"><?php echo $error_phone ?></p>
                <?php } ?>

            </div>
            <div class="mb-3">
                <label for="address" class="form-label">Address</label>
                <textarea class="form-control" name="address" id="address" rows="3" required></textarea>
            </div>
            <div class="mb-3">
                <input class="" type="checkbox" name="default_address" value="default_address" id="default_address" />
                <label class="form-check-label" for="">Địa chỉ mặc định </label>
            </div>
            <button type="submit" class="btn btn-primary" name="add_address"> Submit </button>
        </form>
        <?php } else if (isset($_GET['edit_address'])) {
        $id_address = $_GET['edit_address'];
        $address = Account_info::getAccountInfoById($id_address, $id_user);
        if ($address) {
        ?>
            <h2>Chỉnh sửa địa chỉ</h2>
            <form action="" method="post">
                <div class="mb-3">
                    <label for="phone" class="form-label">Phone</label>
                    <input type="text" class="form-control" name="phone" id="phone" value="<?php echo $address['phone'] ?>" aria-describedby="helpId" required />
                    <?php if (isset($error_phone)) { ?>
                        <p class="form-text text-danger"><?php echo $error_phone ?></p>
                    <?php } ?>

                </div>
                <div class="mb-3">
                    <label for="address" class="form-label">Address</label>
                    <textarea class="form-control" name="address" id="address" rows="3" required><?php echo $address['address'] ?></textarea>
                </div>
                <div class="mb-3">
                    <input class="" type="checkbox" name="default_address" value="default_address" id="default_address" />
                    <label class="form-check-label" for="">Địa chỉ mặc định </label>
                </div>
                <button type="submit" class="btn btn-primary" value="<?php echo $address['id'] ?>" name="update_address"> Submit </button>
            </form>
        <?php } else { ?>
            <h2>Không tìm thấy</h2>
            <a href="edit_address.php" class="btn btn-primary">Chọn đối tượng khác</a>
        <?php        }
    } else {
        $list_address = Account_info::getAccountAllInfoById($id_user) ?>

        <div class="d-flex justify-content-between pb-3">
            <h2>Chọn địa chỉ mặc định</h2>
            <a href="?create_address" class="btn btn-primary">Thêm địa chỉ mới</a>
        </div>
        <?php foreach ($list_address as $value): ?>
            <div class="card">
                <div class="card-body">
                    <h4 class="card-title"><?php echo $value['address'] ?></h4>
                    <p class="card-text"><?php echo $value['phone'] ?></p>
                    <a href="?edit_address=<?php echo $value['id'] ?>" class="btn btn-primary">Chỉnh sửa</a>
                    <?php if ($value['active'] == 1) { ?>
                        <button type="button" class="btn btn-primary" disabled> Địa chỉ mặc định </button>
                    <?php } else { ?>

                        <a href="?default_address=<?php echo $value['id'] ?>" class="btn btn-primary"> Chọn địa chỉ làm mặc định </a>
                        <a href="?delete_address=<?php echo $value['id'] ?>" class="btn btn-danger">Xóa</a>
                    <?php } ?>
                </div>
            </div>

        <?php endforeach; ?>
    <?php } ?>
</div>
<?php
include "footer.php";
