#java -jar apktool_2.3.4.jar empty-framework-dir
jarsigner -verbose -keystore cylee.keystore -signedjar new.apk old.apk cylee
