<h1>Hệ thống Giám sát An ninh và Cảnh báo cháy tích hợp AI (8051-Based Multi-Purpose Security System)</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Model-YOLO11-orange.svg" alt="Model: YOLO11">
  <img src="https://img.shields.io/badge/Platform-AT89C51-blue.svg" alt="Platform: 8051">
  <img src="https://img.shields.io/badge/Language-Assembly%20%7C%20Python-red.svg" alt="Language: Assembly | Python">
  <img src="https://img.shields.io/badge/Tools-Proteus%20%7C%20KeilC-green.svg" alt="Tools: Proteus | KeilC">
</p>

<h2>1. Giới thiệu đề tài</h2>
<p>
Dự án xây dựng một hệ thống bảo vệ toàn diện sử dụng <b>kiến trúc Hybrid</b>, kết hợp giữa sức mạnh thị giác máy tính của AI (High-level) và độ tin cậy của các cảm biến vật lý (Low-level). Hệ thống không chỉ giải quyết bài toán báo động giả trong giám sát an ninh mà còn tích hợp khả năng phòng cháy chữa cháy (PCCC) thông minh thông qua việc giám sát nhiệt độ và khói thời gian thực.
</p>

<h2>2. Tính năng chính</h2>
<ul>
  <li><b>Nhận diện đa mục tiêu:</b> Sử dụng mô hình YOLO11 để phân loại chính xác đối tượng là con người (nhãn <i>"person"</i>) và các dấu hiệu cháy nổ (nhãn <i>"fire/smoke"</i>).</li>
  <li><b>Xác thực kép (Dual-Verification):</b> Kết hợp dữ liệu hình ảnh từ AI với dữ liệu thời gian thực từ cảm biến khói/nhiệt độ thông qua bộ chuyển đổi <b>ADC 0804</b> để tối ưu hóa độ chính xác của báo động.</li>
  <li><b>Phản hồi tức thời:</b> Sử dụng lập trình Assembly tối ưu trên 8051 để điều khiển còi hú, đèn báo và hiển thị trạng thái ngay khi phát hiện sự cố.</li>
  <li><b>Giao diện trực quan:</b> Hiển thị nhiệt độ môi trường và trạng thái hoạt động của hệ thống lên màn hình <b>LCD 16x2</b>.</li>
</ul>

<h2>3. Danh sách linh kiện (Mô phỏng Proteus)</h2>
<table width="100%">
  <thead>
    <tr align="left" style="background-color: #f2f2f2;">
      <th>Linh kiện</th>
      <th>Keyword</th>
      <th>Vai trò</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>MCU</b></td>
      <td><code>AT89C51</code></td>
      <td>Trung tâm điều khiển, xử lý logic tầng thấp và ngắt.</td>
    </tr>
    <tr>
      <td><b>Interface</b></td>
      <td><code>COMPIM</code></td>
      <td>Cổng COM ảo kết nối script Python (AI Engine) với Proteus.</td>
    </tr>
    <tr>
      <td><b>Converter</b></td>
      <td><code>ADC 0804</code></td>
      <td>Chuyển đổi tín hiệu Analog từ cảm biến nhiệt độ/khói sang kỹ thuật số.</td>
    </tr>
    <tr>
      <td><b>Display</b></td>
      <td><code>LCD 16X2</code></td>
      <td>Hiển thị thông số nhiệt độ và trạng thái "Bật/Tắt" hệ thống.</td>
    </tr>
    <tr>
      <td><b>Output</b></td>
      <td><code>BUZZER / LED</code></td>
      <td>Phát tín hiệu cảnh báo âm thanh và ánh sáng khi có xâm nhập hoặc cháy.</td>
    </tr>
    <tr>
      <td><b>Input</b></td>
      <td><code>BUTTON</code></td>
      <td>Nút nhấn điều khiển chế độ hệ thống thông qua ngắt ngoài.</td>
    </tr>
  </tbody>
</table>

<h2>4. Giao thức truyền thông (UART)</h2>
<p>Hệ thống sử dụng chuẩn UART với Baudrate <b>9600 bps</b> để truyền tải mã lệnh giữa PC và 8051:</p>
<ul>
  <li><b>Mã 'A' (Alarm):</b> Kích hoạt báo động khi AI phát hiện có người xâm nhập trái phép.</li>
  <li><b>Mã 'F' (Fire):</b> Kích hoạt báo động khẩn cấp khi phát hiện dấu hiệu hỏa hoạn qua Camera.</li>
</ul>

<h2>5. Quy trình vận hành</h2>

<h3>Bước 1: Chuẩn bị Firmware</h3>
<p>Sử dụng <b>Keil C51</b> để biên dịch mã nguồn <i>Assembly</i> thành file <code>.hex</code>. Sau đó nạp vào AT89C51 trong Proteus với thạch anh <b>11.0592MHz</b>.</p>

<h3>Bước 2: Thiết lập kết nối Serial</h3>
<ol>
  <li>Tạo cặp cổng COM ảo bằng <b>VSPD</b> (Ví dụ: COM1 - COM2).</li>
  <li>Trong <b>Proteus (COMPIM):</b> Chọn Physical Port là <code>COM1</code>.</li>
  <li>Trong <b>Python Script:</b> Cấu hình cổng kết nối là <code>COM2</code>.</li>
</ol>

<h3>Bước 3: Khởi chạy</h3>
<pre><code># Cài đặt thư viện
pip install ultralytics pyserial opencv-python

# Chạy AI Engine
python main.py</code></pre>

