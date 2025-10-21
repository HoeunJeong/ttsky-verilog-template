<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

여러 Master가 동시에 Slave에게 접근할 때 어떤 Master에게 버스의 사용권을 우선적으로 줄지를 결정하는 'AXI Arbiter'를 설계하였습니다.

첫 번째는 'Fixed Priority'인데 말 그대로 고정된 우선순위를 갖는 방식입니다. 6개의 Master를 M0 ~ M5라 했을 때 숫자 인덱스가 낮을수록 높은 우선순위를 갖습니다. 예를 들어 M2, M4가 동시에 Request를 보냈을 경우 M2가 먼저 Service를 받게 됩니다. 이러한 방식의 문제점은 우선순위가 상대적으로 낮은 Master들은 보다 상위의 Master들이 버스를 독점하게 될 경우 대기하는 시간이 지나치게 길어진다는 점입니다. 이런 점을 방지하기 위해 'Aging'처리를 해주었는데 이는 Master별로 Request를 보내고도 Service 받지 못한 시간을 카운트하여 일정시간 이상이 되면 일시적으로 우선순위를 최상위로 높여주는 방식입니다.  

두 번째는 'LRG Scheme'으로 LRG는 Least Recently Granted의 약자입니다. 이 방식은 가장 최근에 Service를 받지 못한 Master에게 높은 우선순위를 주는 것 입니다. 이러한 방식은 이전 Stage에서 버스를 사용한 Master를 다음 Stage에서는 최하위의 우선순위로 내림으로써 구현할 수 있습니다. 가령 초기의 우선순위가 M0 > M1 > M2 > M3 > M4 > M5인 상태에서 M3가 Request를 보내고 Service를 받았다면 다음 Stage에서는 M3가 최하위가 되어 M0 > M1 > M2 > M4 > M5 > M3가 되는 것입니다.

## How to test

Fixed Priority에서 AWVALID [5:0]은 요청을 보내는 Master들이고 M_sel [5:0]은 우선순위에 의해 선택된 Master를 나타냅니다. 또한 aging_cnt [5:0]로 각각의 Master가 Request를 보냈지만 버스의 사용권을 받지 못한 시간을 카운트하여 일정한 파라미터 값에 도달하면 우선순위를 최상위로 올려줍니다. 테스트 벤치에서 AWVALID 값을 무작위로 생성하고 M_sel를 관찰하여 동작을 확인할 수 있습니다. 또한 Aging이 잘 적용되었는지 검증하기 위해 특정 Master가 Request를 보내는 동안 계속해서 상위 우선순위의 Master들이 버스를 점유 하도록 AWVALID 입력을 만들고 특정 시간에 도달했을 때의 M_sel를 확인해야합니다.

LRG Scheme의 경우 조금 다르게 구현하였는데 6비트짜리 priority0 ~ priority5를 각각 만들었습니다. 초기에 priority0 ~ priority5에 One-Hot 방식으로 각각 00_0001 ~ 10_0000을 할당합니다. 이는 00_0001(M0)이 priority0, 즉 최상위 우선순위임을 뜻합니다. 예시로 M3가 버스를 사용했을 경우 다음 Stage에서는 최하위의 우선순위로 가게 되며 M3보다 하위의 우선순위에 있는 M4, M5가 각각 한단계씩 상승하게 됩니다. 이를 마치 우선순위를 한단계씩 Shift하는 방식으로 이전 Stage의 priority4, priority5를 다음 Stage의 priority3, priority4에 할당하여 한단계씩 올리고 priority3은 다음 Stage의 priority5에 할당하여 최하위 우선순위로 내립니다. Fixed Priority 방식처럼 AWVALID에 대한 M_sel를 관찰하면 되고 시뮬레이션 시 스코프로 priority0 ~ priority5를 Waveform에 추가하여 버스의 사용권이 변함에 따라 우선순위가 어떻게 변하는지 관찰할 수 있습니다. 


## External hardware

이 프로젝트는 외부의 추가적인 하드웨어를 필요로 하지 않습니다.
