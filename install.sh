#!/bin/bash

# -e: 오류 시 즉시 중단
# -u: 정의되지 않은 변수 사용 시 오류
# -o pipefail: 파이프라인 오류 감지
set -euo pipefail

# --- 자동화 환경을 위한 핵심 설정 ---
# DEBIAN_FRONTEND=noninteractive : 패키지 설치 시 어떤 질문도 하지 않도록 설정
export DEBIAN_FRONTEND=noninteractive

echo "🚀 Coder Dotfiles: 폰트 설치 스크립트를 시작합니다 (자동화 환경 최적화 버전)"

# -------------------------------------------------------------
# 1. sudo 권한 확인 및 설정 (가장 중요!)
# -------------------------------------------------------------
# 'coder' 유저가 비밀번호 없이 sudo를 사용하도록 설정합니다.
# 이 부분이 없으면 Coder 빌드가 멈출 수 있습니다.
# 스크립트가 이미 root로 실행중일 경우를 대비하여 id -u로 확인합니다.
if [ "$(id -u)" -ne 0 ]; then
    echo "🔧 일반 유저 권한입니다. 비밀번호 없는 sudo를 설정합니다."
    # sudo가 설치되어 있지 않다면 설치부터 진행
    if ! command -v sudo &> /dev/null; then
        apt-get update
        apt-get install -y sudo
    fi
    echo "coder ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/coder-nopasswd
else
    echo "👑 root 권한으로 실행 중입니다. sudo 설정은 건너뜁니다."
fi

# -------------------------------------------------------------
# 2. Microsoft Core Fonts EULA 자동 동의
# -------------------------------------------------------------
echo "👍 MS Core Fonts 라이선스에 미리 동의합니다."
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections

# -------------------------------------------------------------
# 3. 필요한 패키지 설치
# -------------------------------------------------------------
echo "📦 패키지 목록을 업데이트하고 필요한 패키지를 설치합니다."
# add-apt-repository를 위한 software-properties-common 설치
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    software-properties-common \
    ca-certificates \
    fontconfig \
    ttf-mscorefonts-installer

# Ubuntu 22.04 이상에서 multiverse 저장소가 필요할 수 있음
# sudo add-apt-repository multiverse
# sudo apt-get update
# sudo apt-get install -y ttf-mscorefonts-installer

# 간혹 설정이 덜 끝나는 경우를 대비
sudo dpkg --configure -a

# -------------------------------------------------------------
# 4. 폰트 캐시 재생성 및 Matplotlib 캐시 삭제
# -------------------------------------------------------------
echo "🔄 폰트 캐시를 다시 빌드합니다..."
sudo fc-cache -f -v

echo "🧹 Matplotlib 캐시를 정리합니다..."
# $HOME 변수가 coder 유저의 홈 디렉토리(/home/coder)를 가리키도록 함
MATPLOTLIB_CACHE_DIR="/home/coder/.cache/matplotlib"
if [ -d "$MATPLOTLIB_CACHE_DIR" ]; then
    rm -rf "$MATPLOTLIB_CACHE_DIR"
    echo "   - Matplotlib 캐시 삭제 완료."
else
    echo "   - Matplotlib 캐시가 존재하지 않아 건너뜁니다."
fi

echo "✅ 모든 폰트 설치 및 설정이 성공적으로 완료되었습니다!"
