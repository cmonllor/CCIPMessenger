const ethers = require('ethers')


    const start = async()=>{
        console.log('Starting approvals...')

        const fs = require('fs')

        require('dotenv').config()

        const path = require('path')

        chainData  = JSON.parse( fs.readFileSync( path.resolve(__dirname, 'chainData.json') ) )

        console.log('Connecting to Avalanche Fuji Testnet...')
        const rpc = process.env.FUJI_RPC_URL;
        const prik = process.env.FUJI_ACCOUNT_PRIVATE_KEY

        const messengerFuji = chainData.chains[0].messengerAddress;
        const linkFuji = chainData.chains[0].LINKTokenAddress;

        let providerFj = new ethers.WebSocketProvider(rpc);
        let walletFj = new ethers.Wallet(prik, providerFj);

        const blkFj = await providerFj.getBlockNumber()
        console.log('Connected to Avalanche Fuji Testnet! Block:', blkFj)

        const abi =
        [
            "function approve(address,uint256)",
            "function allowance(address,address) view returns (uint256)"
        ]

        const linkCtrtFj = new ethers.Contract(linkFuji, abi, walletFj);

        const linkAllowanceFj = await linkCtrtFj.allowance(walletFj.address, messengerFuji)
        console.log('LINK allowance:', linkAllowanceFj.toString())

        if( linkAllowanceFj.toString() == '0' ){
            console.log('Approving LINK...')
            const tx = await linkCtrtFj.approve(messengerFuji, ethers.parseEther('2000000000000000000') );
            console.log('Approve tx:', tx.hash)

            const receipt = await tx.wait()
            console.log('Approve receipt:', receipt)

        }

        providerFj = null
        walletFj = null

        console.log('Connecting to Ethereum Sepolia Testnet...')
        const rpcS = process.env.SEPOLIA_RPC_URL;
        const prikS = process.env.SEPOLIA_ACCOUNT_PRIVATE_KEY

        const messengerSepolia = chainData.chains[1].messengerAddress;
        const linkSepolia = chainData.chains[1].LINKTokenAddress;

        const providerSepolia = new ethers.WebSocketProvider(rpcS);
        const walletSp = new ethers.Wallet(prikS, providerSepolia);

        const blkSp = await providerSepolia.getBlockNumber()
        console.log('Connected to Ethereum Sepolia Testnet! Block:', blkSp)

        const linkCtrtSp = new ethers.Contract(linkSepolia, abi, walletSp);

        const linkAllowanceSp = await linkCtrtSp.allowance(walletSp.address, messengerSepolia)
        console.log('LINK allowance:', linkAllowanceSp.toString())

        if( linkAllowanceSp.toString() == '0' ){
            console.log('Approving LINK...')
            const tx = await linkCtrtSp.approve(messengerSepolia, ethers.parseEther('2000000000000000000') );
            console.log('Approve tx:', tx.hash)

            const receipt = await tx.wait()
            console.log('Approve receipt:', receipt)

        }
    }

start()
