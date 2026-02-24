# StackEdit 新Logo设计说明

## 设计概念

新Logo采用**渐变科技风格**，体现了现代化的Markdown编辑器特性。

### 设计元素

1. **核心符号**: Markdown标志性的 `#` 井号符号
2. **配色方案**: 多彩渐变（蓝紫色 → 紫色 → 粉红色 → 橙色）
3. **视觉风格**: 圆角矩形背景 + 简洁的白色符号 + 光晕效果

### Logo展示

#### 完整Logo（带文字）
![完整Logo SVG](src/assets/logo.svg)
![完整Logo PNG](src/assets/logo.png)

#### 图标Logo
![图标Logo SVG](src/assets/iconStackedit.svg)
![图标Logo PNG](src/assets/iconStackedit.png)

#### 不同尺寸的图标

| 尺寸 | 预览 | 文件路径 |
|------|------|----------|
| 512x512 | ![512](chrome-app/icon-512.png) | `chrome-app/icon-512.png` |
| 256x256 | ![256](chrome-app/icon-256.png) | `chrome-app/icon-256.png` |
| 128x128 | ![128](chrome-app/icon-128.png) | `chrome-app/icon-128.png` |
| 64x64 | ![64](chrome-app/icon-64.png) | `chrome-app/icon-64.png` |
| 32x32 | ![32](chrome-app/icon-32.png) | `chrome-app/icon-32.png` |
| 16x16 | ![16](chrome-app/icon-16.png) | `chrome-app/icon-16.png` |

## 设计特点

### 1. 渐变科技感
- 使用多层次的渐变色彩，从蓝紫色到橙色的自然过渡
- 体现了现代化、科技化的产品定位

### 2. Markdown特征
- 核心使用 `#` 符号，这是Markdown标题的标志性标记
- 简洁明了，一目了然

### 3. 视觉效果
- 圆角矩形设计，符合现代应用图标的设计趋势
- 白色符号配合彩色背景，对比鲜明
- 添加了微妙的光晕效果，增加立体感和科技感

## 应用位置

新Logo已应用到以下位置：

- ✅ Chrome应用图标（16, 32, 64, 128, 256, 512像素）
- ✅ 网站favicon
- ✅ 应用内Logo
- ✅ 着陆页Logo
- ✅ README.md引用的图标

## 文件清单

### SVG文件（矢量格式）
- `src/assets/logo.svg` - 完整Logo（包含文字）
- `src/assets/iconStackedit.svg` - 纯图标版本
- `static/landing/logo.svg` - 着陆页Logo
- `public/landing/logo.svg` - 公共着陆页Logo

### PNG文件（位图格式）
- `chrome-app/icon-{16,32,64,128,256,512}.png` - 不同尺寸的应用图标
- `src/assets/favicon.png` - 48x48 favicon

### ICO文件
- `src/assets/favicon.ico` - 多尺寸favicon
- `static/landing/favicon.ico` - 着陆页favicon
- `public/landing/favicon.ico` - 公共着陆页favicon

## 下一步

运行 `npm run build` 重新构建项目，新Logo将出现在所有相关页面中。