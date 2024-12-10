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

  <div class="containe">
    <div class="card my-4">
      <h5 class="card-header">Bình luận</h5>
      <div class="card-body">
        <?php if (isset($_SESSION['account'])): ?>
          <!-- Form bình luận nếu đã đăng nhập -->
          <form method="POST" action="add_comment.php">
            <input type="hidden" name="product_id" value="<?php echo $id; ?>">
            <div class="form-group">
              <textarea class="form-control" name="comment_content" rows="3" required></textarea>
            </div>
            <button type="submit" class="btn btn-primary" style="background-color:#4b9249; border-color:#4b9249">Xác nhận</button>
          </form>
        <?php else: ?>
          <!-- Yêu cầu đăng nhập nếu chưa đăng nhập -->
          <p>Bạn cần <a href="login.php">đăng nhập</a> để bình luận.</p>
        <?php endif; ?>
      </div>
    </div>

    <!-- Hiển thị danh sách bình luận -->
    <div class="comments-list">
      <?php
      // Truy vấn danh sách bình luận cho sản phẩm hiện tại
      $query_comments = $db->executeQuery("SELECT * FROM comments WHERE product_id = $id ORDER BY createdate DESC");

      if (mysqli_num_rows($query_comments) > 0):
        while ($comment = mysqli_fetch_assoc($query_comments)):
      ?>
          <div class="media mb-4">
            <img class="d-flex mr-3 rounded-circle" src="img/default-avatar.jpg" alt="User Image" style="width: 50px; height: 50px;">
            <div class="media-body">
              <h5 class="mt-0"><?php echo htmlspecialchars($comment['user_name']); ?></h5>
              <p><?php echo htmlspecialchars($comment['comment_content']); ?></p>
              <small class="text-muted">Đăng vào: <?php echo $comment['createdate']; ?></small>
            </div>
          </div>
        <?php endwhile;
      else: ?>
        <p>Chưa có bình luận nào.</p>
      <?php endif; ?>

    </div>

  <?php
} else { ?>
    <h2>Không tìm thấy sản phẩm.</h2>
    <a href="index.php">Trang chủ</a>
  <?php }
include "footer.php";
  ?>