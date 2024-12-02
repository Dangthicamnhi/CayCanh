<?php
include "header.php";

$size = 4;
$danhmuccon = 0; //id của category
$tongsotrang = 0;
$themsotrang = 0;
$key = '';
$name_page = '';
//Lấy id từ thanh địa chỉ 
if (isset($_GET['category'])) {
  $danhmuccon = $_GET['category'];
  $query = $db->executeQuery("SELECT * FROM category where id = $danhmuccon");
  $result = mysqli_fetch_assoc($query);
  $name_page = $result['name'];
}
?>


<!-- Page Content -->
<div class="container">

  <!-- Page Heading/Breadcrumbs -->
  <br>

  <h1 class="GreenBrand">RainBow Garden
    <small style="font-family: Arial; text-transform: capitalize;"><?php echo $name_page ?></small>
  </h1>

  <ol class="breadcrumb">
    <li class="breadcrumb-item">
      <a href="index.php">Trang Chủ</a>
    </li>
    <li class="breadcrumb-item active" style="text-transform: capitalize;"><?php echo $name_page ?></li>
  </ol>

  <style type="text/css">
    a {
      color: #4b9249;

    }

    a:hover {
      color: #a1e6a1 !important;
    }
  </style>
  <div class="row">

    <?php

    if (isset($_GET['tukhoa'])) {
      $key = $_GET['tukhoa'];
      $result = $db->executeQuery("SELECT count(*) countid from product where name like '%$key%' and category = $danhmuccon");
    } else {
      $result = $db->executeQuery("SELECT count(*) countid from product where category = $danhmuccon");
    }

    if ($result) {
      $row = mysqli_fetch_assoc($result);
      $numpd = (int)$row["countid"];
      // echo "key" . $numpd;
      $tongsotrang = $numpd / $size;
      if ($numpd % $size == 0)
        $themsotrang = 0;
      else
        $themsotrang = 1;
      include("php/products-list.php");
    } ?>

  </div>

  <!-- Pagination -->
  <div>
    <ul class="pagination justify-content-center">
      <?php
      for ($i = 1; $i <= $tongsotrang + $themsotrang; $i++) {
        echo "<li class=\"page-item\" >
      <a class=\"pageprlink page-link\"  href=\"?category={$danhmuccon}&trang={$i}\"
      style=\" color: #4b9249\">{$i}</a>
      </li> ";
      }
      ?>
    </ul>
  </div>

</div>
<!-- /.container -->

<?php
include 'footer.php';
?>