Function New-DynamicParam
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $ParameterName,

        [string[]]
        $Alias,

        [Parameter(Mandatory)]
        [type]
        $ParamType,

        [switch]
        $Mandatory,

        [switch]
        $ValueFromPipeLine,

        [switch]
        $ValueFromPipelineByPropertyName,

        [switch]
        $ValueFromRemainingArguments,

        [object]
        $DefaultValue,

        [string]
        $ParameterSetName,

        [string[]]
        $ValidateSet,

        [string]
        $ValidatePattern,

        [ScriptBlock]
        $ValidateScript,

        [System.Object[]]
        $ValidateRange,

        [switch]
        $ValidateNotNullOrEmpty
    )

    $attribute = [System.Management.Automation.ParameterAttribute]::new()
    $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
    $attribute.Mandatory = $Mandatory.IsPresent

    if ($ParameterSetName)
    {
        $attribute.ParameterSetName = $ParameterSetName
    }

    if ($ValueFromPipeLine.IsPresent)
    {
        $attribute.ValueFromPipeline = $true
    }

    if ($ValueFromPipelineByPropertyName.IsPresent)
    {
        $attribute.ValueFromPipelineByPropertyName = $true
    }

    if ($ValueFromRemainingArguments)
    {
        $attribute.ValueFromRemainingArguments = $true
    }

    if ($Alias)
    {
        $attributeCollection.Add([System.Management.Automation.AliasAttribute]::new($Alias))
    }

    if ($ValidateSet)
    {
        $attributeCollection.Add([System.Management.Automation.ValidateSetAttribute]::new($ValidateSet))
    }

    if ($ValidateRange)
    {
        $attributeCollection.Add([System.Management.Automation.ValidateRangeAttribute]::new($ValidateRange[0], $ValidateRange[1]))
    }

    if ($ValidatePattern)
    {
        $attributeCollection.Add([System.Management.Automation.ValidatePatternAttribute]::new($ValidatePattern))
    }

    if ($ValidateScript)
    {
        $attributeCollection.Add([System.Management.Automation.ValidateScriptAttribute]::new($ValidateScript))
    }

    if ($ValidateNotNullOrEmpty)
    {
        $attributeCollection.Add([System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new())
    }

    $attributeCollection.Add($attribute)

    $runTimeParam = [System.Management.Automation.RuntimeDefinedParameter]::new($ParameterName, $ParamType,  $attributeCollection)

    if ($DefaultValue)
    {
        $runTimeParam.Value = $DefaultValue
        $PSBoundParameters."$ParameterName" = $DefaultValue 
        $PSCmdlet.MyInvocation.BoundParameters."$ParameterName" = $DefaultValue 
        Set-Variable -Name $ParameterName -Value $DefaultValue -Scope Script
    }

    $runTimeParam
}