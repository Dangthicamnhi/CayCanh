<?php
include "header.php";


if ($_SERVER['REQUEST_METHOD'] == 'POST') {
  include 'connectDB.php';  // Database connection

  $name = $_POST['name'];
  $phone = $_POST['phone'];
  $email = $_POST['email'];
  $content = $_POST['content'];

  // Insert the feedback into the database

  $query = "INSERT INTO feedback (name, phone, email, content) VALUES ('$name', '$phone', '$email', '$content')";
  if ($db->executeQuery($query)) {
    // Redirect to thank-you page
    header("Location: thank-you.php");
    exit();
  } else {
    echo "Error submitting feedback!";
  }
}

?>



<!-- Page Content -->
<div class="container">

  <!-- Page Heading/Breadcrumbs -->
  <br>
  <h1 class="GreenBrand">RainBow Garden
    <small style="font-family: Arial">Liên hệ</small>
  </h1>


  <ol class="breadcrumb">
    <li class="breadcrumb-item">
      <a href="index.php">Trang chủ</a>
    </li>
    <li class="breadcrumb-item active">Liên hệ</li>
  </ol>

  <!-- Content Row -->
  <!-- Content Row -->
  <div class=" row">
    <!-- Map Column -->
    <div class="col-lg-8 mb-4">
      <!-- Embedded Google Map -->
      <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3918.4749789205785!2d106.75548917480612!3d10.851432489301938!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x31752797e321f8e9%3A0xb3ff69197b10ec4f!2zVHLGsOG7nW5nIGNhbyDEkeG6s25nIEPDtG5nIG5naOG7hyBUaOG7pyDEkOG7qWM!5e0!3m2!1svi!2s!4v1730472591242!5m2!1svi!2s" width="600" height="450" style="border:0;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
    </div>
    <!-- Contact Details Column -->
    <div class="col-lg-4 mb-4" style="font-family: 'Muli', sans-serif;">
      <h3>Địa chỉ liên lạc</h3>
      <p>
        53 Đ. Võ Văn Ngân, Linh Chiểu,

        <br>Thành Phố Thủ Đức, Hồ Chí Minh, Việt Nam
        <br>
      </p>
      <p>
        Liên hệ: 1800.1555
      </p>
      <p>Email:

        <a href="mailto:dangthicamnhi12@gmail.com">dangthicamnhi12@gmail.com
        </a>
      </p>
      <p title="Hours">Thời gian làm việc : Thứ 2 - Thứ 6: 8:00 AM to 5:00 PM

      </p>
    </div>
  </div>
  <!-- /.row -->

  <!-- Contact Form -->
  <!-- In order to set the email address and subject line for the contact form go to the bin/contact_me.php file. -->
  <div class="row">
    <div class="col-lg-8 mb-4">
      <h3>Để lại tin nhắn cho chúng tôi</h3>
      <form method="POST" action="thank_you.php">
        <div class="control-group form-group">
          <div class="controls">
            <label>Họ tên:</label>
            <input type="text" class="form-control" name="name_fb" id="name" required data-validation-required-message="Please enter your name.">
            <p class="help-block"></p>
          </div>
        </div>
        <div class="control-group form-group">
          <div class="controls">
            <label>Số điện thoại:</label>
            <input type="tel" class="form-control" name="phone_fb" id="phone" required data-validation-required-message="Please enter your phone number.">
          </div>
        </div>
        <div class="control-group form-group">
          <div class="controls">
            <label>Email:</label>
            <input type="email" class="form-control" name="email_fb" id="email" required data-validation-required-message="Please enter your email address.">
          </div>
        </div>
        <div class="control-group form-group">
          <div class="controls">
            <label>Nội dung:</label>
            <textarea rows="10" cols="100" class="form-control" name="message_fb" id="message" required data-validation-required-message="Please enter your message" maxlength="999" style="resize:none"></textarea>
          </div>
        </div>

        <!-- For success/fail messages -->
        <input type="submit" class="btn success" name="send_feedback" value="Gửi">

      </form>
    </div>

  </div>
  <!-- /.row -->

</div>
<?php
include 'footer.php';
?>