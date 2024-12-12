<?php
include  "header.php";
?>
<!-- Container -->
<div id="page-wrapper">
    <h1>Danh sách đơn hàng</h1>
    <form action="" method="get">
        <div class="mb-3">
            <label for="sttFilter" class="form-label">Lọc:</label>
            <select name="stt" id="sttFilter">
                <?php $sttOrder = STTOrder::getAllSTTOrder();
                $sttSelect = 0;
                if (isset($_GET['stt'])) {
                    $sttSelect = $_GET['stt'];
                    echo '<option value="0">ALL</option>';
                } else {
                    echo '<option value="0" selected >ALL</option>';
                }
                foreach ($sttOrder as $stt) { ?>
                    <option value="<?php echo $stt['sttID'] ?>" <?php echo $stt['sttID'] == $sttSelect ? "selected" : "" ?>><?php echo $stt['sttName'] ?></option>
                <?php } ?>
            </select>
        </div>
        <button type="submit" class="btn btn-primary"> Tìm </button>

    </form>
    <table
        class="table table-primary">
        <thead>
            <tr>
                <th scope="col">Người mua</th>
                <th scope="col">Địa chỉ</th>
                <th scope="col">Ngày mua</th>
                <th scope="col">Giá trị</th>
                <th scope="col">Tình trạng</th>
                <th scope="col" style="width: 15%;"></th>
            </tr>
        </thead>
        <tbody>
            <?php
            $pager = isset($_GET['page']) ? $_GET['page'] : 1;
            $perPage = 10;
            $totalPage = Orders::getTotalPages($perPage);
            $orders = Orders::getAllOrder_pagination($pager, $perPage);
            if (isset($_GET['stt']) && $_GET['stt'] != 0) {
                $orders = Orders::getAllOrder_pagination_stt($pager, $perPage, $sttSelect);
                $totalPage = Orders::getTotalPages_stt($perPage, $sttSelect);
            }
            // foreach ($orders as $order) { 
            ?>
            <!-- <tr class="">
                    <td scope="row"><?php echo $order['fullname'] ?></td>
                    <td><?php echo $order['address'] ?></td>
                    <td><?php echo $order['createdate'] ?></td>
                    <td><?php echo number_format(Orders::total_order($order['id'])) ?> <span>VNĐ</span></td>
                    <td><?php echo STTOrder::getSTTOrderById($order['sttOrder'])['sttName'] ?></td>
                    <td>
                        <a href="vieworder_detail.php?id=<?php echo $order['id'] ?>" type="button" class="btn btn-primary">View </a>
                    </td>
                </tr> -->
            <?php if (!empty($orders)) {
                foreach ($orders as $order) {
                    // Lấy thông tin trạng thái
                    $stt = STTOrder::getSTTOrderById($order['sttOrder']);
            ?>
                    <tr>
                        <td scope="row"><?php echo isset($order['fullname']) ? $order['fullname'] : "Không có tên"; ?></td>
                        <td><?php echo isset($order['address']) ? $order['address'] : "Không có địa chỉ"; ?></td>
                        <td><?php echo isset($order['createdate']) ? $order['createdate'] : "Không có ngày"; ?></td>
                        <td>
                            <?php
                            $total = Orders::total_order($order['id']);
                            echo $total ? number_format($total) . " VNĐ" : "Không có giá trị";
                            ?>
                        </td>
                        <td><?php echo $stt ? $stt['sttName'] : "Không xác định"; ?></td>
                        <td>
                            <a href="vieworder_detail.php?id=<?php echo $order['id']; ?>" type="button" class="btn btn-primary">View</a>
                        </td>
                    </tr>
                <?php
                }
            } else { ?>
                <tr>
                    <td colspan="6">Không có đơn hàng nào.</td>
                </tr>
            <?php } ?>

        </tbody>
    </table>
    <nav aria-label="Page navigation">
        <ul
            class="pagination    ">
            <?php if ($pager - 1 > 0) { ?>
                <li class="page-item">
                    <a class="page-link" href="?page=<?php echo $pager - 1 ?><?php echo isset($_GET['stt']) ? "&stt=" . $sttSelect : "" ?>" aria-label="Previous">
                        <span aria-hidden="true">&laquo;</span>
                    </a>
                </li>
            <?php } ?>
            <?php for ($i = 1; $i <= $totalPage; $i++) { ?>
                <li class="page-item <?php echo $i == $pager ? "active" : "" ?>" aria-current="page">
                    <a class="page-link" href="?page=<?php echo $i ?><?php echo isset($_GET['stt']) ? "&stt=" . $sttSelect : "" ?>"><?php echo $i ?></a>
                </li>
            <?php } ?>
            <?php if ($pager + 1 <= $totalPage) { ?>
                <li class="page-item">
                    <a class="page-link" href="?page=<?php echo $pager + 1 ?><?php echo isset($_GET['stt']) ? "&stt=" . $sttSelect : "" ?>" aria-label="Next">
                        <span aria-hidden="true">&raquo;</span>
                    </a>
                </li>
            <?php } ?>
        </ul>
    </nav>

</div>

</div>
<?php
include  "footer.php";
