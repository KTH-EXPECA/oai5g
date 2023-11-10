This is from one of the email threads in oai user mailing list: "Ultra low latency in OAI gNB". 

You need to change the tdd section in the configuration file:

for 2.5 ms TDD
```
   #tdd-UL-DL-ConfigurationCommon
# subcarrierSpacing
# 0=kHz15, 1=kHz30, 2=kHz60, 3=kHz120
       referenceSubcarrierSpacing                                    = 1;
       # pattern1
       # dl_UL_TransmissionPeriodicity
       # 0=ms0p5, 1=ms0p625, 2=ms1, 3=ms1p25, 4=ms2, 5=ms2p5, 6=ms5, 7=ms10
       dl_UL_TransmissionPeriodicity                                 = 5;
       nrofDownlinkSlots                                             = 3;
       nrofDownlinkSymbols                                           = 6;
       nrofUplinkSlots                                               = 1;
       nrofUplinkSymbols                                             = 4;
```

For 2ms TDD
```
   #tdd-UL-DL-ConfigurationCommon
# subcarrierSpacing
# 0=kHz15, 1=kHz30, 2=kHz60, 3=kHz120
       referenceSubcarrierSpacing                                    = 1;
       # pattern1
       # dl_UL_TransmissionPeriodicity
       # 0=ms0p5, 1=ms0p625, 2=ms1, 3=ms1p25, 4=ms2, 5=ms2p5, 6=ms5, 7=ms10
       dl_UL_TransmissionPeriodicity                                 = 4;
       nrofDownlinkSlots                                             = 2;
       nrofDownlinkSymbols                                           = 6;
       nrofUplinkSlots                                               = 1;
       nrofUplinkSymbols                                             = 4;
```

Also make sure you have this in the MACRLC section of the configuration
file:
```
ulsch_max_frame_inactivity=0;
```
which guarantees the the UL is scheduled in every TDD period with the
minimal UL allocation (5 PRBs by default, mcs 9). You might want to
increase this minimal allocation to something like :
```
min_grant_prb = 20;
min_grant_mcs = 16;
```
also in the MACRLC section of the configuration file. Basically for
lowest latency the UL needs to be scheduled in every TDD period,
otherwise the scheduler will wait for SR or BSR to schedule the UL and
this clearly will not work for low-latency services.

We will make a dynamic version of this, but for the moment we need to
use the parameters above to ensure that the scheduler gives resources
all the time to UE for UL. Also, the "min_grant_prb" should be
compatible with the packet size of the service you're trying to use
(i.e. each application packet should fit in the constant allocation
given in the TDD period). This all has to be done differently. We will
make a proper URLLC scheduler soon.

The other thing that is not there yet is to configure the URLLC CSI
reporting (i.e. using the low spectral-efficient MCS table). This will
report the mcs for 10^-5 transport block error rate. That's the "UR" in
URLLC. So to get the equivalent you might want to limit the DL mcs with
```
"dl_max_mcs=XX"
```
and look at the error rate in the first round of HARQ transmission on DL
(also on UL). You see this in logs that come out from the gNB. If you
really want URLLC, you need 10^-5. We have made this work in one
project, but the machines and RF need to be setup properly to ensure
there are not lost fronthaul packets and no jitter in the operating
system scheduling which will result in lost transmission. Without proper
tuning you will have 10^-3 or 10^-4 independently of the SNR.

Also, we needed to deploy the UPF in a real-time container. Normaly
Linux will not provide the require packet jitter for URLLC and this is
completely independent of the radio.
