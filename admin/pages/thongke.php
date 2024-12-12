<?php
include 'header.php';

$category = 0;
$totalDay = 0;
$totalMonth = 0;
$totalYear = 0;
$Day = 0;
$Month = date('m');
$Year = date('Y');
if (isset($_GET['category'])) {
    $category = $_GET['category'];
    $query = $db->executeQuery("SELECT * FROM category where id = $category");
    $result = mysqli_fetch_assoc($query);
    $name_page = $result['name'];
}

include("chartproduct.php");
if ($Day == 0) {
    $date = getdate();
    $Day = $date["mday"];
}

?>

<div id="page-wrapper">
    <div class="row">
        <br>
        <div class="col-lg-12">
            <div class="panel panel-green">
                <div class="panel-heading">
                    <strong> Doanh thu</strong>
                </div>
                <div class="panel-body">

                    <div class="col-lg-4 col-md-6">
                        <div class="panel panel-green">
                            <div class="panel-heading">
                                <div class="row">
                                    <div class="col-xs-3">
                                        <i class="fa fa-tasks fa-5x"></i>
                                    </div>
                                    <div class="col-xs-9 text-right">
                                        <div>Tổng doanh thu ngày <?php echo $Day ?></div>
                                        <div class="huge"><?php echo number_format($totalDay, 0, '', ',')  ?></div>

                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>

                    <div class="col-lg-4 col-md-6">
                        <div class="panel panel-green">
                            <div class="panel-heading">
                                <div class="row">
                                    <div class="col-xs-3">
                                        <i class="fa fa-tasks fa-5x"></i>
                                    </div>
                                    <div class="col-xs-9 text-right">
                                        <div>Tổng doanh thu tháng <?php echo $Month ?></div>
                                        <div class="huge"><?php echo number_format($totalMonth, 0, '', ',') ?></div>

                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>


                    <div class="col-lg-4 col-md-6">
                        <div class="panel panel-green">
                            <div class="panel-heading">
                                <div class="row">
                                    <div class="col-xs-3">
                                        <i class="fa fa-tasks fa-5x"></i>
                                    </div>
                                    <div class="col-xs-9 text-right">
                                        <div>Tổng doanh thu năm <?php echo $Year ?></div>
                                        <div class="huge"><?php echo number_format($totalYear, 0, '', ',') ?></div>

                                    </div>
                                </div>
                            </div>

                        </div>
                    </div>
                </div>

            </div>

        </div>
    </div>
    <?php if (isset($_GET['SelView'])) {
        $SelView = $_GET['SelView'];
    } else {
        $SelView = 1;
    } ?>
    <div class="panel panel-default">
        <div class="panel-heading">
            <i class="fa fa-bar-chart-o fa-fw"></i> Biểu đồ bán hàng
            <div class="pull-right">
                <div class="btn-group">
                    <button type="button" class="btn btn-default btn-xs dropdown-toggle" data-toggle="dropdown">
                        Theo
                        <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu pull-right" role="menu">
                        <li><a href="thongke?category=<?php echo $category ?>&SelView=1">Ngày</a>
                        </li>
                        <li><a href="thongke?category=<?php echo $category ?>&SelView=2">Tháng</a>
                        </li>
                        <li><a href="thongke?category=<?php echo $category ?>&SelView=3">Năm</a>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
        <!-- /.panel-heading -->
        <div class="panel-body">
            <div class="row">
                <div class="col-lg">
                    <div class="table-responsive">
                        <table class="table table-bordered table-hover table-striped">
                            <thead>
                                <tr>
                                    <th>Stt</th>
                                    <th>Tên đơn hàng</th>
                                    <th>Ngày tạo</th>
                                    <th>Tổng tiền</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php
                                if ($SelView == 1) {
                                    $sqlCt = "call sp_thongkedonhang(concat(YEAR(now()),'-',month(now()),'-',day(now())), concat(YEAR(now()),'-',month(now()),'-',day(now())+1),$category)";
                                } else if ($SelView == 2) {
                                    $sqlCt = "call sp_thongkedonhang(concat(YEAR(now()),'-',month(now()),'-1'), LAST_DAY(now()),$category)";
                                } else if ($SelView == 3) {
                                    $sqlCt = "call sp_thongkedonhang(concat(YEAR(now()),'-1','-1'),concat(year(now()),'-12-31'),$category)";
                                }

                                $tbCart = $db->executeQuery($sqlCt);
                                $i = 1;
                                while ($row = mysqli_fetch_assoc($tbCart)) {

                                ?>
                                    <tr class="odd gradeX">

                                        <td><?php echo $i;
                                            $i++ ?></td>
                                        <td><?php echo $row['id'] ?> </td>
                                        <td><?php echo $row['createdate'] ?></td>
                                        <td> <?php echo number_format($row['total'], 0, '', '.') ?></td>

                                    </tr>

                                <?php
                                }
                                ?>
                            </tbody>
                        </table>
                    </div>
                    <!-- /.table-responsive -->
                </div>
                <!-- /.col-lg-4 (nested) -->
                <div class="col-lg-8">
                    <div id="morris-bar-chart"></div>
                </div>
                <!-- /.col-lg-8 (nested) -->
            </div>
            <!-- /.row -->
        </div>
        <!-- /.panel-body -->
    </div>
</div>

<?php
include "footer.php";

?>
<!-- draw chart -->
<script type="text/javascript">
    new Morris.Line({
        // ID of the element in which to draw the chart.
        element: 'morris-bar-chart',
        // Chart data records -- each entry in this array corresponds to a point on
        // the chart.

        data: [
            <?php
            $sqlChar = "SELECT sum(p2.tprice) tmonth,YEAR( p1.createdate) MonthC FROM cart p1
             JOIN (SELECT d.id_cart, sum( d.quantity * p.price) tprice FROM cart_detail d JOIN product p ON d.id_product = p.id
             WHERE p.category={$category} GROUP BY d.id_cart) p2 ON p1.id =p2.id_cart  GROUP BY YEAR(p1.createdate)";
            $CharCart = $db->executeQuery($sqlChar);

            while ($row = mysqli_fetch_assoc($CharCart)) {
            ?> {
                    month: '<?php echo "000" . $row["MonthC"] ?>',
                    value: <?php echo $row["tmonth"] ?>
                },
            <?php
            }
            ?>

        ],
        // The name of the data record attribute that contains x-values.
        xkey: 'month',
        // A list of names of data record attributes that contain y-values.
        ykeys: ['value'],
        // Labels for the ykeys -- will be displayed when you hover over the
        // chart.
        labels: ['Value']
    });
</script>