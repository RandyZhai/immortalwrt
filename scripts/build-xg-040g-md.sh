#!/bin/bash
# ============================================================
# ImmortalWrt 本地编译脚本 - Nokia XG-040G-MD
# 包含: iStore, ZeroTier, Docker, 配置导航
# ============================================================
set -e

echo "=============================================="
echo " ImmortalWrt XG-040G-MD 编译脚本"
echo " 目标: Nokia XG-040G-MD (UBI)"
echo " 平台: Airoha AN7581 / ARM64 Cortex-A53"
echo "=============================================="

# === 1. 检查编译环境 ===
echo "[1/6] 检查编译环境..."
if [ "$(id -u)" = "0" ]; then
    echo "错误: 请不要使用 root 用户运行此脚本"
    exit 1
fi

# === 2. 添加第三方软件源 ===
echo "[2/6] 配置 feeds..."

# 备份原始 feeds
if [ ! -f feeds.conf.default.bak ]; then
    cp feeds.conf.default feeds.conf.default.bak
fi

# 添加 kenzok8 软件源
grep -q "kenzok8/openwrt-packages" feeds.conf.default 2>/dev/null || \
    echo "src-git kenzo https://github.com/kenzok8/openwrt-packages" >> feeds.conf.default
grep -q "kenzok8/small" feeds.conf.default 2>/dev/null || \
    echo "src-git small https://github.com/kenzok8/small" >> feeds.conf.default

echo "当前 feeds.conf.default:"
cat feeds.conf.default

# === 3. 更新和安装 feeds ===
echo "[3/6] 更新 feeds..."
./scripts/feeds update -a

# 清理可能冲突的包
rm -rf feeds/luci/applications/luci-app-mosdns 2>/dev/null || true
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,sing*,smartdns} 2>/dev/null || true

echo "[4/6] 安装 feeds..."
./scripts/feeds install -a

# === 4. 应用配置文件 ===
echo "[5/6] 应用编译配置..."
if [ -f "configs/xg-040g-md.config" ]; then
    cp configs/xg-040g-md.config .config
else
    echo "警告: configs/xg-040g-md.config 不存在，使用默认配置"
fi

# 展开完整配置
make defconfig

# === 5. 下载源码包 ===
echo "[6/6] 下载源码包..."
make download -j$(nproc) V=s 2>&1 | tee logs/download.log

# === 6. 开始编译 ===
echo ""
echo "=============================================="
echo " 开始编译固件..."
echo " 预计耗时: 1-6 小时 (取决于网络和CPU)"
echo "=============================================="
make -j$(nproc) V=s 2>&1 | tee logs/build.log || make -j1 V=s

# === 完成 ===
echo ""
echo "=============================================="
echo " 编译完成!"
echo " 固件位置: bin/targets/airoha/an7581/"
echo "=============================================="
ls -lh bin/targets/airoha/an7581/ 2>/dev/null || echo "请检查编译日志"
