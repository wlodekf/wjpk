# -*- coding: utf-8 -*-

from Crypto.Cipher import AES, PKCS1_v1_5
from Crypto.Hash import SHA256, MD5
from Crypto.PublicKey import RSA
from Crypto import Random

import base64, StringIO, zipfile, json, requests, sys, string, re
    
MF_URL= 'https://test-e-dokumenty.mf.gov.pl/api/Storage'
KEY_SIZE= 32 # AES256
BS= 16

padding= lambda s: s + (BS - len(s) % BS) * chr(BS - len(s) % BS) 

requests.packages.urllib3.disable_warnings() # Tymczasowo

def init_upload(jpk_nazwa):
    """
    wydobycie klucza z certyfikatu MF    
    openssl x509 -inform pem -in cert_mf.pem -pubkey -noout > klucz_mf.pem
    """
    
    jpk_xml= open(jpk_nazwa, 'rb').read()
    jpk= {'xml_nazwa': jpk_nazwa,
          'kod': re.search('kodSystemowy="(\w+) ', jpk_xml).group(1),
          'xml_len': len(jpk_xml)
         }
    
    # losowy 256 bitowy klucz szyfrowania
    key= Random.new().read(KEY_SIZE)
    
    # szyfrowanie klucza szyfrownia algorytmem RSA
    klucz_mf= RSA.importKey(open('klucz_mf.pem', 'r').read())
    rsa_cipher= PKCS1_v1_5.new(klucz_mf)
    jpk['key']= base64.b64encode(rsa_cipher.encrypt(key))
         
    # sha256 dla pliku jpk
    xml_hash= SHA256.new()
    xml_hash.update(jpk_xml)
    jpk['xml_hash']= base64.b64encode(xml_hash.digest())
 
    # Utworzenie archiwum zip z plikiem jpk
    zipio= StringIO.StringIO()
    with zipfile.ZipFile(zipio, mode='w', compression= zipfile.ZIP_DEFLATED) as zf:
        zf.writestr(jpk_nazwa, jpk_xml)
    jpk_zip= zipio.getvalue()
     
    # szyfrowanie pliku
    iv= Random.new().read(16)
    jpk['iv']= base64.b64encode(iv)
    
    obj= AES.new(key, AES.MODE_CBC, iv)
    jpk_aes= obj.encrypt(padding(jpk_zip))
     
    # md5 zaszyfrowanego archiwum zip
    md5= MD5.new()
    md5.update(jpk_aes)
     
    jpk['zip_nazwa']= jpk_nazwa.replace('.xml','.zip')
    jpk['zip_len']= len(jpk_zip)
    jpk['zip_hash']= base64.b64encode(md5.digest())
 
    # Zapisanie zaszyfrowanego pliku zip (to będzie wysyłane w kroku upload)
    with open(jpk['zip_nazwa']+'.aes', 'wb') as f:
        f.write(jpk_aes)
 
    initupload_xml= open('initupload.tpl', 'rb')
    templ= string.Template( initupload_xml.read() )
    initupload_xml= templ.substitute(jpk)
    
    # Zapisanie pliku initupload.xml
    with open(jpk_nazwa[:-4]+'-initupload.xml', 'wb') as f:
        f.write(initupload_xml)

 
def upload(jpk_xades):
     
    initupload_xml= open(jpk_xades, 'rb').read()
    jpk_nazwa= jpk_xades.split('-initupload.')[0]
     
    print 'Wysylanie %s...'%jpk_xades
    headers= {'Content-Type': 'application/xml'}
    resp= requests.post(MF_URL+'/InitUploadSigned', data= initupload_xml, headers= headers, verify= False)
    if resp.status_code != 200:
        print 'InitUploadSigned', resp.status_code, repr(resp.text)
        return
     
    resj= json.loads(resp.text)
    reference= resj.get(u'ReferenceNumber')
    print 'Reference', reference
     
    # Zapisanie pliku initupload.xml w katalogu tymczasowym
    with open(jpk_nazwa+'.ref', 'wb') as f:
        f.write(reference)
     
    blobs= []
    for upload_req in resj.get(u'RequestToUploadFileList'):
        blob_name= upload_req.get(u'BlobName')
        blobs.append(blob_name)
        url= upload_req.get(u'Url')
        aes_name= upload_req.get(u'FileName')+'.aes'
         
        headers= {}
        for header in upload_req.get(u'HeaderList'):
            headers[header.get(u'Key')]= header.get(u'Value')
         
        print 'Wysylanie %s...'%aes_name
        jpk_aes= open(aes_name, 'rb').read()
        resp= requests.put(url, data= jpk_aes, headers=headers, verify= False)
        if resp.status_code != 201:
            print 'PUT', resp.status_code, repr(resp.text)
            return
 
    # FinishUpload
    data= {'ReferenceNumber': reference, 'AzureBlobNameList': blobs}
    headers= {'Content-Type': 'application/json'}
    resp= requests.post(MF_URL+'/FinishUpload', data= json.dumps(data), headers= headers, verify= False)
    if resp.status_code != 200:
        print 'FinishUpload', resp.status_code, repr(resp.text)
            
    return reference
     
     
def upload_status(ref= None, jpk_nazwa= None):
    if ref is None:
        ref= open(re.sub('.xml$', '', jpk_nazwa.split('-initupload.')[0])+'.ref').read()
    resp= requests.get('%s/Status/%s'%(MF_URL, ref), verify= False)
    print 'Status', resp.status_code, repr(resp.text)

 
def main(argv):
    if argv[1] == 'init': init_upload(argv[2])
    if argv[1] == 'upload': upload(argv[2])
    if argv[1] == 'status': upload_status(jpk_nazwa= argv[2])
        
if __name__ == "__main__":
    main(sys.argv)
