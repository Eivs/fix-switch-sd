#!/bin/bash

rm="sudo rm -rf"
arch="sudo chflags -R arch"

# 获取已挂载的外部磁盘列表
disksExternal=$(mount | awk '/Volumes/ { print $3 }')
diskArray=($disksExternal)

# 提示用户选择 SD 卡
PS3="Select SD card for Nintendo Switch: "
select switchSD in "${diskArray[@]}"; do
    if [[ -n "$switchSD" ]]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

switchSD=$(echo "$switchSD" | sed 's/ /\\ /g')

# 提示用户选择修复选项
echo "What do you want to fix?"
options=("Fix bit Nintendo folders" "Fix bit all files")
select Fix in "${options[@]}"; do
    if [[ -n "$Fix" ]]; then
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

# 创建 .metadata_never_index 文件
sudo touch "$switchSD/.metadata_never_index"

if [ "$Fix" = "Fix bit all files" ]; then
    archFiles=$(find "$switchSD"/* -path "$switchSD" -prune -o -path "$switchSD/emuMMC" -prune -o -path "$switchSD/Emutendo" -prune -o -path "$switchSD/Nintendo" -prune -o -depth 0 -print)

    totalSteps=$(echo "$archFiles" | wc -l)
    currentStep=0

    echo "Fixing bit all files..."
    for archBit in $archFiles; do
        ((currentStep++))
        echo "[$currentStep/$totalSteps] Fixing: $archBit"
        sudo chflags -R arch "$archBit"
    done
fi

if [ "$Fix" = "Fix bit Nintendo folders" ]; then
    NCAs=$(find "$switchSD" -name '*.nca' | grep .nca)

    totalSteps=$(echo "$NCAs" | wc -l)
    currentStep=0

    echo "Fixing bit NCA folders..."
    for nca in $NCAs; do
        ((currentStep++))
        echo "[$currentStep/$totalSteps] Fixing: $nca"
        ncaF=$(echo "$nca" | cut -d'.' -f-1)
        sudo mkdir "$ncaF"
        sudo mv "$nca"/* "$ncaF"
        sudo rm -rf "$nca"
        sudo mv "$ncaF" "$ncaF.nca"
    done
fi

# 删除不必要的文件
find "$switchSD" -name '._*' -delete
find "$switchSD" -name '.DS_Store' -delete
sudo rm -rf "$switchSD/.metadata_never_index"
sudo rm -rf "$switchSD/.Trashes"
sudo rm -rf "$switchSD/.fseventsd*"
sudo rm -rf "$switchSD/.Spotlight-V100"

# 卸载 SD 卡
echo "Unmounting SD card..."
sudo diskutil unmount "$switchSD"
afplay /System/Library/Sounds/Glass.aiff

echo "SwitchSD - Done"
