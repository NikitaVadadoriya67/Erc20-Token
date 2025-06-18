const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("NftModule", (m) => {
  const name = m.getParameter("name", "Monkey NFT #1");
  const symbol = m.getParameter("symbol", "N1");

  const nft = m.contract(
    "Nft",
    [name, symbol]
  );
  
  console.log("NFT deployment initialized",nft);
  return { nft };
});