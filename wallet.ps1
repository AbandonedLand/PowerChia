function Invoke-ChiaRpc{
    <#
    .SYNOPSIS
    Invoke a chia rpc command

    .DESCRIPTION
    A function to invoke a chia rpc command

    .PARAMETER section
    The section of the chia rpc command.

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
    
    chia rpc $section $endpoint ($json | ConvertTo-Json) | ConvertFrom-Json

}

function Add-ChiaKey {
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

    .LINK
    https://docs.chia.net/wallet-rpc/#add_key

    .NOTES
    Uses the chia rpc wallet add_key endpoint.

    #>
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,Position=0)]
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
    return $mnemonic.mnemonic
}

function Get-ChiaLoggedInFingerprint{
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

function Login-ChiaWallet {
    <#
    .SYNOPSIS
    Log in to the wallet.

    .DESCRIPTION
    Log in to the wallet.

    .PARAMETER fingerprint
    The fingerprint of the wallet to log in to.

    .EXAMPLE
    Login-ChiaWallet -fingerprint 874731676

    

    .NOTES
    Uses the chia rpc wallet log_in endpoint.

    .LINK
    https://docs.chia.net/wallet-rpc/#log_in

    #>
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory=$true)]
        [UInt32]$fingerprint
    )

    $json = @{
        fingerprint = $fingerprint
    }

    Invoke-ChiaRpc -section wallet -endpoint log_in -json $json
}

# Export-ModuleMember -Function Add-ChiaKey, Test-ChiaDeleteKey, New-ChiaMnemonic