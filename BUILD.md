# ImmortalWrt 编译指南 — Nokia XG-040G-MD

## 📋 固件说明

| 项目 | 说明 |
|------|------|
| **目标设备** | Nokia XG-040G-MD (UBI) |
| **SoC** | Airoha AN7581 |
| **架构** | ARM64 Cortex-A53 |
| **内核** | Linux 6.18 |
| **闪存布局** | UBI (推荐) |

### 内置功能

| 功能 | 说明 |
|------|------|
| 🏪 **iStore** | 应用商店，在线安装/管理 OpenWrt 软件包 |
| 🌐 **ZeroTier** | 虚拟局域网，远程设备组网 |
| 🐳 **Docker** | 容器运行时 + Dockerman 管理面板 |
| 🧭 **配置导航** | LuCI Web 管理界面 (中文) + Argon 主题 |

---

## 🚀 方式一：GitHub Actions 在线编译

### 1. Fork 并启用 Actions

1. Fork 本仓库到你的 GitHub 账号
2. 进入仓库 `Settings` → `Actions` → `General`
3. 选择 **"Allow all actions and reusable workflows"**
4. 确保 **"Read and write permissions"** 已勾选

### 2. 手动触发编译

1. 进入仓库 `Actions` 标签页
2. 左侧选择 **"Build XG-040G-MD ImmortalWrt"**
3. 点击 **"Run workflow"** 下拉按钮
4. 可选勾选 "上传到 Release" 将固件发布到 Release
5. 点击绿色 **"Run workflow"** 按钮

### 3. 下载固件

- 编译完成后（约 2-4 小时），进入该次运行的详情页
- 在 **Artifacts** 区域下载 `ImmortalWrt-XG-040G-MD-xxxxx`
- 解压后获得固件文件

### 4. 固件文件说明

| 文件 | 用途 |
|------|------|
| `*-sysupgrade.itb` | **推荐** — UBI 格式升级固件 |
| `*-sysupgrade.bin` | 标准格式升级固件 |
| `*-preloader.bin` | Bootloader 预加载程序 |
| `*-bl31-uboot.fip` | BL31 + U-Boot 固件 |
| `sha256sums` | 校验文件 |

### 5. 定时自动编译

工作流已配置为每周自动编译一次（北京时间周日上午 8:00）。可在 `.github/workflows/build-xg-040g-md.yml` 中修改 `cron` 表达式调整频率。

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'   # UTC 时间，周日上午 0:00
```

### 6. 上传到 Release

手动触发时勾选 **"上传到 Release"**，编译完成后会自动创建/更新 `XG-040G-MD` 标签的 Release。

---

## 💻 方式二：本地编译

### 环境要求

- **系统**: Debian 11+ / Ubuntu 22.04+ (推荐)
- **CPU**: AMD64，4 核及以上
- **内存**: 4GB 以上
- **磁盘**: 25GB 以上可用空间
- **网络**: 需要能访问 GitHub（下载源码）

### 快速开始

```bash
# 1. 安装编译依赖
sudo apt update -y
sudo apt full-upgrade -y
sudo apt install -y ack antlr3 asciidoc autoconf automake autopoint binutils bison build-essential \
  bzip2 ccache clang cmake cpio curl device-tree-compiler ecj fastjar flex gawk gettext gcc-multilib \
  g++-multilib git gnutls-dev gperf haveged help2man intltool lib32gcc-s1 libc6-dev-i386 libelf-dev \
  libglib2.0-dev libgmp3-dev libltdl-dev libmpc-dev libmpfr-dev libncurses-dev libpython3-dev \
  libreadline-dev libssl-dev libtool libyaml-dev libz-dev lld llvm lrzsz mkisofs msmtp nano \
  ninja-build p7zip p7zip-full patch pkgconf python3 python3-pip python3-ply python3-docutils \
  python3-pyelftools qemu-utils re2c rsync scons squashfs-tools subversion swig texinfo uglifyjs \
  upx-ucl unzip vim wget xmlto xxd zlib1g-dev zstd

# 2. 克隆仓库
git clone https://github.com/RandyZhai/immortalwrt.git
cd immortalwrt

# 3. 一键编译
chmod +x scripts/build-xg-040g-md.sh
./scripts/build-xg-040g-md.sh
```

### 自定义编译

```bash
# 使用 seed config
cp configs/xg-040g-md.config .config

# 如需自定义调整
make menuconfig

# 确认配置
make defconfig

# 下载源码
make download -j$(nproc) V=s

# 开始编译
make -j$(nproc) V=s
```

---

## 📦 刷入方法

### UBI 版本（推荐）

```bash
# 通过 LuCI 系统 → 备份/升级 → 刷写新的固件
# 或通过命令行
sysupgrade -v /tmp/immortalwrt-airoha-an7581-nokia_xg-040g-md-ubi-sysupgrade.itb
```

### 注意事项

- 首次刷入建议使用 `sysupgrade.itb` 格式
- 刷机前请备份当前固件和配置
- 刷机后首次启动可能需要 2-3 分钟
- 默认 IP: `192.168.1.1`，用户名: `root`，密码: (空)
- 刷机后建议执行 `firstboot` 清除旧配置

---

## 🔧 添加更多软件包

编辑 `configs/xg-040g-md.config` 添加 `CONFIG_PACKAGE_*=y` 条目，或在 `make menuconfig` 中交互式选择。

常用第三方 feeds 已内置：
- `kenzo` → https://github.com/kenzok8/openwrt-packages
- `small` → https://github.com/kenzok8/small

---

## 📂 文件结构

```
├── .github/workflows/
│   └── build-xg-040g-md.yml    # GitHub Actions 编译工作流
├── configs/
│   └── xg-040g-md.config       # XG-040G-MD 编译配置
├── scripts/
│   └── build-xg-040g-md.sh     # 本地一键编译脚本
└── README.md
```
