<?php
include 'header.php';
?>
<header>
  <div id="carouselExampleIndicators" class="carousel slide" data-ride="carousel">
    <ol class="carousel-indicators">
      <li data-target="#carouselExampleIndicators" data-slide-to="0" class="active"></li>
      <li data-target="#carouselExampleIndicators" data-slide-to="1"></li>
      <li data-target="#carouselExampleIndicators" data-slide-to="2"></li>
    </ol>
    <div class="carousel-inner" role="listbox">
      <!-- Slide One - Set the background image for this slide in the line below -->
      <div class="carousel-item active" style="background-image: url('img/bg-1.jpg')">
        <div class="carousel-caption d-none d-md-block">
          <h1 style="text-shadow: 1px 1px 2px black">Làm việc với niềm cảm hứng</h1>
          <p>Hãy chọn loại cây bạn thích nó sẽ giúp bạn làm việc hiệu quả hơn</p>
          <a href="loaicay?category= 1" class="button" style="transition: background-color 0.3s ease-out 0s; min-height: 0px; min-width: 0px; line-height: 18px; border-width: 1px; margin: 0px; padding: 15px 29px; letter-spacing: 0px; font-size: 20px;">XEM NGAY</a>

        </div>
      </div>
      <!-- Slide Two - Set the background image for this slide in the line below -->
      <div class="carousel-item" style="background-image: url('img/bg-2.jpg')">
        <div class="carousel-caption d-none d-md-block">
          <h1 style="text-shadow: 1px 1px 2px black">Màu xanh làm tăng sức sống</h1>
          <p>Hãy để màu xanh trong cuộc sống của bạn, nó sẽ khiến bạn mạnh mẽ hơn.</p>
          <a href="loaicay?category= 2" class="button" style="transition: background-color 0.3s ease-out 0s; min-height: 0px; min-width: 0px; line-height: 18px; border-width: 1px; margin: 0px; padding: 15px 29px; letter-spacing: 0px; font-size: 20px;">XEM NGAY</a>
        </div>
      </div>
      <!-- Slide Three - Set the background image for this slide in the line below -->
      <div class="carousel-item" style="background-image: url('img/bg-3.jpg')">
        <div class="carousel-caption d-none d-md-block">
          <h1 style="text-shadow: 1px 1px 2px black">Thay đổi nhỏ hiệu quả lớn</h1>
          <p>Chỉ cần đặt vài chậu hoa ở những nơi được gọi là nhàm chán và nó sẽ làm nơi đó sinh động hơn</p>
          <a href="loaicay?category= 3" class="button" style="transition: background-color 0.3s ease-out 0s; min-height: 0px; min-width: 0px; line-height: 18px; border-width: 1px; margin: 0px; padding: 15px 29px; letter-spacing: 0px; font-size: 20px;">XEM NGAY</a>

        </div>
      </div>
    </div>
    <a class="carousel-control-prev" href="#carouselExampleIndicators" role="button" data-slide="prev">
      <span class="carousel-control-prev-icon" aria-hidden="true"></span>
      <span class="sr-only">Previous</span>
    </a>
    <a class="carousel-control-next" href="#carouselExampleIndicators" role="button" data-slide="next">
      <span class="carousel-control-next-icon" aria-hidden="true"></span>
      <span class="sr-only">Next</span>
    </a>
  </div>
</header>

<!-- Page Content -->
<div class="container">
  <h1 class="my-4"> </h1>
  <!-- Marketing Icons Section -->
  <div class="row">
    <div class="col-lg-4 mb-4">
      <div class="card">
        <h4 class="card-header Bmiddle">Cây mini để bàn</h4>
        <div class="CCard1">
          <div class="figure banner-with-effects effect-oscar green-button with-button">
            <img src="img/deban.jpg" alt="" style="width: 100%">
            <div class="figcaption simple-banner">
            </div>
            <?php foreach ($result as $value) : ?>

              <!-- <a href="caymini.php" class="center center" rel="nofollow">XEM THÊM</a> -->
              <a href="loaicay?category= 1" class="center center" rel="nofollow">XEM THÊM</a>
            <?php endforeach; ?>

          </div>
        </div>
      </div>
    </div>

    <div class="col-lg-4 mb-4">
      <div class="card">
        <h4 class="card-header Bmiddle">Cây không khí</h4>
        <div class="CCard1 Eimg">
          <div class="figure banner-with-effects effect-oscar green-button with-button">
            <img src="img/khongkhi.jpg" alt="" style="width: 100%">
            <div class="figcaption simple-banner">
            </div>
            <?php foreach ($result as $value) : ?>

              <!-- <a href="caymini.php" class="center center" rel="nofollow">XEM THÊM</a> -->
              <a href="loaicay?category= 2" class="center center" rel="nofollow">XEM THÊM</a>
            <?php endforeach; ?>

          </div>

        </div>

      </div>
    </div>
    <div class="col-lg-4 mb-4">
      <div class="card">
        <h4 class="card-header Bmiddle">Cây handmade</h4>
        <div class="CCard1 Eimg">
          <div class="figure banner-with-effects effect-oscar green-button with-button">
            <img src="img/handmade.jpg" alt="" style="width: 100%">
            <div class="figcaption simple-banner">
            </div>
            <?php foreach ($result as $value) : ?>

              <!-- <a href="caymini.php" class="center center" rel="nofollow">XEM THÊM</a> -->
              <a href="loaicay?category= 3" class="center center" rel="nofollow">XEM THÊM</a>
            <?php endforeach; ?>

          </div>
        </div>

      </div>
    </div>
  </div>
</div>
<!-- /.row -->

<!-- Portfolio Section -->


<div class="Sanpham">
  <h4>Các sản phẩm <?php if (!isset($_GET['tukhoa'])) echo "nổi bật" ?> </h4>
</div>
<div class="row">


  <?php
  $size = 8;
  $danhmuccon = 0;
  $tongsotrang = 0;
  $themsotrang = 0;
  $key = '';
  if (isset($_GET['tukhoa'])) {
    $key = $_GET['tukhoa'];
    $result = $db->executeQuery("SELECT count(*) countid from product where name like '%$key%'");
  } else
    //$result=$db->executeQuery("SELECT * from product");
    $result = $db->executeQuery("SELECT count(*) countid from product where category=$danhmuccon");
  if ($result) {
    $row = mysqli_fetch_assoc($result);
    $numpd = $row["countid"];
    $tongsotrang = $numpd / 8;
    if ($numpd % 8 == 0)
      $themsotrang = 0;
    else
      $themsotrang = 1; ?>
    <div class="container">
      <?php include("php/products-list.php"); ?>
    </div>

  <?php }
  ?>
</div>
<!-- /.row -->

<!-- Features Section -->
<div class="row">
  <div class="panel-grid" id="pg-4680-4">
    <div class="siteorigin-panels-stretch panel-row-style" style="padding: 70px;background-image: url(http://vuoncaymini.com/wp-content/uploads/2015/01/texture_1.png);background-repeat: repeat;" data-stretch-type="full">
      <div class="panel-grid-cell" id="pgc-4680-4-0">
        <div class="so-panel widget widget_qt_testimonials widget-testimonials panel-first-child panel-last-child" id="panel-4680-4-0-0" data-index="6">
          <div class="testimonials">

            <h3 class="widget-title" style=" color: #4b9249">



              Khách Hàng Nói Gì?
            </h3>

            <div id="testimonials-carousel-widget-4-0-0" class="carousel slide" data-ride="carousel" data-interval="8000">
              <div class="carousel-inner" role="listbox">
                <div class="item active">
                  <div class="row">


                    <div class="col-xs-12 col-sm-6 col-md-6">
                      <blockquote class="testimonial-quote">
                        Tôi là người yêu thích cây cảnh, hoa hòe, tìm hoài không biết nên mua cái gì để chưng cho phòng khách cả. Tình cờ tìm được trang web Rainbown Graden , click vào xem thì quá ư là thích, nó vừa lạ, vừa bé, vừa xinh, không chịu nỗi. </blockquote>
                      <div class="testimonial-person">
                        <cite class="testimonial-author">Chị Quỳnh</cite>
                        <span class="testimonial-location">Q.3, HCM</span>
                      </div>
                    </div>
                    <div class="col-xs-12 col-sm-6 col-md-6">
                      <blockquote class="testimonial-quote">
                        Tôi quyết định trang trí bàn làm việc bằng những cây xanh, mà thấy ở đâu cũng những cây lớn quá cỡ. Được người bạn giới thiệu lên Rainbow Graden xem. Thế là bàn của tôi không những xinh mà còn sinh động nữa chứ. </blockquote>
                      <div class="testimonial-person">
                        <cite class="testimonial-author">Ms. Trân</cite>
                        <span class="testimonial-location">Tân Bình, HCM</span>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="item">
                  <div class="row">
                    <div class="col-xs-12 col-sm-6 col-md-6">
                      <blockquote class="testimonial-quote">
                        Là người khá kỹ tính, nên những thứ tôi chọn thường yêu cầu rất cao. Nhưng may mắn thay, tôi mua cây tại đây các bạn tư vấn rất nhiệt tình và khá chi tiết. Hi vọng các bạn sẽ vẫn giữ được sự chuyên nghiệp này, tôi sẽ ủng hộ dài dài. </blockquote>
                      <div class="testimonial-person">
                        <cite class="testimonial-author">Ms. Ngọc</cite>
                        <span class="testimonial-location">Hậu Giang</span>
                      </div>
                    </div>
                    <div class="col-xs-12 col-sm-6 col-md-6">
                      <blockquote class="testimonial-quote">
                        Tôi yêu hoa cảnh và kinh doanh. Tôi tìm được vườn có nhiều loại cây khá độc và dễ thương. Biết là cạnh tranh nhưng các bạn rất thoải mái tư vấn về kinh doanh và chăm sóc cây. Hi vọng hợp tác dài lâu với vườn. </blockquote>
                      <div class="testimonial-person">
                        <cite class="testimonial-author">Đại lý (giấu tên)</cite>
                        <span class="testimonial-location">Đà Nẵng</span>
                      </div>
                    </div>

                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  </div>
</div>
<!-- /.row -->

<hr>
</div>
<?php
include "footer.php";
?>