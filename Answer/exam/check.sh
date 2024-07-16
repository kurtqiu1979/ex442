#!/bin/bash

total=0

compare_files() {
  if diff "$1" "$2" > /dev/null; then
    return 0
  else
    return 1
  fi
}

check_kernel_param() {
  param_name="$1"
  value="$2"
  param_value=$(sysctl -a | grep "$param_name" | awk '{print $NF}')
  if [ "$param_value" -eq "$value" ];then
    return 0
  else
    return 1
  fi
}

update_total_and_echo() {
  ((total=total+$1))
  echo "第$2正确，total值加$1"
}

handle_error() {
  echo "第$2错误"
}

execute_test() {
  case "$1" in
    1) if compare_files "exam/1.txt" "1.txt" 1; then update_total_and_echo 1 1; else handle_error 1; fi ;;
    2) if compare_files "exam/2.txt" "2.txt" 1; then update_total_and_echo 1 2; else handle_error 2; fi ;;
    3) if compare_files "exam/3.txt" "3.txt" 1; then update_total_and_echo 1 3; else handle_error 3; fi ;;
    4) tx4 ;;
    5) if check_kernel_param "vm.overcommit_memory" 2; then update_total_and_echo 1 5; else handle_error 5; fi ;;
    6) if check_kernel_param "shmall" 367001; then update_total_and_echo 1 6; else handle_error 6; fi ;;
    7) tx7 ;;
    8) tx8 ;;
    9) tx9 ;;
    10) tx10 ;;
    11) tx11 ;;
    12) tx12 ;;
    13) tx13 ;;
    14) tx14 ;;
    15) if check_kernel_param "vm.dirty_expire_centisecs" 4500; then update_total_and_echo 1 15; else handle_error 15; fi ;;
    16) tx16 ;;
    17) tx17 ;;
    18) tx18 ;;
    19) tx19 ;;
    20) tx20 ;;
    21) tx21 ;;
    22) tx22 ;;
    23) if compare_files "exam/23.txt" "23.txt" 3; then update_total_and_echo 1 23; else handle_error 23; fi ;;
    *) echo "未知测试用例: $1" ;;
  esac
}
tx4() {
  swap_usage=$(free -m | grep -i swap | awk '{print $2}')
  swap_count=$(swapon -s|awk '{print $5}'|grep 5|wc -l)
  if [ "$swap_usage" -gt 2045 ] && [ "$swap_usage" -lt 2050 ] && [ "$swap_count" -eq 2 ]; then
    update_total_and_echo 1 4
  else
    handle_error 4
  fi
}

tx7() {
    update_total_and_echo 1 7
}

tx8() {
  RRS=$(ps -o rss `pgrep realtime`|tail -1)
  mem_count=$(cat 8.txt)
  if [ $mem_count -gt 150 ] && [ $mem_count -lt 210 ];then
    update_total_and_echo 1 8
  else
    handle_error 8
  fi
}

tx9() {
  find_result=$(find /root/.systemtap/cache -name "*.ko")
  if [ $? -eq 0 ];then
    update_total_and_echo 1 9
  else
    handle_error 9
  fi
}

tx10() {
  if [ -f /usr/local/bin/cache-b ];then
    update_total_and_echo 1 10
  else
    handle_error 10
  fi
}

tx11() {
  check_kernel_param "net.core.rmem_default" 131072
  result1=$?
  check_kernel_param "net.core.wmem_default" 131072
  result2=$?
  check_kernel_param "net.core.rmem_max" 196608
  result3=$?
  check_kernel_param "net.core.wmem_max" 196608
  result4=$?

  if [ $result1 -eq 0 ] && [ $result2 -eq 0 ] && [ $result3 -eq 0 ] && [ $result4 -eq 0 ]; then
    update_total_and_echo 1 11
  else
    handle_error 11
  fi
}

tx12() {
  grep '/3' /usr/lib/systemd/system/sysstat-collect.timer > /dev/null
  if [ $? -eq 0 ];then
    update_total_and_echo 1 12
  else
    handle_error 12
  fi
}
tx13() {
  sysctl_tcp_mem=$(sysctl -a | grep net.ipv4.tcp_mem | grep -E '48|72')
  sysctl_tcp_rmem=$(sysctl -a | grep net.ipv4.tcp_rmem | grep -E '98304|147456')
  sysctl_tcp_wmem=$(sysctl -a | grep net.ipv4.tcp_wmem | grep -E '98304|147456')
  if [ -n "$sysctl_tcp_mem" ] && [ -n "$sysctl_tcp_rmem" ] && [ -n "$sysctl_tcp_wmem" ]; then
    update_total_and_echo 1 13
  else
    handle_error 13
  fi
}

tx14() {
  systemctl status monitoring_service.service |grep slice > /dev/null
  if [ $? -eq 0 ];then
    update_total_and_echo 1 14
  else
    handle_error 14
  fi
}

tx15() {
  if check_kernel_param "vm.dirty_expire_centisecs" 4500; then
    update_total_and_echo 1 15
  else
    handle_error 15
  fi
}

tx16() {
  grep LEAK 16.txt > /dev/null
  if [ $? -eq 0 ];then
    update_total_and_echo 1 16
  else
    handle_error 16
  fi
}
tx17() {
  lsmod_st=$(lsmod | grep st)
  st_buffer=$(cat /sys/bus/scsi/drivers/st/fixed_buffer_size)
  if [ -n "$lsmod_st" ] && [ "$st_buffer" -eq 24576 ]; then
    update_total_and_echo 1 17
  else
    handle_error 17
  fi
}

tx18() {
  tuned_adm_active=$(tuned-adm active | grep 442)
  grep_readahead=$(grep readahead /etc/tuned/rh442/tuned.conf | grep 3092)
  if [ -n "$tuned_adm_active" ] && [ -n "$grep_readahead" ]; then
    update_total_and_echo 1 18
  else
    handle_error 18
  fi
}

tx19() {
  status_slice=$(systemctl status httpd | grep slice)
  status_active=$(systemctl status httpd | grep active)
  status_enabled=$(systemctl status httpd | grep enabled)

  if [ -n "$status_slice" ] && [ -n "$status_active" ] && [ -n "$status_enabled" ]; then
    update_total_and_echo 1 19
  else
    handle_error 19
  fi
}

tx20() {
  numa_map=$(cat /proc/$(pgrep firewalld)/numa_maps | awk '{print $2}')
  last_value=$(echo "$numa_map" | tail -1|awk -F: '{print $NF}')

  if [ "$last_value" -eq 2 ]; then
    update_total_and_echo 1 20
  else
    handle_error 20
  fi
}

tx21() {
  search_result=$(grep 'perf stat' 21.txt)

  if [ -n "$search_result" ]; then
    update_total_and_echo 1 21
  else
    handle_error 21
  fi
}

tx22() {
  file_hugepage_fs=$(ls /usr/local/bin/hugepage.fs)
  nr_hugepages=$(sysctl -a | grep 'vm.nr_hugepages =' | awk '{print $NF}')
  mount_hugetlbfs=$(mount | grep 'nodev on /bigpages type hugetlbfs')
  huge_pages_total=$(grep HugePages_Total /proc/meminfo | awk '{print $NF}')

  if [ -e "/bigpages" ] && [ -e "/usr/local/bin/hugepage.fs" ] && [ "$nr_hugepages" -eq 32 ] && [ -n "$mount_hugetlbfs" ] && [ "$huge_pages_total" -eq 32 ]; then
    update_total_and_echo 1 22
  else
    handle_error 22
  fi
}

for test_case in {1..23}; do
  execute_test "$test_case"
done

echo "Total: $total"
