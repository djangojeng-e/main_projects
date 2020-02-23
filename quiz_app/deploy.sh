#!/usr/bin/zsh
IDENTITY_FILE="$HOME/.ssh/wps12th.pem"
HOST="ubuntu@13.209.99.214"
ORIGIN_SOURCE="$HOME/main_projects/quiz_app/"
DEST_SOURCE="/home/ubuntu@13.209.99.214"
SSH_CMD="ssh -i ${IDENTITY_FILE} ${HOST}"

echo "== runserver 배포 =="

# pip freeze
echo "pip freeze"
"$HOME"/.pyenv/versions/quiz_app/bin/pip freeze > "$HOME"/main_projects/quiz_app/requirements.txt


# 기존 폴더 삭제
echo 'remove server source'
${SSH_CMD} sudo rm -rf ${DEST_SOURCE}


# 로컬에 있는 파일 업로드
echo "upload local source"
${SSH_CMD} mkdir -p ${DEST_SOURCE}
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

