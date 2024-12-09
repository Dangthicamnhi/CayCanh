<?php
include 'header.php';

// Lấy ID sản phẩm từ tham số GET
$id = isset($_GET['id']) ? intval($_GET['id']) : 0;

// Truy vấn thông tin sản phẩm từ cơ sở dữ liệu
$product = Product::getProductById($id);
if ($product) {
  $query3 = $db->executeQuery("SELECT * FROM category  WHERE id= {$product['category']}");
  $category = mysqli_fetch_assoc($query3);

  $query4 = $db->executeQuery("SELECT * FROM product  WHERE category= {$category['id']}");
?>


  <div class="container">

    <h1 class="GreenBrand">RainBow Garden
      <small style="font-family: Arial"><?php echo $category['name']; ?></small>
    </h1>

    <ol class="breadcrumb">
      <li class="breadcrumb-item">
        <a href="loaicay?category= <?php echo $category['id']; ?>"><?php echo $category['name']; ?></a>
      </li>
      <li class="breadcrumb-item active"><?php echo $product['name']; ?></li>
    </ol>
    <h1><?php echo $product['name']; ?></h1>
    <div class="row">
      <div class="col-lg-5">
        <img class="img-fluid" src="<?php echo $product['imagiUrl']; ?>" alt="<?php echo $product['name']; ?>">
      </div>
      <div class="col-lg-4">
        <h4><strong><?php echo number_format($product['price'], 0, ',', '.'); ?>VND</strong></h4>
        <p><?php echo $product['short_descripsion']; ?></p>
        <button type="button" class="btn btn-primary"><a href="?id=<?php echo $product['id'] ?>&add_cart=<?php echo $product['id'] ?>">
            Thêm vào giỏ
          </a></button>
      </div>
      <div class="col-lg-3">
        <h5 class="card-header borsp">Sản phẩm tương tự</h5>
        <div class="card-body borsp">
          <ul class="list-unstyled mb-0">
            <?php
            $result = mysqli_fetch_all($query4, MYSQLI_ASSOC);
            ?>
            <?php foreach ($result as $value) : ?>
              <li>
                <a href="?id=<?php echo $value['id'] ?>"><?php echo $value['name'] ?></a>
              </li>
            <?php endforeach; ?>
          </ul>
        </div>
      </div>
    </div>
  </div>
  <!-- Comments Form -->
  <div class="card my-4">
    <h5 class="card-header">Bình luận</h5>
    <div class="card-body">
      <form>
        <div class="form-group">
          <textarea class="form-control" rows="3"></textarea>
        </div>
        <button type="submit" class="btn btn-primary" style="background-color:#4b9249; border-color:#4b9249">Xác nhận</button>
      </form>
    </div>
  </div>

  <!-- Single Comment -->
  <div class="media mb-4">
    <img class="d-flex mr-3 rounded-circle" src="img/sakukai.jpg" alt="">
    <div class="media-body">
      <h5 class="mt-0">Ria Sakukia</h5>
      Mình rất thích loại cây này, nó làm tăng cảm hứng khi mình làm việc rất nhiều... hm~~~
    </div>
  </div>

  <!-- Comment with nested comments -->
  <div class="media mb-4">
    <img class="d-flex mr-3 rounded-circle" src="img/xuan.jpg" alt="">
    <div class="media-body">
      <h5 class="mt-0">葛盈瑄 </h5>
      Mình mới mua, mình đặt nó trong nhà bếp thấy rất đẹp. Mà do buổi sáng nắng chiếu vào nhiều, không biết có bị gì không?

      <div class="media mt-4">
        <img class="d-flex mr-3 rounded-circle" src="img/farach.jpg" alt="">
        <div class="media-body">
          <h5 class="mt-0">celinefarach</h5>
          Mình cũng có một cây như vậy ở nhà, đã ngoài nắng không sao đâu bạn!
        </div>
      </div>

      <div class="media mt-4">
        <img class="d-flex mr-3 rounded-circle" src="img/baongoc.jpg" alt="">
        <div class="media-body">
          <h5 class="mt-0">Bảo Ngọc</h5>
          Nếu để trong nhà bếp bạn nên để cây Kim Ngân á, cây đó đẹp mà chịu nắng tốt, quan trọng là phong thủy để trong nhà bếp lại lợi nữa.
        </div>
      </div>

    </div>
  </div>


<?php
} else { ?>
  <h2>Không tìm thấy sản phẩm.</h2>
  <a href="index.php">Trang chủ</a>
<?php }
include "footer.php";
?>