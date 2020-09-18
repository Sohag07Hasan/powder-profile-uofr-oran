#!/usr/bin/env python

import geni.portal as portal
import geni.rspec.pg as RSpec
import geni.rspec.igext as IG
# Emulab specific extensions.
import geni.rspec.emulab as emulab
from lxml import etree as ET
import crypt
import random
import os.path
import sys

TBCMD = "sudo mkdir -p /local/setup && sudo chown `cat /var/emulab/boot/swapper` /local/setup && sudo -u `cat /var/emulab/boot/swapper` -Hi /bin/sh -c '/local/repository/setup-driver.sh >/local/setup/setup-driver.log 2>&1'"

#
# For now, disable the testbed's root ssh key service until we can remove ours.
# It seems to race (rarely) with our startup scripts.
#
disableTestbedRootKeys = True

#
# Create our in-memory model of the RSpec -- the resources we're going
# to request in our experiment, and their configuration.
#
rspec = RSpec.Request()

#
# This geni-lib script is designed to run in the CloudLab Portal.
#
pc = portal.Context()

#
# Define some parameters.
#
pc.defineParameter(
    "nodeCount","Number of Nodes",
    portal.ParameterType.INTEGER,1,
    longDescription="Number of nodes in your kubernetes cluster.  Should be either 1, or >= 3.")
pc.defineParameter(
    "nodeType","Hardware Type",
    portal.ParameterType.NODETYPE,"d740",
    longDescription="A specific hardware type to use for each node.  Cloudlab clusters all have machines of specific types.  When you set this field to a value that is a specific hardware type, you will only be able to instantiate this profile on clusters with machines of that type.  If unset, when you instantiate the profile, the resulting experiment may have machines of any available type allocated.")
pc.defineParameter(
    "linkSpeed","Experiment Link Speed",
    portal.ParameterType.INTEGER,0,
    [(0,"Any"),(1000000,"1Gb/s"),(10000000,"10Gb/s"),(25000000,"25Gb/s"),(40000000,"40Gb/s"),(100000000,"100Gb/s")],
    longDescription="A specific link speed to use for each link/LAN.  All experiment network interfaces will request this speed.")
pc.defineParameter(
    "diskImage","Disk Image",
    portal.ParameterType.IMAGE,
    "urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU18-64-STD",
    advanced=True,
    longDescription="An image URN or URL that every node will run.")
pc.defineParameter(
    "multiplexLans", "Multiplex Networks",
    portal.ParameterType.BOOLEAN,False,
    longDescription="Multiplex any networks over physical interfaces using VLANs.  Some physical machines have only a single experiment network interface, so if you want multiple links/LANs, you have to enable multiplexing.  Currently, if you select this option.",
    advanced=True)

pc.defineParameter(
    "kubesprayRepo","Kubespray Git Repository",
    portal.ParameterType.STRING,
    "https://github.com/kubernetes-incubator/kubespray.git",
    longDescription="Do not change this value unless you know what you are doing!  Changing would only be necessary if you have a modified fork of Kubespray.  This must be a publicly-accessible repository.",
    advanced=True)
pc.defineParameter(
    "kubesprayVersion","Kubespray Version",
    portal.ParameterType.STRING,"release-2.13",
    longDescription="A tag or commit-ish value; we will run `git checkout <value>`.  The default value is the most recent stable value we have tested.  You should only change this if you need a new feature only available on `master`, or an old feature from a prior release.",
    advanced=True)
pc.defineParameter(
    "kubesprayUseVirtualenv","Kubespray VirtualEnv",
    portal.ParameterType.BOOLEAN,True,
    longDescription="Select if you want Ansible installed in a python virtualenv; deselect to use the system-packaged Ansible.",
    advanced=True)
pc.defineParameter(
    "kubeVersion","Kubernetes Version",
    portal.ParameterType.STRING,"v1.16.14",
    longDescription="A specific release of Kubernetes to install (e.g. v1.16.3); if left empty, Kubespray will choose its current stable version and install that.  You can check for Kubespray-known releases at https://github.com/kubernetes-sigs/kubespray/blob/release-2.13/roles/download/defaults/main.yml (or if you're using a different Kubespray release, choose the corresponding feature release branch in that URL).  You can use unsupported or unknown versions, however, as long as the binaries actually exist.",
    advanced=True)
pc.defineParameter(
    "helmVersion","Helm Version",
    portal.ParameterType.STRING,"v2.12.3",
    longDescription="A specific release of Helm to install (e.g. v2.12.3); if left empty, Kubespray will choose its current stable version and install that.  Note that the version you pick must exist as a tag in this Docker image repository: https://hub.docker.com/r/lachlanevenson/k8s-helm/tags .",
    advanced=True)
pc.defineParameter(
    "dockerVersion","Docker Version",
    portal.ParameterType.STRING,"",
    longDescription="A specific Docker version to install; if left empty, Kubespray will choose its current stable version and install that.  As explained in the Kubespray documentation (https://github.com/kubernetes-sigs/kubespray/blob/master/docs/vars.md), this value must be one of those listed at, e.g. https://github.com/kubernetes-sigs/kubespray/blob/release-2.13/roles/container-engine/docker/vars/ubuntu-amd64.yml .",
    advanced=True)
pc.defineParameter(
    "dockerOptions","Dockerd Options",
    portal.ParameterType.STRING,"",
    longDescription="Extra command-line options to pass to dockerd.  The most common option is probably an --insecure-registry .",
    advanced=True)
pc.defineParameter(
    "doLocalRegistry","Create Private, Local Registry",
    portal.ParameterType.BOOLEAN,True,
    longDescription="Create a private Docker registry on the kube master, and expose it on the (private) management IP address, port 5000, and configure Kubernetes to be able to use it (--insecure-registry).  This is nearly mandatory for some development workflows, so it is on by default.",
    advanced=True)
pc.defineParameter(
    "kubeNetworkPlugin","Kubernetes Network Plugin",
    portal.ParameterType.STRING,"calico",
    [("calico","Calico"),("flannel","Flannel"),("weave","Weave"),
     ("canal","Canal")],
    longDescription="Choose the primary kubernetes network plugin.",
    advanced=True)
pc.defineParameter(
    "kubeEnableMultus","Enable Multus Network Meta Plugin",
    portal.ParameterType.BOOLEAN,False,
    longDescription="Select to enable the Multus (https://github.com/kubernetes-sigs/kubespray/blob/master/docs/multus.md) CNI meta plugin.  Multus provides multiple network interface support to pods.",
    advanced=True)
pc.defineParameter(
    "kubeProxyMode","Kube Proxy Mode",
    portal.ParameterType.STRING,"ipvs",
    [("iptables","iptables"),("ipvs","ipvs")],
    longDescription="Choose the mode for kube-proxy (comparison: https://www.projectcalico.org/comparing-kube-proxy-modes-iptables-or-ipvs/).",
    advanced=True)
pc.defineParameter(
    "kubePodsSubnet","Kubernetes Pods Subnet",
    portal.ParameterType.STRING,"10.244.0.0/16",
    longDescription="The subnet containing pod addresses.",
    advanced=True)
pc.defineParameter(
    "kubeServiceAddresses","Kubernetes Service Addresses",
    portal.ParameterType.STRING,"10.96.0.0/12",
    longDescription="The subnet containing service addresses.",
    advanced=True)
pc.defineParameter(
    "kubeDoMetalLB","Kubespray Enable MetalLB",
    portal.ParameterType.BOOLEAN,True,
    longDescription="We enable MetalLB by default, so that users can use an \"external\" load balancer service type.  You need at least one public IP address for this option because it doesn't make sense without one.",
    advanced=True)
pc.defineParameter(
    "publicIPCount", "Number of public IP addresses",
    portal.ParameterType.INTEGER,1,
    longDescription="Set the number of public IP addresses you will need for externally-published services (e.g., via a load balancer like MetalLB.",
    advanced=True)
pc.defineParameter(
    "kubeFeatureGates","Kubernetes Feature Gate List",
    portal.ParameterType.STRING,"[SCTPSupport=true]",
    longDescription="A []-enclosed, comma-separated list of features.  For instance, `[SCTPSupport=true]`.",
    advanced=True)
pc.defineParameter(
    "kubeletCustomFlags","Kubelet Custom Flags List",
    portal.ParameterType.STRING,"[--allowed-unsafe-sysctls=net.*]",
    longDescription="A []-enclosed, comma-separated list of flags.  For instance, `[--allowed-unsafe-sysctls=net.*]`.",
    advanced=True)
pc.defineParameter(
    "kubeletMaxPods","Kubelet Max Pods",
    portal.ParameterType.INTEGER,120,
    longDescription="An integer max pods limit; 0 allows Kubernetes to use its default value (currently is 110; see https://kubespray.io/#/docs/vars and look for `kubelet_max_pods`).  Do not change this unless you know what you are doing.",
    advanced=True)
pc.defineParameter(
    "sslCertType","SSL Certificate Type",
    portal.ParameterType.STRING,"self",
    [("none","None"),("self","Self-Signed"),("letsencrypt","Let's Encrypt")],
    advanced=True,
    longDescription="Choose an SSL Certificate strategy.  By default, we generate self-signed certificates, and only use them for a reverse web proxy to allow secure remote access to the Kubernetes Dashboard.  However, you may choose `None` if you prefer to arrange remote access differently (e.g. ssh port forwarding).  You may also choose to use Let's Encrypt certificates whose trust root is accepted by all modern browsers.")
pc.defineParameter(
    "sslCertConfig","SSL Certificate Configuration",
    portal.ParameterType.STRING,"proxy",
    [("proxy","Web Proxy")],
    advanced=True,
    longDescription="Choose where you want the SSL certificates deployed.  Currently the only option is for them to be configured as part of the web proxy to the dashboard.")

#
# Get any input parameter values that will override our defaults.
#
params = pc.bindParameters()

if params.publicIPCount > 8:
    perr = portal.ParameterWarning(
        "You cannot request more than 8 public IP addresses, at least not without creating your own modified version of this profile!",
        ["publicIPCount"])
    pc.reportWarning(perr)
if params.kubeDoMetalLB and params.publicIPCount < 1:
    perr = portal.ParameterWarning(
        "If you enable MetalLB, you must request at least one public IP address!",
        ["kubeDoMetalLB","publicIPCount"])
    pc.reportWarning(perr)

#
# Give the library a chance to return nice JSON-formatted exception(s) and/or
# warnings; this might sys.exit().
#
pc.verifyParameters()

tourDescription = \
  "This profile creates a kubernetes cluster with kubespray, and installs the O-RAN Near-RT RIC on it.  When you click the Instantiate button, you'll be presented with a list of parameters that you can change to control what your kubernetes cluster will look like; read the parameter documentation on that page (or in the Instructions)."

tourInstructions = \
  """
### Basic Instructions
Once your experiment nodes have booted, and this profile's configuration scripts have finished configuring kubernetes inside your experiment, you'll be able to visit [the Kubernetes Dashboard WWW interface](https://{host-node-0}:8080/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login) (approx. 10-15 minutes).

The dashboard will not be available immediately.  There are multiple ways to determine if the scripts have finished.
  - First, you can watch the experiment status page: the overall State will say \"booted (startup services are still running)\" to indicate that the nodes have booted up, but the setup scripts are still running.
  - Second, the Topology View will show you, for each node, the status of the startup command on each node (the startup command kicks off the setup scripts on each node).  Once the startup command has finished on each node, the overall State field will change to \"ready\".  If any of the startup scripts fail, you can mouse over the failed node in the topology viewer for the status code.
  - Third, the profile configuration scripts also send you two emails: once to notify you that kubernetes setup has started, and a second to notify you that setup has completed.  Once you receive the second email, you can login to the dashboard and begin your work.
  - Finally, you can view [the profile setup script logfiles](http://{host-node-0}:7999/) as the setup scripts run.  Use the `admin` username and the automatically-generated random password `{password-adminPass}` .

Once the dashboard is available, you can login with either basic or token authentication.  (You may also supply a kubeconfig file, but we don't provide one that includes a secret by default.)
  - `basic`: username `admin`, password `{password-adminPass}`
  - `token`: copy the token from http://{host-node-0}:7999/admin-token.txt (this file is located on `node-0` in `/local/setup/admin-token.txt`)

(To provide secure dashboard access, we run a `kube-proxy` instance that listens on localhost:8888 and accepts all incoming hosts, and export that via nginx proxy listening on `{host-node-0}:8080`.  We also create an `admin` `serviceaccount` in the `default` namespace, and that is the serviceaccount associated with the token auth option mentioned just above.)

Kubernetes credentials are in `~/.kube/config`, or in `/root/.kube/config`, as you'd expect.

The profile's setup scripts are automatically installed on each node in `/local/repository`, and all of the Kubernetes installation is triggered from `node-0`.  The scripts execute as your uid, and keep state and downloaded files in `/local/setup/`.  The scripts write copious logfiles in that directory; so if you think there's a problem with the configuration, you could take a quick look through these logs on the `node-0` node.  The primary logfile is `/local/setup/setup-driver.log`.

Kubespray is a collection of Ansible playbooks, so you can make changes to the deployed kubernetes cluster, or even destroy and rebuild it (although you would then lose any of the post-install configuration we do in `/local/repository/setup-kubernetes-extra.sh`).  The `/local/repository/setup-kubespray.sh` script installs Ansible inside a Python 3 `virtualenv` (in `/local/setup/kubespray-virtualenv` on `node-0`).  A `virtualenv` (or `venv`) is effectively a separate part of the filesystem containing Python libraries and scripts, and a set of environment variables and paths that restrict its user to those Python libraries and scripts.  To modify your cluster's configuration in the Kubespray/Ansible way, you can run commands like these (as your uid):

1. "Enter" (or access) the `virtualenv`: `. /local/setup/kubespray-virtualenv/bin/activate`
2. Leave (or remove the environment vars from your shell session) the `virtualenv`: `deactivate`
3. Destroy your entire kubernetes cluster: `ansible-playbook -i /local/setup/inventories/emulab/inventory.ini /local/setup/kubespray/remove-node.yml -b -v --extra-vars "node=node-0,node-1,node-2"`
   (note that you would want to supply the short names of all nodes in your experiment)
4. Recreate your kubernetes cluster: `ansible-playbook -i /local/setup/inventories/emulab/inventory.ini /local/setup/kubespray/cluster.yml -b -v`

To change the Ansible and playbook configuration, you can start reading Kubespray documentation:
  - https://github.com/kubernetes-sigs/kubespray/blob/master/docs/getting-started.md
  - https://github.com/kubernetes-sigs/kubespray
  - https://kubespray.io/
"""

#
# Setup the Tour info with the above description and instructions.
#  
tour = IG.Tour()
tour.Description(IG.Tour.TEXT,tourDescription)
tour.Instructions(IG.Tour.MARKDOWN,tourInstructions)
rspec.addTour(tour)

datalans = []

if params.nodeCount > 1:
    datalan = RSpec.LAN("datalan-1")
    if params.linkSpeed > 0:
        datalan.bandwidth = int(params.linkSpeed)
    if params.multiplexLans:
        datalan.link_multiplexing = True
        datalan.best_effort = True
        # Need this cause LAN() sets the link type to lan, not sure why.
        datalan.type = "vlan"
    datalans.append(datalan)

nodes = dict({})

for i in range(0,params.nodeCount):
    nodename = "node-%d" % (i,)
    node = RSpec.RawPC(nodename)
    if params.nodeType:
        node.hardware_type = params.nodeType
    if params.diskImage:
        node.disk_image = params.diskImage
    j = 0
    for datalan in datalans:
        iface = node.addInterface("if%d" % (j,))
        datalan.addInterface(iface)
        j += 1
    if TBCMD is not None:
        node.addService(RSpec.Execute(shell="sh",command=TBCMD))
    if disableTestbedRootKeys:
        node.installRootKeys(False, False)
    nodes[nodename] = node

for nname in nodes.keys():
    rspec.addResource(nodes[nname])
for datalan in datalans:
    rspec.addResource(datalan)

class EmulabEncrypt(RSpec.Resource):
    def _write(self, root):
        ns = "{http://www.protogeni.net/resources/rspec/ext/emulab/1}"
        el = ET.SubElement(root,"%spassword" % (ns,),attrib={'name':'adminPass'})

adminPassResource = EmulabEncrypt()
rspec.addResource(adminPassResource)

#
# Grab a few public IP addresses.
#
apool = IG.AddressPool("node-0",params.publicIPCount)
try:
    apool.Site("1")
except:
    pass
rspec.addResource(apool)

pc.printRequestRSpec(rspec)
