<?php
include 'header.php';

if (isset($_SESSION["error"])) {
    echo "<script>alert('{$_SESSION['error']}');</script>";
    unset($_SESSION['error']);
}
if (isset($_SESSION["sussect"])) {
    echo "<script>alert('{$_SESSION['sussect']}');</script>";
    unset($_SESSION['sussect']);
}
if (isset($_SESSION["DelSS"])) {
    echo "<script>alert('{$_SESSION['DelSS']}');</script>";
    unset($_SESSION['DelSS']);
}
if (isset($_SESSION["DelErr"])) {
    echo "<script>alert('{$_SESSION['DelErr']}');</script>";
    unset($_SESSION['DelErr']);
}
?>


<div id="page-wrapper">

    <!-- /.row -->
    <div class="row">
        <br>
        <div class="col-lg-12">
            <div class="panel panel-default">
                <div class="panel-heading">
                    <div class="row">
                        <div class="col-lg-8">
                            Danh Người Dùng
                        </div>
                        <div class="col-lg-4" style="text-align: right">
                            <button type="button" class="btnaddaccount btn btn-outline btn-success" data-toggle="collapse" href="#collapseOne">Thêm Người Dùng</button>
                            <button type="button" class=" btnaddaccount btn btn-outline btn-success" data-toggle="collapse" href="#collapseTwo">Xóa Người Dùng</button>
                        </div>
                    </div>
                </div>

                <div id="collapseOne" class="panel-collapse collapse">

                    <h4 style="color: #4b9249; padding-left: 30px;">Thêm Người Dùng</h4>

                    <form action="User.php" method="POST" enctype="multipart/form-data">
                        <div class="panel-body">
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Họ Tên" name="fullname"
                                    required data-validation-required-message="Please enter your name address.">
                            </div>
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Email" name="username"
                                    required data-validation-required-message="Please enter your email address.">
                            </div>

                            <div class="form-group col-lg-4">
                                <select class="form-control" name="role">
                                    <option value="1">User</option>
                                    <option value="0">Admin</option>
                                </select>
                            </div>
                            <div class="form-group col-lg-4">

                                <input type="submit" class=" btn btn-outline btn-success"
                                    style="width: 100%" name="create_account" value="Xác nhận">

                            </div>

                        </div>
                    </form>
                </div>

                <div id="collapseTwo" class="panel-collapse collapse">
                    <h4 style="color: #4b9249; padding-left: 30px;">Xóa Người Dùng</h4>
                    <form action="User.php" method="POST">
                        <div class="panel-body">
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Mã Người Dùng" name="id_account"
                                    required data-validation-required-message="Please enter your email address.">
                            </div>

                            <div class="form-group col-lg-4">
                                <input type="submit" class="btn btn-outline btn-success"
                                    style="width: 100%" name="delete_account" value="Xác nhận">
                            </div>
                        </div>
                    </form>
                </div>

                <?php

                ?>
                <!-- /.panel-heading -->
                <div class="panel-body">
                    <table width="100%" class="table table-striped table-bordered table-hover" id="dataTables-example">
                        <thead>
                            <tr>
                                <th>Mã Người Dùng</th>
                                <th>Tên Người Dùng</th>
                                <th>Email</th>
                                <th>Vai Trò</th>
                                <th>Sửa</th>


                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $sql = "SELECT * FROM `account` WHERE id";
                            $query = $db->executeQuery($sql);
                            while ($row = mysqli_fetch_assoc($query)) {

                            ?>
                                <tr class="odd gradeX">
                                    <td><?php echo $row['id'] ?></td>
                                    <td><?php echo $row['fullname'] ?> </td>
                                    <td><?php echo $row['username'] ?> </td>
                                    <td><?php echo $row['role'] ?></td>
                                    <td><a href="User.php?acc_edit_id=<?php echo $row['id']; ?>" class="btn btn-outline btn-warning edit-account">Sửa</a></td>

                                </tr>
                            <?php
                            }
                            ?>

                        </tbody>
                    </table>
                    <!-- /.table-responsive -->

                </div>
                <!-- /.panel-body -->
            </div>
            <!-- /.panel -->
        </div>
        <!-- /.col-lg-12 -->
    </div>
    <!-- /#page-wrapper -->

</div>
<?php

include 'footer.php';
