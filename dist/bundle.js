/*
 * ATTENTION: The "eval" devtool has been used (maybe by default in mode: "development").
 * This devtool is neither made for production nor for readable output files.
 * It uses "eval()" calls to create a separate source file in the browser devtools.
 * If you are trying to read the output file, select a different devtool (https://webpack.js.org/configuration/devtool/)
 * or disable the default devtool with "devtool: false".
 * If you are looking for production-ready output files, see mode: "production" (https://webpack.js.org/configuration/mode/).
 */
/******/ (() => { // webpackBootstrap
/******/ 	"use strict";
/******/ 	var __webpack_modules__ = ({

/***/ "./src/index.js":
/*!**********************!*\
  !*** ./src/index.js ***!
  \**********************/
/***/ ((__unused_webpack_module, __webpack_exports__, __webpack_require__) => {

eval("__webpack_require__.r(__webpack_exports__);\n\r\n\r\nlet walletAddress = ''; // 存储钱包地址\r\nconst processid = \"H0OOdNJHHrUNM2n_XZDv7HgMwGUJSlN4RL6xuLEVuic\";  // 替换为实际的 AO 进程 ID\r\n\r\n// 连接钱包\r\nasync function connectWallet() {\r\n  try {\r\n    await window.arweaveWallet.connect(['SIGN_TRANSACTION', 'ACCESS_ADDRESS']);\r\n    walletAddress = await window.arweaveWallet.getActiveAddress();\r\n    console.log('钱包已连接:', walletAddress);\r\n  } catch (error) {\r\n    console.error('连接钱包失败:', error);\r\n  }\r\n}\r\n\r\n// 初始化树\r\nasync function initTree() {\r\n  try {\r\n    let response = await fetch('/initTree', {\r\n      method: 'POST',\r\n      headers: { 'Content-Type': 'application/json' },\r\n      body: JSON.stringify({ owner: walletAddress })\r\n    });\r\n    const result = await response.json();\r\n    if (result.includes('Error')) {\r\n      alert('树已存在，请重新种植！');\r\n    } else {\r\n      console.log('树初始化成功:', result);\r\n    }\r\n  } catch (error) {\r\n    console.error('初始化树失败:', error);\r\n  }\r\n}\r\n\r\n// 让树成长\r\nasync function growTree() {\r\n  try {\r\n    let response = await fetch('/growTree', {\r\n      method: 'POST',\r\n      headers: { 'Content-Type': 'application/json' },\r\n      body: JSON.stringify({ owner: walletAddress })\r\n    });\r\n    const result = await response.json();\r\n    console.log('树成长结果:', result);\r\n    getTreeState();  // 树成长后更新树的状态\r\n  } catch (error) {\r\n    console.error('树成长失败:', error);\r\n  }\r\n}\r\n\r\n// 获取树的状态\r\nasync function getTreeState() {\r\n  try {\r\n    let response = await fetch('/getTree', {\r\n      method: 'POST',\r\n      headers: { 'Content-Type': 'application/json' },\r\n      body: JSON.stringify({ owner: walletAddress })\r\n    });\r\n    const result = await response.json();\r\n    console.log('树的状态:', result);\r\n    updateTreeDisplay(result);\r\n  } catch (error) {\r\n    console.error('获取树的状态失败:', error);\r\n  }\r\n}\r\n\r\n// 获取自然代币的数量\r\nasync function getTokenCount() {\r\n  try {\r\n    let response = await fetch('/getTokenCount');\r\n    const result = await response.json();\r\n    console.log('自然代币数量:', result);\r\n    document.getElementById('tokenCountDisplay').textContent = `自然代币数量: ${result}`;\r\n  } catch (error) {\r\n    console.error('获取自然代币数量失败:', error);\r\n  }\r\n}\r\n\r\n// 更新页面上的树信息\r\nfunction updateTreeDisplay(treeData) {\r\n  const treeElement = document.getElementById('treeDisplay');\r\n  treeElement.querySelector('.height').textContent = `Height: ${treeData.height}`;\r\n  treeElement.querySelector('.leaves').textContent = `Leaves: ${treeData.leaves.join(', ')}`;\r\n  treeElement.querySelector('.lastUpdated').textContent = `Last Updated: ${treeData.lastUpdated}`;\r\n}\r\n\r\n// 页面加载时获取树状态和自然代币数量\r\ndocument.addEventListener('DOMContentLoaded', () => {\r\n  getTreeState();\r\n  getTokenCount();\r\n});\r\n\r\n// 事件绑定\r\ndocument.getElementById('initTreeButton').addEventListener('click', () => {\r\n  initTree();\r\n});\r\n\r\ndocument.getElementById('growTreeButton').addEventListener('click', () => {\r\n  growTree();\r\n});\r\n\r\ndocument.getElementById('connectWalletButton').addEventListener('click', async () => {\r\n  await connectWallet();\r\n});\r\n\n\n//# sourceURL=webpack://ao-tree/./src/index.js?");

/***/ })

/******/ 	});
/************************************************************************/
/******/ 	// The require scope
/******/ 	var __webpack_require__ = {};
/******/ 	
/************************************************************************/
/******/ 	/* webpack/runtime/make namespace object */
/******/ 	(() => {
/******/ 		// define __esModule on exports
/******/ 		__webpack_require__.r = (exports) => {
/******/ 			if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 				Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 			}
/******/ 			Object.defineProperty(exports, '__esModule', { value: true });
/******/ 		};
/******/ 	})();
/******/ 	
/************************************************************************/
/******/ 	
/******/ 	// startup
/******/ 	// Load entry module and return exports
/******/ 	// This entry module can't be inlined because the eval devtool is used.
/******/ 	var __webpack_exports__ = {};
/******/ 	__webpack_modules__["./src/index.js"](0, __webpack_exports__, __webpack_require__);
/******/ 	
/******/ })()
;