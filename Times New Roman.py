#!/bin/bash

# -e: 스크립트 실행 중 오류가 발생하면 즉시 중단
# -u: 정의되지 않은 변수를 사용하면 오류 발생
# -o pipefail: 파이프라인에서 중간 명령어가 실패해도 전체 실패로 처리
set -euo pipefail

echo "🚀 Coder Dotfiles: 초기 폰트 설치를 시작합니다..."

# -------------------------------------------------------------
# Microsoft Core Fonts (ttf-mscorefonts-installer) EULA 자동 동의
# 이 부분이 없으면 설치 중간에 멈춰버립니다. 아주 중요해요!
# -------------------------------------------------------------
echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections

# 패키지 목록 업데이트 및 필요한 패키지 설치
# -y 옵션: 모든 질문에 자동으로 'yes'로 답하여 중단 없이 설치 진행
sudo apt-get update
sudo apt-get install -y fontconfig ttf-mscorefonts-installer

# 간혹 패키지 설정이 덜 끝나는 경우를 대비한 명령어
sudo dpkg --configure -a

# 폰트 캐시 재생성
echo "🔄 폰트 캐시를 다시 빌드합니다..."
sudo fc-cache -f -v

# Matplotlib 캐시 삭제 (새 폰트를 바로 인식하도록)
# -d: 해당 디렉토리가 존재하는지 확인
echo "🧹 Matplotlib 캐시를 정리합니다..."
if [ -d "$HOME/.cache/matplotlib" ]; then
    rm -rf "$HOME/.cache/matplotlib"
    echo "   - Matplotlib 캐시 삭제 완료."
else
    echo "   - Matplotlib 캐시가 존재하지 않아 건너뜁니다."
fi

echo "✅ 모든 폰트 설치 및 설정이 완료되었습니다!"