// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("Erc20Module", (m) => {
  const tokenName = m.getParameter("tokenName","Monkey #1");
  const tokenSymbol = m.getParameter("tokenSymbol","M1");
  const totalSupply = m.getParameter("totalSupply",BigInt(100));

  const erc20 = m.contract("Erc20", [tokenName, tokenSymbol, totalSupply], {
  });
  console.log("Token deploys data ::", erc20);
  return { erc20 };
});
