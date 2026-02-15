# Stage 1: Base setup
FROM python:3.12-slim

# تنظیم متغیرهای محیطی برای جلوگیری از ساخت فایل‌های pyc و بافر شدن لاگ‌ها
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# تنظیم دایرکتوری کاری
WORKDIR /app

# نصب پکیج‌های سیستمی مورد نیاز
# libgl1-mesa-glx و libglib2.0-0 برای OpenCV/YOLO ضروری هستند
# tor برای قابلیت‌های مربوط به دارک‌وب نصب می‌شود (اگر اپلیکیشن خودش پروسه را اجرا کند)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libgl1-mesa-glx \
    libglib2.0-0 \
    tor \
    curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# کپی کردن فایل نیازمندی‌ها و نصب آن‌ها
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# کپی کردن کل سورس کد به داخل کانتینر
COPY . .

# ساخت پوشه geodata برای جلوگیری از ارور (در صورتی که ماونت نشود)
RUN mkdir -p geodata

# ساخت یک کاربر غیر روت برای امنیت بیشتر (اختیاری ولی توصیه شده)
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# پورت پیش‌فرض فلاسک
EXPOSE 8000

# دستور اجرا
CMD ["python", "app.py"]