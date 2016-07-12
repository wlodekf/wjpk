<?xml version="1.0" encoding="utf-8"?>
<InitUpload xmlns="http://e-dokumenty.mf.gov.pl">
    <DocumentType>JPK</DocumentType>
    <Version>01.02.01.20160617</Version>
    <EncryptionKey algorithm="RSA" mode="ECB" padding="PKCS#1" encoding="Base64">$key</EncryptionKey>
    <DocumentList>
        <Document>
            <FormCode systemCode="$kod (1)" schemaVersion="1-0">$kod</FormCode>
            <FileName>$xml_nazwa</FileName>
            <ContentLength>$xml_len</ContentLength>
            <HashValue algorithm="SHA-256" encoding="Base64">$xml_hash</HashValue>
            <FileSignatureList filesNumber="1">
                <Packaging>
                    <SplitZip type="split" mode="zip"/>
                </Packaging>
                <Encryption>
                    <AES size="256" block="16" mode="CBC" padding="PKCS#7">
                        <IV bytes="16" encoding="Base64">$iv</IV>
                    </AES>
                </Encryption>
                <FileSignature>
                    <OrdinalNumber>1</OrdinalNumber>
                    <FileName>$zip_nazwa</FileName>
                    <ContentLength>$zip_len</ContentLength>
                    <HashValue algorithm="MD5" encoding="Base64">$zip_hash</HashValue>
                </FileSignature>
            </FileSignatureList>
        </Document>
    </DocumentList>
</InitUpload>