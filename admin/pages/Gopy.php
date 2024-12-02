<?php


include 'header.php';
?>

<!-- Page Content -->

<div id="page-wrapper">
    <div class="container-fluid">
        <div class="row">
            <div class="col-lg-12">
                <h1 class="page-header">Góp ý từ khách hàng</h1>
            </div>
            <div class="col-lg">

            </div>
            <!-- /.col-lg-12 -->
        </div>
        <!-- /.row -->
    </div>
    <?php
    $query = $db->executeQuery("SELECT `id`, `name`, `phone`, `email`, `content` FROM `feedback` ORDER BY `feedback`.`id` DESC LIMIT 0,10 ");
    $i = 1;
    while ($row = mysqli_fetch_assoc($query)) {
    ?>
        <div class="panel panel-default">
            <div class="panel-heading">
                <?php echo "Feedback #" . $i++; ?>
            </div>
            <div class="panel-body">
                <button type="button" class="btn btn-default">Name: <?php echo $row["name"]; ?></button>
                <button type="button" class="btn btn-default">Phone: <?php echo $row["phone"]; ?></button>
                <button type="button" class="btn btn-default">Email: <?php echo $row["email"]; ?></button>
                <div>
                    <?php echo $row["content"]; ?>
                </div>
            </div>
        </div>
    <?php
    }
    ?>
</div>
<?php

include 'footer.php';
?>