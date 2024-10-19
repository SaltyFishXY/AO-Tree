import { message, createDataItemSigner, result } from '@permaweb/aoconnect';

const processid = "7FKJJB-XwbL9ufVAkt_j0WEoZsZMQ7DsAcj-E7jF_2c";  // 替换为实际的 AO 进程 ID
let walletAddress = '';
let tokenCount = 0;  // 用户当前的代币数量
const rainCost = 20; // 降雨效果花费的代币数量
const donateCost = 50; // 爱心效果花费的代币数量

// 连接钱包
async function connectWallet() {
  try {
    await window.arweaveWallet.connect(['SIGN_TRANSACTION', 'ACCESS_ADDRESS']);
    walletAddress = await window.arweaveWallet.getActiveAddress();
    console.log('钱包已连接:', walletAddress);
  } catch (error) {
    console.error('连接钱包失败:', error);
  }
}

// 初始化一棵树 (initTree)
async function initTree() {
  try {
    let response = await message({
      process: processid,
      tags: [{ name: "Action", value: "initTree" }],
      signer: await createDataItemSigner(window.arweaveWallet),
      data: JSON.stringify({ owner: walletAddress }),
    });

    let { Messages } = await result({
      message: response,
      process: processid,
    });

    if (Messages && Messages[0] && Messages[0].Data) {
      console.log('初始化树结果:', Messages[0].Data);
      document.getElementById('treeDisplay').textContent = Messages[0].Data;
    } else {
      console.error('初始化树返回的数据格式不正确:', Messages);
    }
  } catch (error) {
    console.error('初始化树失败:', error);
  }
}

// 让树成长 (growTree)
async function growTree() {
  try {
    let response = await message({
      process: processid,
      tags: [{ name: "Action", value: "growTree" }],
      signer: await createDataItemSigner(window.arweaveWallet),
      data: JSON.stringify({ owner: walletAddress }),
    });

    let { Messages } = await result({
      message: response,
      process: processid,
    });

    if (Messages && Messages.length > 0 && Messages[0].Data) {
      let treeData = Messages[0].Data;
      console.log('树成长结果:', treeData);
      document.getElementById('treeDisplay').textContent = treeData;
    } else {
      console.error('树成长返回的数据格式不正确:', Messages);
      document.getElementById('treeDisplay').textContent = '树成长成功，但没有返回详细信息。';
    }
  } catch (error) {
    console.error('树成长失败:', error);
    document.getElementById('treeDisplay').textContent = '树成长失败，请稍后再试。';
  }
}

// 获取自然代币的数量 (getTokenCount)
async function getTokenCount() {
  try {
    let response = await message({
      process: processid,
      tags: [{ name: "Action", value: "getTokenCount" }],
      signer: await createDataItemSigner(window.arweaveWallet),
      data: '',
    });

    let { Messages } = await result({
      message: response,
      process: processid,
    });

    if (Messages && Messages[0] && Messages[0].Data) {
      tokenCount = parseInt(Messages[0].Data, 10); // 更新代币数量
      console.log('自然代币数量:', tokenCount);
      document.getElementById('tokenCountDisplay').textContent = `自然代币数量: ${tokenCount}`;
    } else {
      console.error('获取自然代币数量返回的数据格式不正确:', Messages);
    }
  } catch (error) {
    console.error('获取自然代币数量失败:', error);
  }
}

// 获取系统信息 (getInfo)
async function getInfo() {
  try {
    let response = await message({
      process: processid,
      tags: [{ name: "Action", value: "Info" }],
      signer: await createDataItemSigner(window.arweaveWallet),
      data: '',
    });

    let { Messages } = await result({
      message: response,
      process: processid,
    });

    if (Messages && Messages[0] && Messages[0].Data) {
      console.log('系统信息:', Messages[0].Data);
      document.getElementById('infoDisplay').textContent = Messages[0].Data;
    } else {
      console.error('获取系统信息返回的数据格式不正确:', Messages);
    }
  } catch (error) {
    console.error('获取系统信息失败:', error);
  }
}

// 更新服务器上的代币数量
function updateTokenCountOnServer(newTokenCount) {
  let ws = new WebSocket('ws://localhost:9000');
  ws.onopen = function () {
    ws.send(JSON.stringify({
      action: 'updateTokenCount',
      tokenCount: newTokenCount
    }));
  };
}

// 触发降雨特效的函数

function triggerRainEffect() {
    const rainEffectContainer = document.getElementById('rain-effect');

    // 清空之前的雨滴
    rainEffectContainer.innerHTML = '';

          // 创建 100 个雨滴
    for (let i = 0; i < 100; i++) {
      const raindrop = document.createElement('div');
      raindrop.className = 'raindrop';
      raindrop.style.left = `${Math.random() * 100}vw`;  // 随机水平位置
      raindrop.style.animationDuration = `${Math.random() * 2 + 1}s`;  // 随机动画时长
      rainEffectContainer.appendChild(raindrop);
    }

    setTimeout(() => {
        rainEffectContainer.innerHTML = '';  // 5秒后移除雨滴
    }, 5000);
}

      // 触发爱心特效的函数
function triggerLoveEffect() {
    const loveEffectContainer = document.getElementById('love-effect');

    // 清空之前的爱心
    loveEffectContainer.innerHTML = '';

    // 创建 50 个爱心
    for (let i = 0; i < 50; i++) {
        const heart = document.createElement('div');
        heart.className = 'heart';
        heart.style.left = `${Math.random() * 100}vw`;  // 随机水平位置
        heart.style.animationDuration = `${Math.random() * 4 + 2}s`;  // 随机动画时长
        loveEffectContainer.appendChild(heart);
    }

    setTimeout(() => {
        loveEffectContainer.innerHTML = '';  // 5秒后移除爱心
    }, 5000);
}


// 处理代币消耗逻辑
function handleTokenConsumption(cost, effectCallback) {
  if (tokenCount >= cost) {
    tokenCount -= cost; // 扣除代币
    document.getElementById('tokenCountDisplay').textContent = `自然代币数量: ${tokenCount}`;
    updateTokenCountOnServer(tokenCount); // 更新服务器代币数量
    effectCallback(); // 触发效果
  } else {
    alert(`自然代币不足！需要${cost}个代币。`);
  }
}

// document.addEventListener('DOMContentLoaded', async () => {
//   try {
//     // 断开原有钱包连接
//     await window.arweaveWallet.disconnect();
//     console.log('已断开钱包连接');
//   } catch (error) {
//     console.error('断开钱包连接失败:', error);
//   }
// });

// 页面加载时连接钱包并获取系统信息和自然代币数量
document.addEventListener('DOMContentLoaded', async () => {
  await connectWallet();
  await getTokenCount();
  await getInfo();
});

// 事件绑定
document.getElementById('initTreeButton').addEventListener('click', () => {
  initTree();
});

document.getElementById('growTreeButton').addEventListener('click', () => {
  growTree();
});

// 按钮事件 - 触发降雨效果
document.getElementById('rain-button').addEventListener('click', function () {
  handleTokenConsumption(rainCost, triggerRainEffect);
});

// 按钮事件 - 触发爱心效果
document.getElementById('donate-button').addEventListener('click', function () {
  handleTokenConsumption(donateCost, triggerLoveEffect);
});
