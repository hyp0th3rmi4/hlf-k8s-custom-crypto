#set -x
if [ $# -ne 2 ]; then
   echo "Usage: ibm-to-crypto-config <ibm-input-directory> <crypto-config-output-directory>"
   exit 1
fi

if [ ! -d $1 ]; then
   echo "Input directory does not exist: $1"
   exit 1
fi

SRC=$1
DST=$2

rm -rf $DST

# doServerMSP <mspParentDir> <adminCert>
function doServerMSP {
   if [ $# -ne 2 ]; then
     echo "Usage: doServerMSP <mspParentDir> <adminCert>"
     return 1
   fi
   org=`echo $1 | cut -d '/' -f 2`
   mycopy $2 $1/msp/admincerts/admin.crt
   mycopy ca_root-certificate.crt $1/msp/cacerts/ca.crt
   mycopy ca_issuer-certificate.crt $1/msp/intermediatecerts/ca.crt
   dst=$1/msp/tlscacerts/tlsca.${org}-cert.pem
   mycopy ca_root-certificate.crt $dst
   echo "" >> $DST/$dst
   cat $SRC/ca_issuer-certificate.crt >> $DST/$dst
   mycopy ca_issuer-certificate.crt $1/msp/tlsintermediatecerts/tlsca.${org}.pem
}

# clientMSP <mspParentDir> <adminCert> <signerCert> <signerKey>
function doClientMSP {
   if [ $# -ne 4 ]; then
     echo "Usage: doClientMSP <mspParentDir> <adminCert> <signerCert> <signerKey>"
     return 1
   fi
   doServerMSP $1 $2
   mycopy $3 $1/msp/signcerts/signer.crt
   mycopy $4 $1/msp/keystore/signer.key
   mycopy ca_root-certificate.crt $1/tls/ca.crt
   echo "" >> $DST/$1/tls/ca.crt
   cat $SRC/ca_issuer-certificate.crt >> $DST/$1/tls/ca.crt
   mycopy $3 $1/tls/server.crt
   mycopy $4 $1/tls/server.key
}

function mycopy {
   if [ $# -ne 2 ]; then
     echo "Usage: mycopy <source> <destination>"
     return 1
   fi
   mkdir -p $DST/`dirname $2`
   cp $SRC/$1 $DST/$2
}

# orderer
doServerMSP ordererOrganizations/kopernik.ibm.org                                     	Admin@kopernik.ibm.org.pem
doClientMSP ordererOrganizations/kopernik.ibm.org/orderers/orderer.kopernik.ibm.org 	Admin@kopernik.ibm.org.pem orderer.kopernik.ibm.org.pem orderer.kopernik.ibm.org.key
doClientMSP ordererOrganizations/kopernik.ibm.org/users/Admin@kopernik.ibm.org      	Admin@kopernik.ibm.org.pem Admin@kopernik.ibm.org.pem Admin@kopernik.ibm.org.key

# peer org1
doServerMSP peerOrganizations/org1.kopernik.ibm.org 										Admin@org1.kopernik.ibm.org.pem
doClientMSP peerOrganizations/org1.kopernik.ibm.org/peers/peer0.org1.kopernik.ibm.org 	Admin@org1.kopernik.ibm.org.pem peer0.org1.kopernik.ibm.org.pem peer0.org1.kopernik.ibm.org.key
doClientMSP peerOrganizations/org1.kopernik.ibm.org/peers/peer1.org1.kopernik.ibm.org 	Admin@org1.kopernik.ibm.org.pem peer1.org1.kopernik.ibm.org.pem peer1.org1.kopernik.ibm.org.key
doClientMSP peerOrganizations/org1.kopernik.ibm.org/users/Admin@org1.kopernik.ibm.org 	Admin@org1.kopernik.ibm.org.pem Admin@org1.kopernik.ibm.org.pem Admin@org1.kopernik.ibm.org.key
doClientMSP peerOrganizations/org1.kopernik.ibm.org/users/User1@org1.kopernik.ibm.org 	Admin@org1.kopernik.ibm.org.pem User1@org1.kopernik.ibm.org.pem User1@org1.kopernik.ibm.org.key

# peer org2
doServerMSP peerOrganizations/org2.kopernik.ibm.org 										Admin@org2.kopernik.ibm.org.pem
doClientMSP peerOrganizations/org2.kopernik.ibm.org/peers/peer0.org2.kopernik.ibm.org 	Admin@org2.kopernik.ibm.org.pem peer0.org2.kopernik.ibm.org.pem peer0.org2.kopernik.ibm.org.key
doClientMSP peerOrganizations/org2.kopernik.ibm.org/peers/peer1.org2.kopernik.ibm.org 	Admin@org2.kopernik.ibm.org.pem peer1.org2.kopernik.ibm.org.pem peer1.org2.kopernik.ibm.org.key
doClientMSP peerOrganizations/org2.kopernik.ibm.org/users/Admin@org2.kopernik.ibm.org 	Admin@org2.kopernik.ibm.org.pem Admin@org2.kopernik.ibm.org.pem Admin@org2.kopernik.ibm.org.key
doClientMSP peerOrganizations/org2.kopernik.ibm.org/users/User1@org2.kopernik.ibm.org 	Admin@org2.kopernik.ibm.org.pem User1@org2.kopernik.ibm.org.pem User1@org2.kopernik.ibm.org.key
