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
                            Danh sách sản phẩm
                        </div>
                        <div class="col-lg-4" style="text-align: right">
                            <button type="button" class="btnaddproduct btn btn-outline btn-success" data-toggle="collapse" href="#collapseOne">Thêm sản phẩm</button>
                            <button type="button" class=" btnaddproduct btn btn-outline btn-success" data-toggle="collapse" href="#collapseTwo">Xóa sản phẩm</button>
                        </div>
                    </div>
                </div>

                <div id="collapseOne" class="panel-collapse collapse">

                    <h4 style="color: #4b9249; padding-left: 30px;">Thêm sản phẩm</h4>

                    <form action="Changeproduct.php" method="POST" enctype="multipart/form-data">
                        <div class="panel-body">

                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Tên sản phẩm" name="name"
                                    required data-validation-required-message="Please enter your email address.">
                            </div>
                            <div class="form-group col-lg-4" style="display: table">
                                <input class="form-control" placeholder="Giá" name="price"
                                    required data-validation-required-message="Please enter your email address.">
                            </div>
                            <?php
                            $query = $db->executeQuery("SELECT * FROM category");
                            $result = mysqli_fetch_all($query, MYSQLI_ASSOC);

                            ?>
                            <div class="form-group col-lg-4">
                                <select class="form-control" name="category">
                                    <option value="">Loại cây</option>
                                    <?php foreach ($result as $value) : ?>
                                        <option value="<?php echo $value['id']; ?>"><?php echo $value['name']; ?></option>
                                    <?php endforeach; ?>

                                </select>
                            </div>
                            <div class="form-group col-lg-4" style="display: table">
                                <input class="form-control" placeholder="Khuyến mãi" name="saleoff"
                                    required data-validation-required-message="Please enter your email address.">
                                <span class="input-group-addon">%</span>
                            </div>
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="link ảnh" name="image" accept="image/png, image/jpeg, image/jpg" type="file"
                                    required data-validation-required-message="Please chose image.">

                            </div>
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Miêu tả" name="short_descripsion"
                                    required data-validation-required-message="Please enter your email address.">
                            </div>
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Số lượng" name="inStock"
                                    required data-validation-required-message="Please enter your email address.">
                            </div>
                            <div class="form-group col-lg-4">
                                <select class="form-control" name="isAvailable">
                                    <option value="1">Được bán</option>

                                    <option value="0">Lưu trữ</option>


                                </select>
                            </div>
                            <div class="form-group col-lg-4">

                                <input type="submit" class=" btn btn-outline btn-success"
                                    style="width: 100%" name="create_product" value="Xác nhận">

                            </div>

                        </div>
                    </form>
                </div>
                <div id="collapseEdit" class="panel-collapse collapse">
                    <h4 style="color: #4b9249; padding-left: 30px;">Sửa sản phẩm</h4>
                    <form action="Changeproduct.php" method="POST" enctype="multipart/form-data">
                        <div class="panel-body">
                            <div class="form-group col-lg-4">
                                <input type="hidden" name="id" id="editProductId">
                                <input class="form-control" placeholder="Tên sản phẩm" name="name" id="editProductName" required>
                            </div>
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Giá" name="price" id="editProductPrice" required>
                            </div>
                            <?php
                            $query = $db->executeQuery("SELECT * FROM category");
                            $result = mysqli_fetch_all($query, MYSQLI_ASSOC);

                            ?>
                            <div class="form-group col-lg-4">
                                <select class="form-control" name="category">
                                    <option value="">Loại cây</option>
                                    <?php foreach ($result as $value) : ?>
                                        <option value="<?php echo $value['id']; ?>"><?php echo $value['name']; ?></option>
                                    <?php endforeach; ?>

                                </select>
                            </div>
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Khuyến mãi" name="saleoff" id="editProductSaleoff" required>
                                <span class="input-group-addon">%</span>
                            </div>
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Link ảnh" name="image" id="editProductImage" accept="image/png, image/jpeg, image/jpg" type="file">
                            </div>
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Miêu tả" name="short_descripsion" id="editProductDescription" required>
                            </div>
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Số lượng" name="inStock" id="editProductStock" required>
                            </div>
                            <div class="form-group col-lg-4">
                                <select class="form-control" name="isAvailable" id="editProductAvailable">
                                    <option value="1">Được bán</option>
                                    <option value="0">Lưu trữ</option>
                                </select>
                            </div>
                            <div class="form-group col-lg-4">
                                <input type="submit" class="btn btn-outline btn-success" style="width: 100%" name="edit_product" value="Xác nhận sửa">
                            </div>
                        </div>
                    </form>
                </div>


                <div id="collapseTwo" class="panel-collapse collapse">
                    <h4 style="color: #4b9249; padding-left: 30px;">Xóa sản phẩm</h4>
                    <form action="Changeproduct.php" method="POST">
                        <div class="panel-body">
                            <div class="form-group col-lg-4">
                                <input class="form-control" placeholder="Mã sản phẩm" name="id_product"
                                    required data-validation-required-message="Please enter your email address.">
                            </div>

                            <div class="form-group col-lg-4">
                                <input type="submit" class="btn btn-outline btn-success"
                                    style="width: 100%" name="delete_product" value="Xác nhận">
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
                                <th>Giá(s)</th>
                                <th>Ảnh</th>
                                <th>Loại sản phẩm</th>
                                <th>Khuyến mãi</th>
                                <th>Sửa</th>


                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $sql = "select p.*, activePrice(p.id) as price from product p";
                            $query = $db->executeQuery($sql);
                            while ($row = mysqli_fetch_assoc($query)) {

                            ?>
                                <tr class="odd gradeX">
                                    <td><?php echo $row['id'] ?></td>
                                    <td><?php echo $row['name'] ?> </td>

                                    <td><?php echo  number_format($row['price'], 0, '', ',')   ?></td>
                                    <td> <img style="width: 30px; height:30px" src="../../<?php echo $row['imagiUrl'] ?>"></td>
                                    <td><?php if ($row['category'] == 1)
                                            echo "cây mini";
                                        else if ($row['category'] == 2)
                                            echo "cây không khí";
                                        else echo "cây handmande" ?></td>
                                    <td><?php echo $row['saleoff'] ?></td>
                                    <!-- href="editproduct.php?pro_edit_id=<?php echo $product['id']; ?>" -->
                                    <td><a href="Changeproduct.php?pro_edit_id=<?php echo $row['id']; ?>" class="btn btn-outline btn-warning edit-product">Sửa</a></td>

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
