# PowerChia is not affiliated with the Chia Network.  This is a third party tool.

# This Module can be used to create Chia Offers in a programatic way, enabling you to make trades with other users on the Chia Network. 

# This module is provided AS IS and you are responsible for how you use it.
# With financial tools, you should always verify the code before running it.

# This module provides a set of functions to interact with the Chia Wallet RPC.

function Invoke-ChiaRpc{
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Invoke a chia rpc command

    .DESCRIPTION
    This is a powershell way to call the chia rpc commands.  You can pass in a Hashtable @{} as the json object and it will convert it to JSON automatically.

    .PARAMETER section
    The section of the chia rpc command.
    chia rpc SECTION ENDPOINT JSON

    .PARAMETER endpoint
    The sections endpoint for Chia RPC

    .PARAMETER json
    The json to send to the endpoint


    #>
    param(
        [parameter(Mandatory=$true)]
        [ValidateSet("wallet")]
        [string]$section,
        [parameter(Mandatory=$true)]
        [string]$endpoint,
        [parameter(Mandatory=$true)]
        [hashtable]$json
    )
    
    $result = chia rpc $section $endpoint ($json | ConvertTo-Json) | ConvertFrom-Json
    return $result

}

function Add-ChiaKey {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Create a new wallet from a mnemonic.

    .DESCRIPTION
    Add a 12 word or 24 word mnemonic to the wallet.

    .Parameter mnemonic
    Add an array of 12 or 24 words to the wallet.

    .EXAMPLE
    Add-ChiaKey -mnemonic @("hint", "dice", "session", "fun", "budget", "strong", "album", "lava", "tackle", "sudden", "garage", "people", "bundle", "federal", "chest", "process", "vicious", "behave", "nephew", "zero", "vital", "ocean", "artist", "lawsuit")

    fingerprint success
    ----------- -------
    874731676    True

    .EXAMPLE
    New-ChiaMnemonic | Add-ChiaKey

    
    .LINK
    https://docs.chia.net/wallet-rpc/#add_key

    .NOTES
    Uses the chia rpc wallet add_key endpoint.

    #>
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string[]]$mnemonic
    )

    if ($mnemonic.Length -ne 12 -and $mnemonic.Length -ne 24) {
        throw "Mnemonic must be either 12 or 24 words long."
    }

    $json = @{
        "mnemonic" = $mnemonic
    }

    Invoke-ChiaRpc -section wallet -endpoint add_key -json $json

}

function Test-ChiaDeleteKey {
    [CmdletBinding()]
    <#
    .SYNOPSIS 
    Display whether a fingerprint has a balance, and whether it is used for farming or pool rewards.

    .DESCRIPTION
    This is helpful when determining whether it is safe to delete a key without first backing it up.

    .PARAMETER fingerprint
    The wallet fingerprint to test.

    .PARAMETER max_ph_to_search
    The maximum number of addresses to search for the fingerprint. Default is 100.

    .EXAMPLE
    Test-ChiaDeleteKey -fingerprint 874731676 -max_ph_to_search 200

    fingerprint             : 874731676
    success                 : True
    used_for_farmer_rewards : False
    used_for_pool_rewards   : False
    wallet_balance          : False

    .LINK
    https://docs.chia.net/wallet-rpc/#check_delete_key

    .NOTES
    Uses the chia rpc wallet check_delete_key endpoint.

    #>
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,Position=0)]
        [UInt32]$fingerprint,
        [UInt32]$max_ph_to_search
    )

    $json = @{
        fingerprint = $fingerprint
    }

    Invoke-ChiaRpc -section wallet -endpoint check_delete_key -json $json
}

function Remove-ChiaKey{
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Remove a key from the wallet.

    .DESCRIPTION
    Removes the fingerprint/wallet from the wallet.  Make sure you have the mnemonic backed up or you will lose access to the coins.

    .PARAMETER fingerprint
    The fingerprint of the wallet to remove.

    .EXAMPLE

    Remove-ChiaKey -fingerprint 874731676

    Success : True

    .LINK
    https://docs.chia.net/wallet-rpc/#delete_key

    .NOTES
    Uses the chia rpc wallet delete_key endpoint.


    #>
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [UInt32]$fingerprint
    )

    $json = @{
        fingerprint = $fingerprint
    }

    Invoke-ChiaRpc -section wallet -endpoint delete_key -json $json

}
function New-ChiaMnemonic{
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Generate a new mnemonic.

    .DESCRIPTION
    Generate a new mnemonic.

    .EXAMPLE
    New-ChiaMnemonic

    mnemonic                       success
    --------                       -------
    {wheat, off, carbon, chronic…}    True


    .LINK
    https://docs.chia.net/wallet-rpc/#generate_mnemonic

    .NOTES
    Uses the chia rpc wallet generate_mnemonic endpoint.

    #>
    $mnemonic = Invoke-ChiaRpc -section wallet -endpoint generate_mnemonic -json @{}
    return $mnemonic
}
function Get-ChiaLoggedInFingerprint{
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Get the fingerprint of the currently logged in wallet.

    .DESCRIPTION
    Get the fingerprint of the currently logged in wallet.

    .EXAMPLE
    Get-ChiaLoggedInFingerprint

    fingerprint success
    ----------- -------
    422264843    True

    .LINK
    https://docs.chia.net/wallet-rpc/#get_logged_in_fingerprint

    .NOTES
    Uses the chia rpc wallet get_logged_in_fingerprint endpoint.

    #>
    $fingerprint = Invoke-ChiaRpc -section wallet -endpoint get_logged_in_fingerprint -json @{}
    return $fingerprint
}
function Get-ChiaPrivateKey {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Get the private key of a wallet.

    .DESCRIPTION
    Get the private key of a wallet.

    .PARAMETER fingerprint
    The fingerprint of the wallet to get the private key for.

    .EXAMPLE
    Get-ChiaPrivateKey -fingerprint 874731676

    .NOTES
    Uses the chia rpc wallet get_private_key endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#get_private_key


#>
param(
    [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
    [UInt32]$fingerprint
)

$json = @{
    fingerprint = $fingerprint
}

$result = Invoke-ChiaRpc -section wallet -endpoint get_private_key -json $json
return $result.private_key
}
function Get-ChiaPublicKey {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Get the public keys of a wallet.

    .DESCRIPTION
    Get the public keys of a wallet.

    .PARAMETER fingerprint
    The fingerprint of the wallet to get the public keys for.

    .EXAMPLE
    Get-ChiaPublicKeys -fingerprint 874731676

    .NOTES
    Uses the chia rpc wallet get_public_keys endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#get_public_keys

    #>
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [UInt32]$fingerprint
    )

    $json = @{
        fingerprint = $fingerprint
    }

    $result = Invoke-ChiaRpc -section wallet -endpoint get_public_keys -json $json
    return $result
}
function Set-ChiaActiveFingerprint {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Set the Active to the Chia Fingerpint/Wallet.

    .DESCRIPTION
    Set the active fingerprint for the wallet.  This is also known as logging in.

    .PARAMETER fingerprint
    The fingerprint of the wallet to make active.

    .EXAMPLE
    Set-ChiaActiveFingerprint -fingerprint 874731676

    .NOTES
    Uses the chia rpc wallet log_in endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#log_in

    #>
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [UInt32]$fingerprint
    )

    $json = @{
        fingerprint = $fingerprint
    }

    Invoke-ChiaRpc -section wallet -endpoint log_in -json $json
}

function Get-ChiaAutoClaim {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Get the auto claim settings.

    .DESCRIPTION
    Get the auto claim settings.

    .EXAMPLE
    Get-ChiaAutoClaim
    
    batch_size : 50
    enabled    : False
    min_amount : 0
    success    : True
    tx_fee     : 0

    .NOTES
    Uses the chia rpc wallet get_auto_claim endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#get_auto_claim

    #>

    $result = Invoke-ChiaRpc -section wallet -endpoint get_auto_claim -json @{}
    return $result
}

function Get-ChiaHeightInfo {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Get the height info of the wallet.

    .DESCRIPTION
    Get the height info of the wallet.

    .EXAMPLE
    Get-ChiaHeightInfo

    height success
    ------ -------
    1000   True

    .NOTES
    Uses the chia rpc wallet get_height_info endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#get_height_info

    #>

    $result = Invoke-ChiaRpc -section wallet -endpoint get_height_info -json @{}
    return $result
}

function Get-ChiaNetworkInfo {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Get the network info of the wallet.

    .DESCRIPTION
    Get the network info of the wallet.

    .EXAMPLE
    Get-ChiaNetworkInfo

    genesis_challenge                                                network_name network_prefix success
    -----------------                                                ------------ -------------- -------
    ccd5bb71183532bff220ba46c268991a3ff07eb358e8255a65c30a2dce0e5fbb mainnet      xch               True

    .NOTES
    Uses the chia rpc wallet get_network_info endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#get_network_info

    #>

    $result = Invoke-ChiaRpc -section wallet -endpoint get_network_info -json @{}
    return $result
}

function Get-ChiaSyncStatus {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Get the sync status of the wallet.

    .DESCRIPTION
    Get the sync status of the wallet.

    .EXAMPLE
    Get-ChiaSyncStatus

    genesis_initialized success synced syncing
    ------------------- ------- ------ -------
                True    True   True   False

    .NOTES
    Uses the chia rpc wallet get_sync_status endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#get_sync_status

    #>

    $result = Invoke-ChiaRpc -section wallet -endpoint get_sync_status -json @{}
    return $result
}

function Get-ChiaTimestampForHeight {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Get the timestamp for a given height.

    .DESCRIPTION
    Get the timestamp for a given height.

    .PARAMETER height
    The height to get the timestamp for.

    .PARAMETER add_local_timestamp
    Add the local timestamp to the result.

    .EXAMPLE
    Get-ChiaTimestampForHeight -height 1000

    timestamp success
    --------- -------
    1612345678 True

    .EXAMPLE
    Get-ChiaTimestampForHeight -height 6523938 -add_local_timestamp
    
    success  timestamp local_timestamp
    -------  --------- ---------------
    True 1737477594 1/21/2025 10:39:54 AM

    .NOTES
    Uses the chia rpc wallet get_timestamp_for_height endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#get_timestamp_for_height

    #>
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [UInt32]$height,
        [Switch]$add_local_timestamp
    )

    $json = @{
        height = $height
    }
    

    $result = Invoke-ChiaRpc -section wallet -endpoint get_timestamp_for_height -json $json
    if ($add_local_timestamp) {
        $timezone = [System.TimeZoneInfo]::Local
        $timestamp = [System.DateTimeOffset]::FromUnixTimeSeconds($result.timestamp).UtcDateTime
        $localTime = [System.TimeZoneInfo]::ConvertTimeFromUtc($timestamp, $timezone)
        $result | Add-Member -MemberType NoteProperty -Name "local_timestamp" -Value $localTime
    }
    return $result
}

function Submit-ChiaTransaction {
    <#
    .SYNOPSIS
    Send a Spendbundle to the blockchain.

    .DESCRIPTION
    Sends a previously created spendbundle to the blockchain.

    .PARAMETER spend_bundle
    The spendbundle to send.

    .EXAMPLE
    Submit-ChiaTransaction 

    .NOTES
    Uses the chia rpc wallet push_tx endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#push_tx

    #>
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [string]$spend_bundle
    )

    $json = @{
        spend_bundle = $spend_bundle
    }

    $result = Invoke-ChiaRpc -section wallet -endpoint push_tx -json $json
    return $result
}

function Set-ChiaAutoClaim {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Set the auto claim settings.

    .DESCRIPTION
    Set the auto claim settings.

    .PARAMETER enabled
    Enable or disable auto claim.

    .PARAMETER batch_size
    The batch size for auto claim.

    .PARAMETER min_amount
    The minimum amount for auto claim.

    .PARAMETER tx_fee
    The transaction fee for auto claim.

    .EXAMPLE
    Set-ChiaAutoClaim -enabled $true -batch_size 50 -min_amount 0 -tx_fee 0

    batch_size : 50
    enabled    : True
    min_amount : 0
    success    : True
    tx_fee     : 0


    .NOTES
    Uses the chia rpc wallet set_auto_claim endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#set_auto_claim

    #>
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [bool]$enabled,
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [UInt32]$batch_size,
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [UInt32]$min_amount,
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [UInt64]$tx_fee
    )

    $json = @{
        enabled = $enabled
        batch_size = $batch_size
        min_amount = $min_amount
        tx_fee = $tx_fee
    }

    Invoke-ChiaRpc -section wallet -endpoint set_auto_claim -json $json
}
    
function Add-ChiaCat {
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Adds the ability to track a CAT token to the wallet.

    .DESCRIPTION
    This commands adds a cat token with a wallet_id to your fingerprint.  This is useful for tracking CAT tokens in your wallet.

    .PARAMETER name
    This is the lable for the Cat in your wallet.

    .PARAMETER asset_id
    The asset_id of the CAT token.

    

    .LINK
    https://docs.chia.net/wallet-rpc/#create_new_wallet

    .NOTES
    This does not add tokens to your wallet, it just enables tracking of the token.
    Uses the chia rpc wallet create_new_wallet endpoint.
    
    .EXAMPLE
    Add DexieBucks to the wallet.

    Add-ChiaCat -name DBX -asset_id db1a9020d48d9d4ad22631b66ab4b9ebd3637ef7758ad38881348c5d24c38f20

    asset_id                                                         success type wallet_id
    --------                                                         ------- ---- ---------
    db1a9020d48d9d4ad22631b66ab4b9ebd3637ef7758ad38881348c5d24c38f20    True    6         2

    
    #>
    param(
        [string]$name,
        [Parameter(Mandatory=$true)]
        [string]$asset_id
    )

    $json = @{
        wallet_type = "cat_wallet"
        mode = "existing"
        name = $name
        asset_id = $asset_id
    }

    Invoke-ChiaRpc -section wallet -endpoint create_new_wallet -json $json
}

function Get-ChiaWallets{
    [CmdletBinding()]
    <#
    .SYNOPSIS
    Get a list of chia wallets.

    .DESCRIPTION
    Get a list of chia wallets for the logged in fingerprint.

    .PARAMETER type
    The type of wallet to get.  Options are standard_wallet, atomic_swap, authorized_payee, multi_sig, custody, cat, recoverable, decentralized_id, pooling_wallet, nft, data_layer, data_layer_offer, vc

    .PARAMETER exclude_data
    Exclude the data from the wallet.

    .EXAMPLE
    Get-ChiaWallets -type standard_wallet

    data id name        type
    ---- -- ----        ----
        1 Chia Wallet    0

    .EXAMPLE
    Get-ChiaWallets

    data                                                               id name        type
    ----                                                               -- ----        ----
                                                                        1 Chia Wallet    0
    db1a9020d48d9d4ad22631b66ab4b9ebd3637ef7758ad38881348c5d24c38f2000  2 DBX            6

    .LINK
    https://docs.chia.net/wallet-rpc/#get_wallets

    .NOTES
    Uses the chia rpc wallet get_wallets endpoint.


    #>
    param(
        [ValidateSet("standard_wallet","atomic_swap","authorized_payee","multi_sig","custody","cat","recoverable","decentralized_id","pooling_wallet","nft","data_layer","data_layer_offer","vc")]
        [string]$type,
        [switch]$exclude_data
    )
    $wallet_type = $null
    
    switch ($type) {
        "standard_wallet" {$wallet_type = 0}
        "atomic_swap" {$wallet_type = 2}
        "authorized_payee" {$wallet_type = 3}
        "multi_sig" {$wallet_type = 4}
        "custody" {$wallet_type = 5}
        "cat" {$wallet_type = 6}
        "recoverable" {$wallet_type = 7}
        "decentralized_id" {$wallet_type = 8}
        "pooling_wallet" {$wallet_type = 8}
        "nft" {$wallet_type = 10}
        "data_layer" {$wallet_type = 11}
        "data_layer_offer" {$wallet_type = 12}
        "vc" {$wallet_type = 13}
    }

    

    if($exclude_data.IsPresent){
        $exclude = $true
    } else {
        $exclude = $false
    }
    if($type){
        $json = @{
            type = $wallet_type
            exclude_data = $exclude
        }
    } else {
        $json = @{
            exclude_data = $exclude
        }
    }


    $result = Invoke-ChiaRpc -section wallet -endpoint get_wallets -json $json
    return $result.wallets
   
}

function Get-ChiaNftInfo{
    <#
    .SYNOPSIS
    Get the NFT info for a coin_id.

    .DESCRIPTION
    Get the on chain information for an NFT.

    .PARAMETER coin_id
    This can be either the coin_id or the launcher_id of the NFT.

    .PARAMETER wallet_id
    The wallet_id of the NFT if you own it.

    .EXAMPLE
    Get-ChiaNftInfo -coin_id "nft1r5u0rrpsafl9rz8slh0jm8w3h9xl8f7mftqzn8dc8cqnuh7ked4ssk5rl4"

    chain_info                   : ((117 "https://ipfs.fancyfauna.com/ipfs/QmP6b5yUXPtpUHEL3nQihMsVWBSTpy87AJV4gz73rwnShE") (104 . 0x33bfd9355b4ce0b268363ba76524919b4147637e6a77bf4a5aa290309bf512b3) (28021
                                "https://ipfs.fancyfauna.com/ipfs/QmV2Xiq1y6J4dMDBb4WSjPtcj48sKQF7pKcynLSq9zueAr") (28008 . 0x38b5c9ee85343aaaef21c222b76ba7f17164de1a562c4c58d73133843ca7aba9) (27765
                                "https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt") (29550 . 1) (29556 . 1) (27752 . 0xa2010f343487d3f7618affe54f789f5487602331c0a8d03f49e9a7c547cf0499))
    data_hash                    : 0x33bfd9355b4ce0b268363ba76524919b4147637e6a77bf4a5aa290309bf512b3
    data_uris                    : {https://ipfs.fancyfauna.com/ipfs/QmP6b5yUXPtpUHEL3nQihMsVWBSTpy87AJV4gz73rwnShE}
    edition_number               : 1
    edition_total                : 1
    launcher_id                  : 0x1d38f18c30ea7e5188f0fddf2d9dd1b94df3a7db4ac0299db83e013e5fd6cb6b
    launcher_puzhash             : 0xeff07522495060c066f66f32acc2a77e3a3e737aca8baea4d1a64ea4cdc13da9
    license_hash                 : 0xa2010f343487d3f7618affe54f789f5487602331c0a8d03f49e9a7c547cf0499
    license_uris                 : {https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt}
    metadata_hash                : 0x38b5c9ee85343aaaef21c222b76ba7f17164de1a562c4c58d73133843ca7aba9
    metadata_uris                : {https://ipfs.fancyfauna.com/ipfs/QmV2Xiq1y6J4dMDBb4WSjPtcj48sKQF7pKcynLSq9zueAr}
    mint_height                  : 6518668
    minter_did                   : 
    nft_coin_confirmation_height : 6525578
    nft_coin_id                  : 0xcd58353b234b59b6ca78621567adbe9af5b9266327ec0b084ee1a91d4cb60d77
    nft_id                       : nft1r5u0rrpsafl9rz8slh0jm8w3h9xl8f7mftqzn8dc8cqnuh7ked4ssk5rl4
    off_chain_metadata           : 
    owner_did                    : 
    p2_address                   : 0x32e7a53316929bb0b7eb5e5c940602d0bfc71e41953cc8bceebe394590fa35fe
    pending_transaction          : False
    royalty_percentage           : 500
    royalty_puzzle_hash          : 0x5284226b2be7b21f964f6c3a1eb57c84097b74f5588e6096c18486d9138d485b
    supports_did                 : True
    updater_puzhash              : 0xfe8a4b4e27a2e29a4d3fc7ce9d527adbcaccbab6ada3903ccf3ba9a769d2d78b

    .LINK
    https://docs.chia.net/wallet-rpc/#nft_get_info

    .NOTES
    Uses the chia rpc wallet nft_get_info endpoint.

    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [string]$coin_id,
        [UInt32]$wallet_id
    )

    $json = @{
        coin_id = $coin_id
    }
    if($wallet_id -gt 0)
    {
        $json.wallet_id = $wallet_id
    }

    $nft = Invoke-ChiaRpc -section wallet -endpoint nft_get_info -json $json
    return $nft.nft_info
}

function Get-ChiaOffers {
    <#
    .SYNOPSIS
    Get a list of all offers known to the wallet.

    .DESCRIPTION
    Get a list of all offers known to the wallet.

    .PARAMETER start
    Number of offers to skip from the start.

    .PARAMETER end
    Number of offers to return.

    .PARAMETER exclude_my_offers
    Exclude offers made by the wallet.

    .PARAMETER exclude_taken_offers
    Exclude offers that have been taken.

    .PARAMETER include_completed
    Include completed offers.

    .PARAMETER reverse
    Reverse the order of the offers.

    .PARAMETER file_contents
    Show the Offer file contents.

    .EXAMPLE
    Get-ChiaOffers -start 0 -end 10

    .NOTES
    Uses the chia rpc wallet get_all_offers endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#get_all_offers

    #>
    [CmdletBinding()]
    param(
        [UInt32]$start,
        [UInt32]$end,
        [switch]$exclude_my_offers,
        [switch]$exclude_taken_offers,
        [switch]$include_completed,
        [switch]$reverse,
        [switch]$file_contents
    )

    if($end -eq 0){
        $end = 10
    }
   
    $json = @{
        start = $start
        end = $end
        exclude_my_offers = $exclude_my_offers.IsPresent
        exclude_taken_offers = $exclude_taken_offers.IsPresent
        include_completed = $include_completed.IsPresent
        reverse = $reverse.IsPresent
        file_contents = $file_contents.IsPresent
    }

    $result = Invoke-ChiaRpc -section wallet -endpoint get_all_offers -json $json
    return $result.trade_records
}

function Get-ChiaOffer {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$trade_id,
        [switch]$file_contents
    )
    $json = @{
        trade_id = $trade_id
        file_contents = $file_contents.IsPresent
    }

    $result = Invoke-ChiaRpc -section wallet -endpoint get_offer -json $json
    return $result.trade_record
}

function Revoke-Offer{
    <#
    .SYNOPSIS
    Cancel an Offer by trade_id.

    .DESCRIPTION
    Cancel an offer on or off chain by using the secure flag.

    .PARAMETER trade_id
    The trade_id of the offer to cancel.

    .PARAMETER fee
    The fee paid to confirm transaction. Default = 0

    .PARAMETER insecure
    This switch will unlock the coin from the wallet, but the offer is still valid until the coin is spent onchain.
    

    .EXAMPLE

    Revoke-Offer -trade_id 0xda6a840ebdb8a85a363d5e0af3ea287fbb0de90dda87f6aae7cf51b62ad00fd4 -insecure

    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$trade_id,
        [UInt64]$fee,
        [switch]$insecure
    )

    if($insecure.IsPresent){
        $secure = $false
    } else {
        $secure = $true
    }

    $json = @{
        fee = $fee
        trade_id = $trade_id
        secure = $secure
    }
    
    $result = Invoke-ChiaRpc -section wallet -endpoint cancel_offer -json $json
    return $result
}

function Get-ChiaOfferSummary {
    <#
    
    .SYNOPSIS
    Get a summary of an offer string.

    .DESCRIPTION
    Gets the summery from an offer string.

    .PARAMETER offer
    The offer string to get the summary from.

    .PARAMETER advanced
    Get the advanced summary.

    .EXAMPLE
    Get-ChiaOfferSummary -offer "offer1qqr83wcuu2rykcmqvpsxzgqqemhmlaekcenaz02ma6hs5w600dhjlvfjn477nkwz369h88kll73h37fefnwk3qqnz8s0lle04zemqw4ca0w6nkptpuppmfm78g2nknd8te5w4449p50dj36cncaj5q8n7xpyd6dez5qlulx2q2d3gdly7ghykd4cjxu02nxjgf0ajt2uxkzcrnall4h78axlzx2uxq9kua8ezsl37ne4jxeyd75d753vj8wl464l5k9utaylc7vljkxry0349a00k9n6k9a04au36l6wmqc59ww9mfzhwluv4my0j0fmgfhrmhjekdusyw8jrrd3ds8zd7602dk60gdkm0vdkm0yvkm0ar5knd84g6lavxacwp0kp0h0w0pth4jxudkhxgarymjpazt9ts0kq0nhd4sdenkq4mwntvj624gxt0auyjuqa2ea4ddafwfr7wc5k57ckl66c30jx5l56nk0vnwt2m8me2uap2szhxpphn5t7rqqvmmgk3auadze2mkasd9kfz757e747wp4kjnrmp66k9yk0qv8hllc8twuj438wlru2f7l8yhr5fn03rxfmgs0r0qq2xgqxmmmll0lq5yhxdjkchmu49ck3zrd4p2t86ddfv7a5vujllqmmdrudt9nzmp06f2qs5m079mv80nmqmx2tw4jxrdtf6yq06ldesuhkuze67m3kpcvle89trr49c7f2qz5vh787qdpsmj07enx2xqllpx4x4qgcclu665mzv4duzzurv4qfyrug27n3hv8sl7vl9av9lx9rfw4dp2fp22llxa55m7z0tqvngulutecydl0ap96njelnng4e505llgd0e7mfm8f40mtxnat36cpa4m282mx35hlq44dke24jaxd46p7xdaktv87uku0qn7aesrk0fsc6lau47v9fd9eedh7mlx0fvd9u8lc99236dx9a82u9xdd3m36vkefth7h9sltlz95xjq65cme9d43vzwwpsz9534g68m87qdpvmdl7enqnvx7gm5ekzfwt7m6fmru7unwt6m6lctm3af794atlvhna8mr9wt63y2layjl2l6p6xrvm7fmh4t9fzrea7w3x2hvtg4zg6yna6n8yvec0kkc00h0l55rdgz3t9834q8yfesym5jqeq7t22xtcdh7ewswaentwrnvlmuhmsu8pxc5rmlvnqnhavz76qm07uxdp4y8kvhte958ku4585ua48sud48cad38c9328m2f0rs0u8mdflpqxa0gksnk0v92n5f4a7me57v5r5p2saypv8e85a9mm9ex8m9fm8pqz0elv3nd20gg2t20m34sa00smlf877l8ktupfn8k5nkl7pwtq58hshws3s2kyz4k89lx2h2e7qlekpcjk0l0utvs2hldlelv6wlqf4scy0wraz438x7k86st8mmzl6cjvkhfmr57kf4v25v0a4qmkfnfghwacgasapuj9dz3k0q07cld9m957cf2tuwpxga0n4ncj5hk3e3ykam0mvsh5uwz7tlmk0llyx4q23dge5pmtm8lstaahqe5dcm2e88p0tsdm3eykmrheyjz35qkuvwnqnu9amtah3c84hvzlu9hfrc5de0xcy5n70uvxfmkwelwwpm0kwzn7d42d49wkwtgewweh8wx7wlujnapqxw2yzve5hyzsfjm8guuyndjwlsjheh6qkvexjmhthkt3g8ch2kg2v0qatpwjfeqcwe8uz4rpkcarpkcdppkedppxmdpqqut35mvfcypldlmgggxpl22r5csnvu5w4ex80jh87x6u7496yc45kufmwl9cfnf0lpt948f07665pfpzw6evhh506m86vdrt5l9nlenw6zw565zrf5747mleekranr3c206ckw0auwhh6v3aj2fp9wrkad48k9cdkynjw0lut6s3gaawmhuu0m49m7m9gn4vdw84hw3dex09eghwh9wv934ewhx6sjxkjyrvmqlhl342un2v0pe9k0nnumgfrtyn52xqullashte9wlwdslvfum5djsjk5vvyapyc8ugtnzn28sg3c0y8pkhgrkr5czqfjyd27pp93u2pekgl0ldfc6rt3k8klad4lhz442xk29luwa5l8k2t329kmtt9nhhmn28lreqluwx8vlg0r04fyzwclc4l2sr6m789we0tath5sz9gre68260390cwf8zhde9zahqyrmphlhz8kkhdqcawnm4lheyqcqy6m9wwq72w8a7" -advanced

    id                                                                 success summary
    --                                                                 ------- -------
    0x489275d9d8f0ddff2315f756d2067141f87dfb9000d76fc8e747d6d21e1d1414    True @{additions=System.Object[]; fees=0; infos=; offered=; removals=System.Object[]; requested=; valid_times=}

    .NOTES
    Uses the chia rpc wallet get_offer_summary endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#get_offer_summary
    

    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$offer,
        [switch]$advanced
    )

    $json = @{
        offer = $offer
        advanced = $advanced.IsPresent
    }

    $result = Invoke-ChiaRpc -section wallet -endpoint get_offer_summary -json $json
    return $result
}


Class ChiaOffer{
    [hashtable]$offer
    [UInt64]$fee
    $offertext
    $json
    [string]$dexie_url 
    $requested_nft_data
    $nft_info
    [UInt64]$max_height
    [UInt64]$max_time
    [UInt64]$min_height
    [UInt64]$min_time
    [bool]$validate_only

    ChiaOffer(){
        $this.max_height = 0
        $this.max_time = 0
        $this.min_height = 0
        $this.min_time = 0
        $this.fee = 0
        $this.offer = @{}
        $this.validate_only = $false
        $this.dexie_url = "https://dexie.space/v1/offers"
    }

    offerNft($nft_id){
        $this.RPCNFTInfo($nft_id)
        $this.offer.($this.nft_info.launcher_id.substring(2))=-1
    }

    requestNft($nft_id){
        $this.RPCNFTInfo($nft_id)
        $this.offer.($this.nft_info.launcher_id.substring(2))=1
        $this.BuildDriverDict($this.nft_info)
    }

    requestCat($asset_id, $amount){
        $this.offer.$asset_id=$amount
    }

    addBlocksUntilExpiration($num){
        $height = (Get-ChiaHeightInfo).height
        $this.max_height = $height + $num
    }

    setMaxHeight($num){
        $this.max_height = $num
    }

    addBlocksUntilTradable($num){
        $height = (Get-ChiaHeightInfo).height
        $this.min_height = $height + $num
    }

    setMinHeight($num){
        $this.min_height = $num
    }
    

    addTimeInMinutesUntilExpiration($min){
        $DateTime = (Get-Date).ToUniversalTime()
        $DateTime = $DateTime.AddMinutes($min)
        $this.max_time = [System.Math]::Truncate((Get-Date -Date $DateTime -UFormat %s))
    }

    addTimeInMinutesUntilTradable($min){
        $DateTime = (Get-Date).ToUniversalTime()
        $DateTime = $DateTime.AddMinutes($min)
        $this.min_time = [System.Math]::Truncate((Get-Date -Date $DateTime -UFormat %s))
    }

    requestXch([Int64]$amount){
        $this.offer.([string]"1")=[Int64]$amount
    }
 

    offerXch([Int64]$amount){
        $this.offer."1"=($amount*-1)
    }

    offered($asset_id, [Int64]$amount){
        $this.offer."$asset_id"=($amount*-1)
    }

    validateonly(){
        $this.validate_only = $true
    }
    
    makejson(){
        $this.json = [ordered]@{
            "offer"=($this.offer)
            "fee"=$this.fee
            "validate_only"=$this.validate_only
            "reuse_puzhash"=$true
        }
        if($this.requested_nft_data){
            $this.json."driver_dict"=$this.requested_nft_data
        }
        
        if($this.max_height -ne 0){
            $this.json.max_height = $this.max_height
        } 
        if($this.max_time -ne 0){
            $this.json.max_time = $this.max_time
        }
        if($this.min_height -ne 0){
            $this.json.min_height = $this.min_height
        }
        if($this.min_time -ne 0){
            $this.json.min_time = $this.min_time
        }
        
    } 
    
    [pscustomobject]createoffer(){
        $this.makejson()
        $offerjson = $this.json | ConvertTo-Json -Depth 11
        $this.offertext = chia rpc wallet create_offer_for_ids $offerjson
        return $this.offertext | ConvertFrom-Json
    }

    [pscustomobject]showoffer(){
        if($this.offertext){
            return $this.offertext | ConvertFrom-Json
        } else {
            throw "You must create the offer first."
        }
        
    }

    
    RPCNFTInfo($nft_id){
        $this.nft_info = Get-ChiaNftInfo -coin_id $nft_id
    }

    BuildDriverDict($data){
    
        $this.requested_nft_data = [ordered]@{($data.launcher_id.substring(2))=[ordered]@{
                type='singleton';
                launcher_id=$data.launcher_id;
                launcher_ph=$data.launcher_puzhash;
                also=[ordered]@{
                    type='metadata';
                    metadata=$data.chain_info;
                    updater_hash=$data.updater_puzhash;
                    also=[ordered]@{
                        type='ownership';
                        owner=$data.owner_did;
                        transfer_program=[ordered]@{
                            type='royalty transfer program';
                            launcher_id=$data.launcher_id;
                            royalty_address=$data.royalty_puzzle_hash;
                            royalty_percentage=[string]$data.royalty_percentage
                        }
                    }
                }
            }
        }
        
    }
}



function Build-ChiaOffer{
    <#
    .SYNOPSIS
    Build a new ChiaOffer object.

    .DESCRIPTION
    This is used for creating a powershell offer object.  

    .EXAMPLE
    Building an offer to request 205 DBX (dexiebucks) and offer 1 XCH.
    Notice the the offer and request numbers are in Mojos.  
    1 XCH = 1,000,000,000,000 Mojos
    205 DBX = 205,000 Mojos

    # Create an offer object.
    $offer = Build-ChiaOffer
    
    # Offer 1 XCH
    $offer.offerXch(1000000000000)

    # Request Dexie Bucks using the asset_id and amount in mojos.
    $offer.requestCat("db1a9020d48d9d4ad22631b66ab4b9ebd3637ef7758ad38881348c5d24c38f20",205000)

    # Create the offer
    $offer.createoffer()

    # Assign that data to a variable.
    $offer_data = $offer.showoffer()

    offer                 : offer1......
    success               : True
    trade_record          : @{accepted_at_time=; coins_of_interest=System.Object[]; confirmed_at_index=0; created_at_time=1737572687; is_my_offer=True; pending=; sent=0; sent_to=System.Object[]; status=PENDING_ACCEPT;   
                            summary=; taken_offer=; trade_id=0xda6a840ebdb8a85a363d5e0af3ea287fbb0de90dda87f6aae7cf51b62ad00fd4; valid_times=}
    transactions          : {}
    unsigned_transactions : {}

    If you have the PowerDexie Module, you can upload the offer by using the following command:
    
    Send-DexieOffer -offer $offer_data.offer
    StatusCode        : 200
    StatusDescription : OK
    Content           : {"success":true,"id":"Ht6FQ9QmmYs8LyzpS8pYrYBKjqBfeJgyyBxoj5Ez1LFe","known":true,"offer":{"id":"Ht6FQ9QmmYs8LyzpS8pYrYBKjqBfeJgyyBxoj5Ez1LFe","status":3,"involved_coins":["0xd8b874f36a16fcf89e410 
                        07ba6…
    RawContent        : HTTP/1.1 200 OK
                        Date: Wed, 22 Jan 2025 19:26:34 GMT
                        Transfer-Encoding: chunked
                        Connection: keep-alive
                        cdn-cache-control: no-cache, stale-if-error=600
                        ETag: W/"6a6-BjPIXUA2TlbKVYURnSh1rcQ6Wg4"
                        cf…
    Headers           : {[Date, System.String[]], [Transfer-Encoding, System.String[]], [Connection, System.String[]], [cdn-cache-control, System.String[]]…}
    Images            : {}
    InputFields       : {}
    Links             : {}
    RawContentLength  : 1702
    RelationLink      : {}

    #>
    [CmdletBinding()]
    $offer = [ChiaOffer]::new()
    return $offer
}


function ConvertTo-XCHMojo{
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [decimal]$amount
    )

    if ($amount -ne [Math]::Round($amount, 12)) {
        throw "This number is more than twelve decimal places.  Please round to twelve decimal places and try again."
    }
    return [Math]::Round(($amount * 1000000000000),0)
}

function ConvertFrom-XCHMojo{
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [UInt64]$amount
    )
    return [Math]::Round($amount / 1000000000000,12)
}

function ConvertFrom-CatMojo{
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [UInt64]$amount
    )
    return [Math]::Round($amount / 1000,3)
}

function ConvertTo-CatMojo{
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [decimal]$amount
    )
    
    if ($amount -ne [Math]::Round($amount, 3)) {
        throw "This number is more than three decimal places.  Please round to three decimal places and try again."
    }
    
    return [Math]::Round($amount * 1000,0)
}

@("Invoke-ChiaRPC","Add-ChiaKey","Test-ChiaDeleteKey","Remove-ChiaKey","New-ChiaMnemonic","Get-ChiaLoggedInFingerprint","Get-ChiaPrivateKey","Get-ChiaPublicKey",
"Set-ChiaActiveFingerprint","Get-ChiaAutoClaim","Get-ChiaHeightInfo","Get-ChiaNetworkInfo","Get-ChiaSyncStatus","Get-ChiaTimestampForHeight","Submit-ChiaTransaction","set-ChiaAutoClaim","Add-ChiaCat","Get-ChiaWallets",
"Get-ChiaNftInfo","Get-ChiaOffers","Revoke-Offer","Get-ChiaOfferSummary","Build-ChiaOffer","ConvertTo-XCHMojo","ConvertFrom-XCHMojo","ConvertTo-CATMojo","ConvertFrom-CATMojo") | Export-ModuleMember
