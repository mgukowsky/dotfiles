# Shell configuration specific to AMD CPUs and GPUs

# Allow selection of Vulkan driver via environment variables, per https://wiki.archlinux.org/title/Vulkan#Selecting_via_environment_variable
export DISABLE_LAYER_AMD_SWITCHABLE_GRAPHICS_1=1

# Prefix a vulkan executable invocation to use it with a specific driver
# e.g. VK_AMD vkcube
alias VK_AMD='VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/amd_icd64.json'
alias VK_RADV='VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/radeon_icd.x86_64.json'
alias VK_AMDPRO='VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/amd_pro_icd64.json'
alias VK_SWRAST='VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.x86_64.json'

