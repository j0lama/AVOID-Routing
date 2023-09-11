#!/usr/bin/env python

kube_description= \
"""
AVOID Routing
"""
kube_instruction= \
"""
Author: Jon Larrea
"""


import geni.portal as portal
import geni.rspec.pg as PG
import geni.rspec.igext as IG


pc = portal.Context()
rspec = PG.Request()


# Profile parameters.
pc.defineParameter("Hardware", "Machine Hardware",
                   portal.ParameterType.STRING,"d430",[("d430","d430"),("d710","d710"), ("d820", "d820"), ("pc3000", "pc3000")])
pc.defineParameter("gateways", "Number of Gateways",
                   portal.ParameterType.INTEGER, 1)


params = pc.bindParameters()

#
# Give the library a chance to return nice JSON-formatted exception(s) and/or
# warnings; this might sys.exit().
#
pc.verifyParameters()



tour = IG.Tour()
tour.Description(IG.Tour.TEXT,kube_description)
tour.Instructions(IG.Tour.MARKDOWN,kube_instruction)
rspec.addTour(tour)


# Network
netmask="255.255.255.0"
network = rspec.Link("Network")
network.link_multiplexing = True
network.vlan_tagging = True
network.best_effort = True

# Gateways
for i in range(0,params.gateways):
    gw = rspec.RawPC("gateway" + str(i+1))
    gw.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
    gw.addService(PG.Execute(shell="bash", command="sudo /local/repository/scripts/setup.sh gw"))
    gw.hardware_type = params.Hardware
    iface = gw.addInterface()
    iface.addAddress(PG.IPv4Address("192.168.1."+str(i+2), netmask))
    network.addInterface(iface)

i+=1

# Home Gateway
home_gw = rspec.RawPC("home_gw")
home_gw.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD'
home_gw.addService(PG.Execute(shell="bash", command=" sudo /local/repository/scripts/setup.sh home_gw"))
home_gw.hardware_type = params.Hardware
iface = home_gw.addInterface()
iface.addAddress(PG.IPv4Address("192.168.1.1", netmask))
network.addInterface(iface)


#
# Print and go!
#
pc.printRequestRSpec(rspec)