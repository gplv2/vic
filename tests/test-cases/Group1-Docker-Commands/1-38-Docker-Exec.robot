# Copyright 2016-2017 VMware, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#	http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

*** Settings ***
Documentation  Test 1-38 - Docker Exec
Resource  ../../resources/Util.robot
Suite Setup  Install VIC Appliance To Test Server
Suite Teardown  Cleanup VIC Appliance On Test Server

*** Test Cases ***
Exec -d
    ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} pull busybox
    Should Be Equal As Integers  ${rc}  0
    Should Not Contain  ${output}  Error
    ${rc}  ${id}=  Run And Return Rc And Output  docker %{VCH-PARAMS} run -d busybox /bin/top -d 600
    Should Be Equal As Integers  ${rc}  0
    ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} exec -d ${id} /bin/touch tmp/force
    Should Be Equal As Integers  ${rc}  0
    ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} exec ${id} /bin/ls -al /tmp/force
    Should Be Equal As Integers  ${rc}  0
    Should Contain  ${output}  force

Exec Echo
    ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} pull busybox
    Should Be Equal As Integers  ${rc}  0
    Should Not Contain  ${output}  Error
    ${rc}  ${id}=  Run And Return Rc And Output  docker %{VCH-PARAMS} run -d busybox /bin/top -d 600
    Should Be Equal As Integers  ${rc}  0
    :FOR  ${idx}  IN RANGE  0  5
    \   ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} exec ${id} /bin/echo "Help me, Obi-Wan Kenobi. You're my only hope."
    \   Should Be Equal As Integers  ${rc}  0
    \   Should Be Equal As Strings  ${output}  Help me, Obi-Wan Kenobi. You're my only hope.

Exec Echo -i
    ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} pull busybox
    Should Be Equal As Integers  ${rc}  0
    Should Not Contain  ${output}  Error
    ${rc}  ${id}=  Run And Return Rc And Output  docker %{VCH-PARAMS} run -d busybox /bin/top -d 600
    Should Be Equal As Integers  ${rc}  0
    :FOR  ${idx}  IN RANGE  0  5
    \   ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} exec -i ${id} /bin/echo "Your eyes can deceive you. Don't trust them."
    \   Should Be Equal As Integers  ${rc}  0
    \   Should Be Equal As Strings  ${output}  Your eyes can deceive you. Don't trust them.

Exec Echo -t
    ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} pull busybox
    Should Be Equal As Integers  ${rc}  0
    Should Not Contain  ${output}  Error
    ${rc}  ${id}=  Run And Return Rc And Output  docker %{VCH-PARAMS} run -d busybox /bin/top -d 600
    Should Be Equal As Integers  ${rc}  0
    :FOR  ${idx}  IN RANGE  0  5
    \   ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} exec -t ${id} /bin/echo "Do. Or do not. There is no try."
    \   Should Be Equal As Integers  ${rc}  0
    \   Should Be Equal As Strings  ${output}  Do. Or do not. There is no try.

Exec Sort
    ${rc}  ${tmp}=  Run And Return Rc And Output  mktemp -d -p /tmp
    Should Be Equal As Integers  ${rc}  0
    ${fifo}=  Catenate  SEPARATOR=/  ${tmp}  fifo
    ${rc}  ${output}=  Run And Return Rc And Output  mkfifo ${fifo}
    Should Be Equal As Integers  ${rc}  0
    ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} pull busybox
    Should Be Equal As Integers  ${rc}  0
    Should Not Contain  ${output}  Error
    ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} run -d busybox /bin/top -d 600
    Should Be Equal As Integers  ${rc}  0
    :FOR  ${idx}  IN RANGE  0  5
    \     Start Process  docker %{VCH-PARAMS} exec ${output} /bin/sort < ${fifo}  shell=True  alias=custom
    \     Run  echo one > ${fifo}
    \     ${ret}=  Wait For Process  custom
    \     Log  ${ret.stderr}
    \     Should Be Empty  ${ret.stdout}
    \     Should Be Equal As Integers  ${ret.rc}  0
    \     Should Be Empty  ${ret.stderr}
    Run  rm -rf ${tmp}

Exec Sort -i
    ${rc}  ${tmp}=  Run And Return Rc And Output  mktemp -d -p /tmp
    Should Be Equal As Integers  ${rc}  0
    ${fifo}=  Catenate  SEPARATOR=/  ${tmp}  fifo
    ${rc}  ${output}=  Run And Return Rc And Output  mkfifo ${fifo}
    Should Be Equal As Integers  ${rc}  0
    ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} pull busybox
    Should Be Equal As Integers  ${rc}  0
    Should Not Contain  ${output}  Error
    ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} run -d busybox /bin/top -d 600
    Should Be Equal As Integers  ${rc}  0
    :FOR  ${idx}  IN RANGE  0  5
    \     Start Process  docker %{VCH-PARAMS} exec -i ${output} /bin/sort < ${fifo}  shell=True  alias=custom
    \     Run  echo one > ${fifo}
    \     ${ret}=  Wait For Process  custom
    \     Log  ${ret.stderr}
    \     Should Be Equal  ${ret.stdout}  one
    \     Should Be Equal As Integers  ${ret.rc}  0
    \     Should Be Empty  ${ret.stderr}
    Run  rm -rf ${tmp}

Exec NonExisting
    ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} pull busybox
    Should Be Equal As Integers  ${rc}  0
    Should Not Contain  ${output}  Error
    ${rc}  ${id}=  Run And Return Rc And Output  docker %{VCH-PARAMS} run -d busybox /bin/top -d 600
    Should Be Equal As Integers  ${rc}  0
    :FOR  ${idx}  IN RANGE  0  5
    \   ${rc}  ${output}=  Run And Return Rc And Output  docker %{VCH-PARAMS} exec ${id} /NonExisting
    \   Should Be Equal As Integers  ${rc}  0
    \   Should Contain  ${output}  no such file or directory
