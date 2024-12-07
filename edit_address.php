<?php
include 'header.php';
if (isset($_POST['add_address'])) {
    $phone = $_POST['phone'];
    $address = $_POST['address'];
    $default_address = 0;
    if (isset($_POST['default_address'])) {
        $default_address = 1;
    }
    if (!ctype_digit($phone)) {
        $error_phone = "Yêu cầu là số điện thoại!";
    } else {
        if (Account_info::createAccountInfo($id_user, $phone, $address)) {
            echo " <script>
            location.href = 'profile.php';
        </script>";
        }
    }
} ?>

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
    <?php } else {
        $list_address = Account_info::getAccountAllInfoById($id_user) ?>
        <h2>Chọn địa chỉ mặc định</h2>
        <?php foreach ($list_address as $value): ?>
            <div class="card">
                <div class="card-body">
                    <h4 class="card-title"><?php echo $value['address'] ?></h4>
                    <p class="card-text"><?php echo $value['phone'] ?></p>
                    <a href="?create_address" class="btn btn-primary">Chỉnh sửa</a>
                    <?php if ($value['active'] == 1) { ?>
                        <button type="button" class="btn btn-primary" disabled> Địa chỉ mặc định </button>
                    <?php } else { ?>

                        <a href="" class="btn btn-primary"> Chọn địa chỉ làm mặc định </a>
                        <a href="" class="btn btn-danger">Xóa</a>
                    <?php } ?>
                </div>
            </div>

        <?php endforeach; ?>
    <?php } ?>
</div>
<?php
include "footer.php";
