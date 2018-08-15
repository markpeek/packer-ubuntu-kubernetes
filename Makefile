build:
	packer build -var-file=vars.json ubuntu.json

debug:
	PACKER_LOG=1 PACKER_LOG_PATH="packerlog.txt" packer build -var-file=vars.json -on-error=ask ubuntu.json
	govc export.ovf -vm "VMware-ubuntu-kubernetes" ova
	(cd ova/VMware-ubuntu-kubernetes && tar cf ../VMware-ubuntu-kubernetes.ova .)

import:
	govc import.ova -name kube-test output-kubernetes/VMware-ubuntu-kubernetes.ova

clean:
	rm -rf output-kubernetes
