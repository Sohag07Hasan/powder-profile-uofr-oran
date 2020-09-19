#!/bin/sh

set -x

export SRC=`dirname $0`
cd $SRC
. $SRC/setup-lib.sh

if [ -f $OURDIR/setup-ran-done ]; then
    echo "setup-ran already ran; not running again"
    exit 0
fi

#
# OAI build
#
cd $OURDIR

git clone https://gitlab.flux.utah.edu/powderrenewpublic/oai-ric
cd oai-ric
git checkout develop-oran-ric
cd cmake_targets

wget -O $OURDIR/E2AP-generated-bindings.tar.gz \
    https://www.emulab.net/downloads/johnsond/profile-oai-oran/E2AP-generated-bindings.tar.gz
wget -O $OURDIR/E2SM-KPM-generated-bindings.tar.gz \
    https://www.emulab.net/downloads/johnsond/profile-oai-oran/E2SM-KPM-generated-bindings.tar.gz
wget -O $OURDIR/E2SM-NI-generated-bindings.tar.gz \
    https://www.emulab.net/downloads/johnsond/profile-oai-oran/E2SM-NI-generated-bindings.tar.gz
wget -O $OURDIR/E2SM-GNB-NRT-generated-bindings.tar.gz \
    https://www.emulab.net/downloads/johnsond/profile-oai-oran/E2SM-GNB-NRT-generated-bindings.tar.gz
tar -xzvf $OURDIR/E2AP-generated-bindings.tar.gz -C $OURDIR
tar -xzvf $OURDIR/E2SM-KPM-generated-bindings.tar.gz -C $OURDIR
tar -xzvf $OURDIR/E2SM-NI-generated-bindings.tar.gz -C $OURDIR
tar -xzvf $OURDIR/E2SM-GNB-NRT-generated-bindings.tar.gz -C $OURDIR

./build_oai -I --eNB --UE -w SIMU -g --verbose-compile \
    --build-ric-agent --with-ric-generated-e2ap-binding-dir $OURDIR/E2AP \
    --with-ric-generated-e2sm-kpm-binding-dir $OURDIR/E2SM-KPM \
    --with-ric-generated-e2sm-ni-binding-dir $OURDIR/E2SM-NI \
    --with-ric-generated-e2sm-gnb-nrt-binding-dir $OURDIR/E2SM-GNB-NRT

cat <<EOF >$OURDIR/enb-fdd-aws.conf
Active_eNBs = ( "eNB-Eurecom-LTEBox");
# Asn1_verbosity, choice in: none, info, annoying
Asn1_verbosity = "none";

eNBs =
(
 {
    ////////// Identification parameters:
    eNB_ID    =  0x1;

    RIC : {
        remote_ipv4_addr = "$E2TERM_IP";
        remote_port = 36422;
        enabled = "yes";
    };

    cell_type =  "CELL_MACRO_ENB";

    eNB_name  =  "eNB-Eurecom-LTEBox";

    // Tracking area code, 0x0000 and 0xfffe are reserved values
    tracking_area_code  =  1;

    plmn_list = ( { mcc = 998; mnc = 98; mnc_length = 2; } );

    tr_s_preference     = "local_mac"

    ////////// Physical parameters:

    component_carriers = (
      {
      node_function             = "3GPP_eNODEB";
      node_timing               = "synch_to_ext_device";
      node_synch_ref            = 0;
      frame_type                                      = "FDD";
      tdd_config                                      = 3;
      tdd_config_s                                    = 0;
      prefix_type                                     = "NORMAL";
      eutra_band                                      = 4;
      downlink_frequency                              = 2125000000L;
      uplink_frequency_offset                         = -400000000;
      Nid_cell                                        = 1;
      N_RB_DL                                         = 25;
      Nid_cell_mbsfn                                  = 0;
      nb_antenna_ports                                = 1;
      nb_antennas_tx                                  = 1;
      nb_antennas_rx                                  = 1;
      tx_gain                                            = 90;
      rx_gain                                            = 125;
      pbch_repetition                                 = "FALSE";
      prach_root                                      = 0;
      prach_config_index                              = 0;
      prach_high_speed                                = "DISABLE";
      prach_zero_correlation                          = 1;
      prach_freq_offset                               = 2;
      pucch_delta_shift                               = 1;
      pucch_nRB_CQI                                   = 0;
      pucch_nCS_AN                                    = 0;
      pucch_n1_AN                                     = 0;
      pdsch_referenceSignalPower                              = 20;
      pdsch_p_b                                               = 0;
      pusch_n_SB                                              = 1;
      pusch_enable64QAM                                       = "DISABLE";
      pusch_hoppingMode                                  = "interSubFrame";
      pusch_hoppingOffset                                = 0;
      pusch_groupHoppingEnabled                               = "ENABLE";
      pusch_groupAssignment                                   = 0;
      pusch_sequenceHoppingEnabled                            = "DISABLE";
      pusch_nDMRS1                                       = 1;
      phich_duration                                     = "NORMAL";
      phich_resource                                     = "ONESIXTH";
      srs_enable                                         = "DISABLE";
      /*  srs_BandwidthConfig                                =;
      srs_SubframeConfig                                 =;
      srs_ackNackST                                      =;
      srs_MaxUpPts                                       =;*/

      pusch_p0_Nominal                                   = -96;
      pusch_alpha                                        = "AL1";
      pucch_p0_Nominal                                   = -104;
      msg3_delta_Preamble                                = 6;
      pucch_deltaF_Format1                               = "deltaF2";
      pucch_deltaF_Format1b                              = "deltaF3";
      pucch_deltaF_Format2                               = "deltaF0";
      pucch_deltaF_Format2a                              = "deltaF0";
      pucch_deltaF_Format2b                           = "deltaF0";

      rach_numberOfRA_Preambles                          = 64;
      rach_preamblesGroupAConfig                         = "DISABLE";
      /*
      rach_sizeOfRA_PreamblesGroupA                      = ;
      rach_messageSizeGroupA                             = ;
      rach_messagePowerOffsetGroupB                      = ;
      */
      rach_powerRampingStep                              = 4;
      rach_preambleInitialReceivedTargetPower            = -108;
      rach_preambleTransMax                              = 10;
      rach_raResponseWindowSize                          = 10;
      rach_macContentionResolutionTimer                  = 48;
      rach_maxHARQ_Msg3Tx                                = 4;

      pcch_default_PagingCycle                           = 128;
      pcch_nB                                            = "oneT";
      bcch_modificationPeriodCoeff                            = 2;
      ue_TimersAndConstants_t300                              = 1000;
      ue_TimersAndConstants_t301                              = 1000;
      ue_TimersAndConstants_t310                              = 1000;
      ue_TimersAndConstants_t311                              = 10000;
      ue_TimersAndConstants_n310                              = 20;
      ue_TimersAndConstants_n311                              = 1;
      ue_TransmissionMode                                    = 1;

      //Parameters for SIB18
      rxPool_sc_CP_Len                                       = "normal";
      rxPool_sc_Period                                       = "sf40";
      rxPool_data_CP_Len                                     = "normal";
      rxPool_ResourceConfig_prb_Num                          = 20;
      rxPool_ResourceConfig_prb_Start                        = 5;
      rxPool_ResourceConfig_prb_End                          = 44;
      rxPool_ResourceConfig_offsetIndicator_present          = "prSmall";
      rxPool_ResourceConfig_offsetIndicator_choice           = 0;
      rxPool_ResourceConfig_subframeBitmap_present           = "prBs40";
      rxPool_ResourceConfig_subframeBitmap_choice_bs_buf              = "00000000000000000000";
      rxPool_ResourceConfig_subframeBitmap_choice_bs_size             = 5;
      rxPool_ResourceConfig_subframeBitmap_choice_bs_bits_unused      = 0;
/*    rxPool_dataHoppingConfig_hoppingParameter                       = 0;
      rxPool_dataHoppingConfig_numSubbands                            = "ns1";
      rxPool_dataHoppingConfig_rbOffset                               = 0;
      rxPool_commTxResourceUC-ReqAllowed                              = "TRUE";
*/
      // Parameters for SIB19
      discRxPool_cp_Len                                               = "normal"
      discRxPool_discPeriod                                           = "rf32"
      discRxPool_numRetx                                              = 1;
      discRxPool_numRepetition                                        = 2;
      discRxPool_ResourceConfig_prb_Num                               = 5;
      discRxPool_ResourceConfig_prb_Start                             = 3;
      discRxPool_ResourceConfig_prb_End                               = 21;
      discRxPool_ResourceConfig_offsetIndicator_present               = "prSmall";
      discRxPool_ResourceConfig_offsetIndicator_choice                = 0;
      discRxPool_ResourceConfig_subframeBitmap_present                = "prBs40";
      discRxPool_ResourceConfig_subframeBitmap_choice_bs_buf          = "f0ffffffff";
      discRxPool_ResourceConfig_subframeBitmap_choice_bs_size         = 5;
      discRxPool_ResourceConfig_subframeBitmap_choice_bs_bits_unused  = 0;

      }
    );


    srb1_parameters :
    {
        # timer_poll_retransmit = (ms) [5, 10, 15, 20,... 250, 300, 350, ... 500]
        timer_poll_retransmit    = 80;

        # timer_reordering = (ms) [0,5, ... 100, 110, 120, ... ,200]
        timer_reordering         = 35;

        # timer_reordering = (ms) [0,5, ... 250, 300, 350, ... ,500]
        timer_status_prohibit    = 0;

        # poll_pdu = [4, 8, 16, 32 , 64, 128, 256, infinity(>10000)]
        poll_pdu                 =  4;

        # poll_byte = (kB) [25,50,75,100,125,250,375,500,750,1000,1250,1500,2000,3000,infinity(>10000)]
        poll_byte                =  99999;

        # max_retx_threshold = [1, 2, 3, 4 , 6, 8, 16, 32]
        max_retx_threshold       =  4;
    }

    # ------- SCTP definitions
    SCTP :
    {
        # Number of streams to use in input/output
        SCTP_INSTREAMS  = 2;
        SCTP_OUTSTREAMS = 2;
    };


    ////////// MME parameters:
    mme_ip_address      = ( { ipv4       = "$EPC_IP";
                              ipv6       = "192:168:30::17";
                              active     = "yes";
                              preference = "ipv4";
                            }
                          );

    enable_measurement_reports = "no";

    ///X2
    enable_x2 = "yes";
    t_reloc_prep      = 10000;      /* unit: millisecond */
    tx2_reloc_overall = 20000;      /* unit: millisecond */

    enable_e2ap = "yes";

    NETWORK_INTERFACES :
    {
        ENB_INTERFACE_NAME_FOR_S1_MME            = "eno1";
        ENB_IPV4_ADDRESS_FOR_S1_MME              = "$RAN_IP";
        ENB_INTERFACE_NAME_FOR_S1U               = "eno1";
        ENB_IPV4_ADDRESS_FOR_S1U                 = "$RAN_IP/24";
        ENB_PORT_FOR_S1U                         = 2152; # Spec 2152

        ENB_IPV4_ADDRESS_FOR_X2C                 = "$RAN_IP/24";
        ENB_PORT_FOR_X2C                         = 36422; # Spec 36422
    };

  }
);

DU = (
    {
        DU_INTERFACE_NAME_FOR_F1U           = "lo";
        DU_IPV4_ADDRESS_FOR_F1U             = "127.0.0.1/16";
        DU_PORT_FOR_F1U                     = 22100;
        F1_U_DU_TRANSPORT_TYPE              = "TCP";
    }
    );

CU = (
    {
        CU_INTERFACE_NAME_FOR_F1U           = "lo";
        CU_IPV4_ADDRESS_FOR_F1U             = "127.0.0.1";   //Address to search the DU
        CU_PORT_FOR_F1U                     = 22100;
        F1_U_CU_TRANSPORT_TYPE              = "TCP";         // One of TCP/UDP/SCTP
        DU_TYPE                             = "LTE";
    }
    );

    CU_BALANCING = "ALL";

MACRLCs = (
        {
        num_cc = 1;
        tr_s_preference = "local_L1";
        tr_n_preference = "local_RRC";
        phy_test_mode = 0;
        puSch10xSnr     =  200;
        puCch10xSnr     =  200;
        }
);

L1s = (
        {
        num_cc = 1;
        tr_n_preference = "local_mac";
        }
);

RUs = (
    {
       local_rf       = "yes"
         nb_tx          = 1
         nb_rx          = 1
         att_tx         = 0
         att_rx         = 0;
         bands          = [4];
         max_pdschReferenceSignalPower = 20;
         max_rxgain                    = 125;
         eNB_instances  = [0];

    }
);

NETWORK_CONTROLLER :
{
    FLEXRAN_ENABLED        = "no";
    FLEXRAN_INTERFACE_NAME = "lo";
    FLEXRAN_IPV4_ADDRESS   = "127.0.0.1";
    FLEXRAN_PORT           = 2210;
    FLEXRAN_CACHE          = "/local/oai_agent_cache";
    FLEXRAN_AWAIT_RECONF   = "no";
};

THREAD_STRUCT = (
  {
    #three config for level of parallelism "PARALLEL_SINGLE_THREAD", "PARALLEL_RU_L1_SPLIT", or "PARALLEL_RU_L1_TRX_SPLIT"
    parallel_config    = "PARALLEL_SINGLE_THREAD";
    #two option for worker "WORKER_DISABLE" or "WORKER_ENABLE"
    worker_config      = "WORKER_ENABLE";
  }
);

     log_config :
     {
       global_log_level                      ="info";
       global_log_verbosity                  ="medium";
       hw_log_level                          ="info";
       hw_log_verbosity                      ="medium";
       phy_log_level                         ="info";
       phy_log_verbosity                     ="medium";
       mac_log_level                         ="info";
       mac_log_verbosity                     ="high";
       rlc_log_level                         ="info";
       rlc_log_verbosity                     ="medium";
       pdcp_log_level                        ="info";
       pdcp_log_verbosity                    ="medium";
       rrc_log_level                         ="info";
       rrc_log_verbosity                     ="medium";
    };

EOF

cat <<EOF >$OURDIR/enb-tdd-cbrs.conf
Active_eNBs = ( "eNB-Eurecom-LTEBox");
# Asn1_verbosity, choice in: none, info, annoying
Asn1_verbosity = "none";

eNBs =
(
 {
    ////////// Identification parameters:
    eNB_ID    =  0x1;

    RIC : {
        remote_ipv4_addr = "$E2TERM_IP";
        remote_port = 36422;
        enabled = "yes";
    };

    cell_type =  "CELL_MACRO_ENB";

    eNB_name  =  "eNB-Eurecom-LTEBox";

    // Tracking area code, 0x0000 and 0xfffe are reserved values
    tracking_area_code  =  1;

    plmn_list = ( { mcc = 998; mnc = 98; mnc_length = 2; } );

    tr_s_preference     = "local_mac"

    ////////// Physical parameters:

    component_carriers = (
      {
      node_function             = "3GPP_eNODEB";
      node_timing               = "synch_to_ext_device";
      node_synch_ref            = 0;
      frame_type                                      = "TDD";
      tdd_config                                      = 3;
      tdd_config_s                                    = 0;
      prefix_type                                     = "NORMAL";
      eutra_band                                      = 48;
      downlink_frequency                              = 3600000000L;
      uplink_frequency_offset                         = 0;
      Nid_cell                                        = 1;
      N_RB_DL                                         = 50;
      Nid_cell_mbsfn                                  = 0;
      nb_antenna_ports                                = 1;
      nb_antennas_tx                                  = 1;
      nb_antennas_rx                                  = 1;
      tx_gain                                            = 90;
      rx_gain                                            = 125;
      pbch_repetition                                 = "FALSE";
      prach_root                                      = 0;
      prach_config_index                              = 0;
      prach_high_speed                                = "DISABLE";
      prach_zero_correlation                          = 1;
      prach_freq_offset                               = 2;
      pucch_delta_shift                               = 1;
      pucch_nRB_CQI                                   = 0;
      pucch_nCS_AN                                    = 0;
      pucch_n1_AN                                     = 0;
      pdsch_referenceSignalPower                              = 20;
      pdsch_p_b                                               = 0;
      pusch_n_SB                                              = 1;
      pusch_enable64QAM                                       = "DISABLE";
      pusch_hoppingMode                                  = "interSubFrame";
      pusch_hoppingOffset                                = 0;
      pusch_groupHoppingEnabled                               = "ENABLE";
      pusch_groupAssignment                                   = 0;
      pusch_sequenceHoppingEnabled                            = "DISABLE";
      pusch_nDMRS1                                       = 1;
      phich_duration                                     = "NORMAL";
      phich_resource                                     = "ONESIXTH";
      srs_enable                                         = "DISABLE";
      /*  srs_BandwidthConfig                                =;
      srs_SubframeConfig                                 =;
      srs_ackNackST                                      =;
      srs_MaxUpPts                                       =;*/

      pusch_p0_Nominal                                   = -96;
      pusch_alpha                                        = "AL1";
      pucch_p0_Nominal                                   = -104;
      msg3_delta_Preamble                                = 6;
      pucch_deltaF_Format1                               = "deltaF2";
      pucch_deltaF_Format1b                              = "deltaF3";
      pucch_deltaF_Format2                               = "deltaF0";
      pucch_deltaF_Format2a                              = "deltaF0";
      pucch_deltaF_Format2b                           = "deltaF0";

      rach_numberOfRA_Preambles                          = 64;
      rach_preamblesGroupAConfig                         = "DISABLE";
      /*
      rach_sizeOfRA_PreamblesGroupA                      = ;
      rach_messageSizeGroupA                             = ;
      rach_messagePowerOffsetGroupB                      = ;
      */
      rach_powerRampingStep                              = 4;
      rach_preambleInitialReceivedTargetPower            = -108;
      rach_preambleTransMax                              = 10;
      rach_raResponseWindowSize                          = 10;
      rach_macContentionResolutionTimer                  = 48;
      rach_maxHARQ_Msg3Tx                                = 4;

      pcch_default_PagingCycle                           = 128;
      pcch_nB                                            = "oneT";
      bcch_modificationPeriodCoeff                            = 2;
      ue_TimersAndConstants_t300                              = 1000;
      ue_TimersAndConstants_t301                              = 1000;
      ue_TimersAndConstants_t310                              = 1000;
      ue_TimersAndConstants_t311                              = 10000;
      ue_TimersAndConstants_n310                              = 20;
      ue_TimersAndConstants_n311                              = 1;
      ue_TransmissionMode                                    = 1;

      //Parameters for SIB18
      rxPool_sc_CP_Len                                       = "normal";
      rxPool_sc_Period                                       = "sf40";
      rxPool_data_CP_Len                                     = "normal";
      rxPool_ResourceConfig_prb_Num                          = 20;
      rxPool_ResourceConfig_prb_Start                        = 5;
      rxPool_ResourceConfig_prb_End                          = 44;
      rxPool_ResourceConfig_offsetIndicator_present          = "prSmall";
      rxPool_ResourceConfig_offsetIndicator_choice           = 0;
      rxPool_ResourceConfig_subframeBitmap_present           = "prBs40";
      rxPool_ResourceConfig_subframeBitmap_choice_bs_buf              = "00000000000000000000";
      rxPool_ResourceConfig_subframeBitmap_choice_bs_size             = 5;
      rxPool_ResourceConfig_subframeBitmap_choice_bs_bits_unused      = 0;
/*    rxPool_dataHoppingConfig_hoppingParameter                       = 0;
      rxPool_dataHoppingConfig_numSubbands                            = "ns1";
      rxPool_dataHoppingConfig_rbOffset                               = 0;
      rxPool_commTxResourceUC-ReqAllowed                              = "TRUE";
*/
      // Parameters for SIB19
      discRxPool_cp_Len                                               = "normal"
      discRxPool_discPeriod                                           = "rf32"
      discRxPool_numRetx                                              = 1;
      discRxPool_numRepetition                                        = 2;
      discRxPool_ResourceConfig_prb_Num                               = 5;
      discRxPool_ResourceConfig_prb_Start                             = 3;
      discRxPool_ResourceConfig_prb_End                               = 21;
      discRxPool_ResourceConfig_offsetIndicator_present               = "prSmall";
      discRxPool_ResourceConfig_offsetIndicator_choice                = 0;
      discRxPool_ResourceConfig_subframeBitmap_present                = "prBs40";
      discRxPool_ResourceConfig_subframeBitmap_choice_bs_buf          = "f0ffffffff";
      discRxPool_ResourceConfig_subframeBitmap_choice_bs_size         = 5;
      discRxPool_ResourceConfig_subframeBitmap_choice_bs_bits_unused  = 0;

      }
    );


    srb1_parameters :
    {
        # timer_poll_retransmit = (ms) [5, 10, 15, 20,... 250, 300, 350, ... 500]
        timer_poll_retransmit    = 80;

        # timer_reordering = (ms) [0,5, ... 100, 110, 120, ... ,200]
        timer_reordering         = 35;

        # timer_reordering = (ms) [0,5, ... 250, 300, 350, ... ,500]
        timer_status_prohibit    = 0;

        # poll_pdu = [4, 8, 16, 32 , 64, 128, 256, infinity(>10000)]
        poll_pdu                 =  4;

        # poll_byte = (kB) [25,50,75,100,125,250,375,500,750,1000,1250,1500,2000,3000,infinity(>10000)]
        poll_byte                =  99999;

        # max_retx_threshold = [1, 2, 3, 4 , 6, 8, 16, 32]
        max_retx_threshold       =  4;
    }

    # ------- SCTP definitions
    SCTP :
    {
        # Number of streams to use in input/output
        SCTP_INSTREAMS  = 2;
        SCTP_OUTSTREAMS = 2;
    };


    ////////// MME parameters:
    mme_ip_address      = ( { ipv4       = "$EPC_IP";
                              ipv6       = "192:168:30::17";
                              active     = "yes";
                              preference = "ipv4";
                            }
                          );

    enable_measurement_reports = "no";

    ///X2
    enable_x2 = "yes";
    t_reloc_prep      = 10000;      /* unit: millisecond */
    tx2_reloc_overall = 20000;      /* unit: millisecond */

    enable_e2ap = "yes";

    NETWORK_INTERFACES :
    {
        ENB_INTERFACE_NAME_FOR_S1_MME            = "eno1";
        ENB_IPV4_ADDRESS_FOR_S1_MME              = "$RAN_IP";
        ENB_INTERFACE_NAME_FOR_S1U               = "eno1";
        ENB_IPV4_ADDRESS_FOR_S1U                 = "$RAN_IP/24";
        ENB_PORT_FOR_S1U                         = 2152; # Spec 2152

        ENB_IPV4_ADDRESS_FOR_X2C                 = "$RAN_IP/24";
        ENB_PORT_FOR_X2C                         = 36422; # Spec 36422
    };

  }
);

DU = (
    {
        DU_INTERFACE_NAME_FOR_F1U           = "lo";
        DU_IPV4_ADDRESS_FOR_F1U             = "127.0.0.1/16";
        DU_PORT_FOR_F1U                     = 22100;
        F1_U_DU_TRANSPORT_TYPE              = "TCP";
    }
    );

CU = (
    {
        CU_INTERFACE_NAME_FOR_F1U           = "lo";
        CU_IPV4_ADDRESS_FOR_F1U             = "127.0.0.1";   //Address to search the DU
        CU_PORT_FOR_F1U                     = 22100;
        F1_U_CU_TRANSPORT_TYPE              = "TCP";         // One of TCP/UDP/SCTP
        DU_TYPE                             = "LTE";
    }
    );

    CU_BALANCING = "ALL";

MACRLCs = (
        {
        num_cc = 1;
        tr_s_preference = "local_L1";
        tr_n_preference = "local_RRC";
        phy_test_mode = 0;
        puSch10xSnr     =  200;
        puCch10xSnr     =  200;
        }
);

L1s = (
        {
        num_cc = 1;
        tr_n_preference = "local_mac";
        }
);

RUs = (
    {
       local_rf       = "yes"
         nb_tx          = 1
         nb_rx          = 1
         att_tx         = 0
         att_rx         = 0;
         bands          = [4];
         max_pdschReferenceSignalPower = 20;
         max_rxgain                    = 125;
         eNB_instances  = [0];

    }
);

NETWORK_CONTROLLER :
{
    FLEXRAN_ENABLED        = "no";
    FLEXRAN_INTERFACE_NAME = "lo";
    FLEXRAN_IPV4_ADDRESS   = "127.0.0.1";
    FLEXRAN_PORT           = 2210;
    FLEXRAN_CACHE          = "/local/oai_agent_cache";
    FLEXRAN_AWAIT_RECONF   = "no";
};

THREAD_STRUCT = (
  {
    #three config for level of parallelism "PARALLEL_SINGLE_THREAD", "PARALLEL_RU_L1_SPLIT", or "PARALLEL_RU_L1_TRX_SPLIT"
    parallel_config    = "PARALLEL_SINGLE_THREAD";
    #two option for worker "WORKER_DISABLE" or "WORKER_ENABLE"
    worker_config      = "WORKER_ENABLE";
  }
);

     log_config :
     {
       global_log_level                      ="info";
       global_log_verbosity                  ="medium";
       hw_log_level                          ="info";
       hw_log_verbosity                      ="medium";
       phy_log_level                         ="info";
       phy_log_verbosity                     ="medium";
       mac_log_level                         ="info";
       mac_log_verbosity                     ="high";
       rlc_log_level                         ="info";
       rlc_log_verbosity                     ="medium";
       pdcp_log_level                        ="info";
       pdcp_log_verbosity                    ="medium";
       rrc_log_level                         ="info";
       rrc_log_verbosity                     ="medium";
    };

EOF

ln -s $OURDIR/enb-fdd-aws.conf $OURDIR/enb.conf

#
# srsLTE build
#
cd $OURDIR

maybe_install_packages \
    cmake libfftw3-dev libmbedtls-dev libboost-program-options-dev \
    libconfig++-dev libsctp-dev libzmq3-dev

git clone https://gitlab.flux.utah.edu/powderrenewpublic/srslte-ric
cd srslte-ric
mkdir -p build
cd build
cmake ../ \
    -DRIC_GENERATED_E2AP_BINDING_DIR=$OURDIR/E2AP \
    -DRIC_GENERATED_E2SM_KPM_BINDING_DIR=$OURDIR/E2SM-KPM \
    -DRIC_GENERATED_E2SM_NI_BINDING_DIR=$OURDIR/E2SM-NI \
    -DRIC_GENERATED_E2SM_GNB_NRT_BINDING_DIR=$OURDIR/E2SM-GNB-NRT
NCPUS=`grep proc /proc/cpuinfo | wc -l`
if [ -n "$NCPUS" ]; then
    make -j$NCPUS
else
    make
fi
$SUDO make install
$SUDO ./srslte_install_configs.sh service

touch $OURDIR/setup-ran-done

exit 0