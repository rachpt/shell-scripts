#/bin/bash
# Author: rachpt@126.com
# Date: 2019-03-12
# TODO：华中科技大学自动预约羽毛球场地

# 使用crontab 或则 at 命令定时运行
# crontab 规则： 0 8 * * */4 /path/of/dir/auto-appointment.sh # 每周四上午8点运行
# at :  at 8:00 friday /path/of/dir/auto-appointment.sh # 周四上午8点运行
# parameters
pa_name='张三'
pa_no='M201800000'
pa_pwd='password'
my_date="$(date -d '2 days' +%Y-%m-%d)"
log_file="~/auto-appointment.log"

user_agent='User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0'

# change it to your's cookie
cookie='Cookie: JSESSIONID=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx; BIGipServerpool-tyb-cggl-yysf=xxxxxxxxxxxxxxxxxxxx'

token="$(http 'https://pecg.hust.edu.cn/cggl/front/yuyuexz' "$cookie" "$user_agent"|grep 'token.*hidden'|head -1|grep -Eio '[a-z0-9]{32,}')"

# choosetime=294 # 1号场地
# choosetime=302 # 8号场地
# changdibh=69 # 西边体育馆 羽毛球

for i in {1..8}; do
  if http --ignore-stdin -f POST 'http://pecg.hust.edu.cn/cggl/front/step2' starttime='20:00:00' endtime='22:00:00' partnerCardType=1 partnerName="$pa_name" partnerSchoolNo="$pa_no" partnerPwd="$pa_pwd" choosetime="$((i + 294))" changdibh=69 date="$my_date" token="$token" token="$token" &> /dev/null; then
    echo "已经成功my_date第$i号场地" >> "$log_file"
    break
  else
    case $? in
      2) echo "$i Request timed out!" >> "$log_file" ;;
      3) echo "$i Unexpected HTTP 3xx Redirection!" >> "$log_file" ;;
      4) echo "$i HTTP 4xx Client Error!" >> "$log_file" ;;
      5) echo "$i HTTP 5xx Server Error!" >> "$log_file" ;;
      6) echo "$i Exceeded --max-redirects=<n> redirects!" >> "$log_file" ;;
      *) echo "$i Other Error!" >> "$log_file" ;;
    esac
  fi
done
