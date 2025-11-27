// lib/core/constants/app_strings.dart
class AppStrings {
  // App
  static const String appName = 'Quản Lý Đồ Cổ';
  static const String appSubtitle = 'Quản lý bộ sưu tập quý giá của bạn';
  
  // Auth
  static const String login = 'Đăng Nhập';
  static const String signup = 'Đăng Ký';
  static const String email = 'Email';
  static const String password = 'Mật khẩu';
  static const String dontHaveAccount = 'Chưa có tài khoản? Đăng ký';
  static const String alreadyHaveAccount = 'Đã có tài khoản? Đăng nhập';
  
  // Home
  static const String antiqueCollection = 'Bộ Sưu Tập Đồ Cổ';
  static const String search = 'Tìm kiếm';
  static const String statistics = 'Thống kê';
  static const String addItem = 'Thêm Đồ';
  static const String offlineMode = 'Chế độ Offline';
  static const String all = 'Tất cả';
  
  // Categories
  static const String furniture = 'Đồ gỗ';
  static const String ceramics = 'Gốm sứ';
  static const String paintings = 'Tranh vẽ';
  static const String jewelry = 'Trang sức';
  static const String textiles = 'Vải dệt';
  static const String sculptures = 'Điêu khắc';
  static const String books = 'Sách cổ';
  static const String coins = 'Tiền xu';
  static const String stamps = 'Tem';
  static const String instruments = 'Nhạc cụ';
  static const String others = 'Khác';
  
  // Add/Edit Item
  static const String addNewItem = 'Thêm Đồ Mới';
  static const String editItem = 'Sửa Thông Tin';
  static const String save = 'Lưu';
  static const String cancel = 'Hủy';
  
  // Form Fields
  static const String images = 'Hình ảnh';
  static const String gallery = 'Thư viện';
  static const String camera = 'Máy ảnh';
  static const String basicInformation = 'Thông tin cơ bản';
  static const String itemName = 'Tên đồ vật';
  static const String category = 'Danh mục';
  static const String description = 'Mô tả';
  static const String valueAndCondition = 'Giá trị & Tình trạng';
  static const String estimatedValue = 'Giá trị ước tính (VNĐ)';
  static const String condition = 'Tình trạng';
  static const String originAndHistory = 'Nguồn gốc & Lịch sử';
  static const String origin = 'Xuất xứ/Địa điểm';
  static const String period = 'Thời kỳ/Niên đại';
  static const String acquisitionDate = 'Ngày mua/nhận';
  static const String provenance = 'Nguồn gốc (Lịch sử sở hữu)';
  
  // Conditions
  static const String excellent = 'Xuất sắc';
  static const String good = 'Tốt';
  static const String fair = 'Khá';
  static const String poor = 'Kém';
  static const String restorationNeeded = 'Cần phục chế';
  
  // Item Detail
  static const String edit = 'Sửa';
  static const String delete = 'Xóa';
  static const String created = 'Tạo lúc';
  static const String lastUpdated = 'Cập nhật';
  
  // Delete Dialog
  static const String deleteItem = 'Xóa Đồ Vật';
  static const String deleteConfirm = 'Bạn có chắc muốn xóa';
  
  // Search
  static const String searchItems = 'Tìm kiếm đồ vật...';
  static const String startSearching = 'Bắt đầu tìm kiếm';
  static const String noResultsFound = 'Không tìm thấy kết quả';
  static const String enterKeywords = 'Nhập từ khóa để tìm kiếm';
  static const String tryDifferentKeywords = 'Thử từ khóa khác';
  
  // Statistics
  static const String totalItems = 'Tổng số đồ';
  static const String totalValue = 'Tổng giá trị';
  static const String averageValue = 'Giá trị trung bình';
  static const String itemsByCategory = 'Đồ vật theo danh mục';
  static const String items = 'đồ';
  
  // Empty States
  static const String noItemsYet = 'Chưa có đồ vật';
  static const String startBuilding = 'Bắt đầu xây dựng bộ sưu tập bằng cách thêm đồ cổ đầu tiên';
  
  // Validation
  static const String pleaseEnterItemName = 'Vui lòng nhập tên đồ vật';
  static const String pleaseEnterDescription = 'Vui lòng nhập mô tả';
  static const String pleaseEnterValue = 'Vui lòng nhập giá trị';
  static const String pleaseEnterValidNumber = 'Vui lòng nhập số hợp lệ';
  static const String pleaseAddImage = 'Vui lòng thêm ít nhất 1 hình ảnh';
  static const String pleaseEnterEmail = 'Vui lòng nhập email';
  static const String pleaseEnterValidEmail = 'Vui lòng nhập email hợp lệ';
  static const String pleaseEnterPassword = 'Vui lòng nhập mật khẩu';
  static const String passwordTooShort = 'Mật khẩu phải có ít nhất 6 ký tự';
  
  // Messages
  static const String itemAddedSuccess = 'Đã thêm đồ vật thành công';
  static const String itemUpdatedSuccess = 'Đã cập nhật thành công';
  static const String itemDeletedSuccess = 'Đã xóa thành công';
  static const String error = 'Lỗi';
  static const String somethingWentWrong = 'Có lỗi xảy ra';
  static const String tryAgain = 'Thử lại';
  static const String noInternetConnection = 'Không có kết nối Internet';
  
  // Auth Errors
  static const String userNotFound = 'Không tìm thấy người dùng';
  static const String wrongPassword = 'Sai mật khẩu';
  static const String emailInUse = 'Email đã được sử dụng';
  static const String weakPassword = 'Mật khẩu quá yếu';
  static const String invalidEmail = 'Email không hợp lệ';
  static const String authFailed = 'Xác thực thất bại';
  
  // Hints
  static const String descriptionHint = 'Mô tả chi tiết về đồ vật';
  static const String periodHint = 'VD: Thời Trần, Thời Lê, Thế kỷ 19';
  static const String provenanceHint = 'Ghi lại lịch sử và chủ sở hữu trước đây';
}