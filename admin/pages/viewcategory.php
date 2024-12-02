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
                            Danh sách loại sản phẩm
                        </div>
                        <div class="col-lg-4" style="text-align: right">
                            <button type="button" class="btnaddCategory btn btn-outline btn-success" data-toggle="collapse" href="#collapseOne">Thêm loại sản phẩm</button>
                            <button type="button" class=" btnaddCategory btn btn-outline btn-success" data-toggle="collapse" href="#collapseTwo">Xóa loại sản phẩm</button>
                        </div>
                    </div>
                </div>

                <div id="collapseOne" class="panel-collapse collapse">

                    <h4 style="color: #4b9249; padding-left: 30px;">Thêm loại sản phẩm</h4>

                    <form action="Category.php" method="POST" enctype="multipart/form-data">
                        <div class="panel-body">

                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Tên loại sản phẩm" name="name"
                                    required data-validation-required-message="Please enter your email address.">
                            </div>
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="link ảnh" name="image" accept="image/png, image/jpeg, image/jpg" type="file"
                                    required data-validation-required-message="Please chose image.">

                            </div>
                            <div class="form-group col-lg-4">

                                <input type="submit" class=" btn btn-outline btn-success"
                                    style="width: 100%" name="create_category" value="Xác nhận">

                            </div>

                        </div>
                    </form>
                </div>
                <div id="collapseEdit" class="panel-collapse collapse">
                    <h4 style="color: #4b9249; padding-left: 30px;">Sửa loại sản phẩm</h4>
                    <form action="Category.php" method="POST" enctype="multipart/form-data">
                        <div class="panel-body">
                            <div class="form-group col-lg-4">
                                <input type="hidden" name="id" id="editCategoryId">
                                <input class="form-control" placeholder="Tên loại sản phẩm" name="name" id="editCategoryName" required>
                            </div>
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Link ảnh" name="image" id="editCategoryImage" accept="image/png, image/jpeg, image/jpg" type="file">
                            </div>

                            <div class="form-group col-lg-4">
                                <input type="submit" class="btn btn-outline btn-success" style="width: 100%" name="edit_category" value="Xác nhận sửa">
                            </div>
                        </div>
                    </form>
                </div>


                <div id="collapseTwo" class="panel-collapse collapse">
                    <h4 style="color: #4b9249; padding-left: 30px;">Xóa loại sản phẩm</h4>
                    <form action="Category.php" method="POST">
                        <div class="panel-body">
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Mã loại sản phẩm" name="id_category"
                                    required data-validation-required-message="Please enter your email address.">
                            </div>

                            <div class=" form-group col-lg-4">
                                <input type="submit" class="btn btn-outline btn-success"
                                    style="width: 100%" name="delete_category" value="Xác nhận">
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
                                <th>Mã sản phẩm</th>
                                <th>Tên sản phẩm</th>
                                <th>Ảnh</th>
                                <th>Sửa</th>


                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $sql = "SELECT * FROM `category` WHERE id";
                            $query = $db->executeQuery($sql);
                            while ($row = mysqli_fetch_assoc($query)) {

                            ?>
                                <tr class="odd gradeX">
                                    <td><?php echo $row['id'] ?></td>
                                    <td><?php echo $row['name'] ?> </td>
                                    <td> <img style="width: 30px; height:30px" src="../../<?php echo $row['image'] ?>"></td>
                                    <td><a href="Category.php?cat_edit_id=<?php echo $row['id']; ?>" class="btn btn-outline btn-warning edit-category">Sửa</a></td>

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
