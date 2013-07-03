$vm = Get-VM "<vm name>" | Get-View
$cloneName = "<clone name>"
$cloneFolder = $vm.parent
$cloneSpec = new-object Vmware.Vim.VirtualMachineCloneSpec
$cloneSpec.Location = new-object Vmware.Vim.VirtualMachineRelocateSpec  # required
$cloneSpec.Location.Pool = (get-cluster "somecluster" | get-resourcepool "Resources" | get-view).MoRef
$cloneSpec.Location.Host = (get-vm "somevm" | get-vmhost | get-view).MoRef
$cloneSpec.Location.Datastore = (get-datastore -vm "anothervm" | get-view).MoRef
$cloneSpec.Location.Transform = [Vmware.Vim.VirtualMachineRelocateTransformation]::sparse
$vm.CloneVM_Task( $cloneFolder, $cloneName, $cloneSpec )