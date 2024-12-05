<?php
include 'header.php';
?>
<div class="container">
    <div class="row" style="padding: 20px;">
        <div class="col-md-4 col-md-offset-4" style="text-align: center;">
            <div class="login-panel panel panel-default">
                <div class="panel-heading">
                    <h3 class="panel-title"><STRONG style="color: #1e7e34">ĐĂNG NHẬP</STRONG></h3>
                </div>
                <div class="panel-body">
                    <form action="" method="POST">
                        <fieldset>
                            <div class="form-group">
                                <input class="form-control" placeholder="E-mail" name="email" type="email" autofocus required data-validation-required-message="Please enter your email address.">
                                <p class="help-block"></p>
                            </div>
                            <div class="form-group">
                                <input class="form-control" placeholder="Password" name="password" type="password" required data-validation-required-message="Please enter your name.">
                            </div>
                            <div class="checkbox">
                                <label>
                                    <input name="remember" type="checkbox" value="Remember Me">Nhớ mật khẩu
                                </label>
                            </div>
                            <!-- Change this to a button or input when using this as a form -->
                            <input type="submit" name="btn_submit" value="Xác nhận" class="btn btn-lg btn-success btn-block">
                        </fieldset>
                    </form>
                    <div style="margin-top: 15px; text-align: center;">
                        <a href="reset_password.php">Quên mật khẩu?</a>
                    </div>

                </div>
            </div>
        </div>
    </div>
</div>

<?php
include 'footer.php';
?>