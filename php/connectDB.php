<?php

/** The name of the database */
define('DB_NAME', 'rainbow');
/** MySQL database username */
define('DB_USER', 'root');
/** MySQL database password */
define('DB_PASSWORD', '');
/** MySQL hostname */
define('DB_HOST', 'localhost');
/** Port number of DB */
define('DB_PORT', 3306);
/** Database Charset to use in creating database tables */
define('DB_CHARSET', 'utf8');

class DataAccessHelper
{
	static $connection;

	public function connect()
	{
		// Kết nối với cơ sở dữ liệu
		self::$connection = new mysqli(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME, DB_PORT);

		// Kiểm tra kết nối
		if (self::$connection->connect_error) {
			die("Connection failed: " . self::$connection->connect_error);
		}

		// Thiết lập charset
		self::$connection->set_charset(DB_CHARSET);
	}

	public function executeNonQuery($sql)
	{
		// Thực thi câu lệnh không trả về kết quả (INSERT, UPDATE, DELETE)
		return self::$connection->query($sql) === true;
	}

	public function executeQuery($sql)
	{
		// Thực thi câu lệnh trả về kết quả (SELECT)
		return self::$connection->query($sql);
	}

	public function lastIdInsert()
	{
		// Lấy ID vừa chèn cuối cùng
		return self::$connection->insert_id;
	}

	public function close()
	{
		// Đóng kết nối
		if (self::$connection) {
			self::$connection->close();
		}
	}
}
