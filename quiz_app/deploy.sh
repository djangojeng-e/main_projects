#!/usr/bin/zsh
IDENTITY_FILE="~/.ssh/wps12th.pem"
USER="ubuntu"
HOST="13.209.99.214"
TARGET=${USER}@${HOST}
ORIGIN_SOURCE="$HOME/main_projects/quiz_app/"
DEST_SOURCE="/home/ubuntu/main_projects/"
SSH_CMD="ssh -i ${IDENTITY_FILE} ${TARGET}"

echo "== runserver 배포 =="
# 서버 초기 설정

echo "apt update & upgrade & autoremove"
${SSH_CMD} -C 'sudo apt update && sudo DEBIAN_FRONTEND=noninteractive apt dist-upgrade -y && apt -y autoremove'
echo "apt install python3-pip"
${SSH_CMD} -C 'sudo apt -y install python3-pip'

# pip freeze
echo "pip freeze"
"$HOME"/.pyenv/versions/quiz_app/bin/pip freeze > "$HOME"/main_projects/quiz_app/requirements.txt


# 기존 폴더 삭제
echo 'remove server source'
${SSH_CMD} sudo rm -rf ${DEST_SOURCE}


# 로컬에 있는 파일 업로드
echo "upload local source"
${SSH_CMD} mkdir ${DEST_SOURCE}
scp -q -i "${IDENTITY_FILE}" -r "${ORIGIN_SOURCE}" ${HOST}:${DEST_SOURCE}


# pip install
echo "pip install"

${SSH_CMD} pip3 install -q -r /home/ubuntu/main_projects/quiz_app/requirements.txt


echo "screen settings"
# 실행중이던 screen 세션 종료
${SSH_CMD} -C 'screen -X -S runserver quit'
# screen 실행
${SSH_CMD} -C 'screen -S runserver -d -m'
# 실행중인 세션에 명령어 전달
${SSH_CMD} -C "screen -r runserver -X stuff 'sudo python3 /home/ubuntu/main_projects/quiz_app/quiz_app/manage.py runserver 0:80\n'"

echo " finish!"

