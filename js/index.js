const ethers = require('ethers')


    const start = async()=>{
        console.log('CCIP Messenger started!')

        const arg  = parseInt( process.argv[2] )

        if( arg == 0 ){
            console.log('TODO: fuji')
        }
        else if( arg == 1 ){
            console.log('TODO: sepolia')
        }
    }


    start()
    
