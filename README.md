# Przygotowanie i wysyłka plików JPK

Skrypt w pythonie (2.7) do przygotowania i wysyłki plików JPK.
Wymgane są w używanym środowisku pythona następujące zależności:

* pycropto
* requests
* urllib3[secure]

(instalacja przy pomocy pip).

Wysyłka gotowego pliku JPK składa się z następujących etapów

1. Przygotowanie danych uwierzytelniających - pliku XML dla operacji InitUpload
2. Podpisanie pliku uwierzytelniającego podpisem kwalifikowanym
3. Wysłanie plików
4. Sprawdzenie statusu / pobranie UPO

Skrypt wjpk.py realizuje, kroki 1, 3, 4.
Podpis przygotowanego w kroku 1 pliku xml trzeba wykonać przy pomocy odpowiedniego programu
do obsługi podpisu kwalifikowanego.

W przykładach zakładamy, że mamy do wysłania plik jpk1.xml

W katalogu z którego wysyłamy plik muszą się znajdować wszystkie pliki z projektu, tzn.

* initupload.tpl - szablon pliku inicjalizującego sesje
* klucz_mf.pem - klucz publiczny MF do zaszyfrowanie klucza szyfrującego plik JPK

Klucz ten został wydzielony z dostarczonego przez MF certyfikatu
> openssl x509 -inform pem -in cert_mf.pem -pubkey -noout > klucz_mf.pem

## 1. Przygotowanie danych uwierzytelniających - pliku XML dla operacji InitUpload

> $ python wjpk.py init jpk1.xml

W pierwszym kroku plik do wysłania jest szyfrowany wygenerowanym losowym kluczem i tworzony jest
plik uwierzytelniający do podpisania podpisem kwalifikowanym.

Krok init tworzy następujące pliki 

* jpk1-initupload.xml - plik uwierzytelniający, który należy podpisać
* jpk1.zip - archiwum z plikiem JPK (testowo)
* jpk1.zip.aes - zaszyfrowane archiwum zip do wysłania w kroku 3

## 2. Podpisanie pliku uwierzytelniającego podpisem kwalifikowanym

Utworzony plik uwierzytelniający (np. jpk1-initupload.xml) należy podpisać podpisem kwalifikowanym.
Podpisany plik naleźy wgrać do katalogu. Dalej zakładamy, że plik ten ma dodatkowe rozszerzenie
.xades (np. jpk1-initupload.xml.xades) ale nazwa moźe być inna w zależności od użytego do podpisu pliku.

## 3. Wysłanie plików

> $ python wjpk.py upload jpk1-initupload.xml.xades

W następnym kroku wysyłamy zaszyfrowane pliki przy pomocy komendy **upload**.
Jako argument podajemy nazwę podpisanego pliku uwierzytelniającego.

W kroku tym najpierw wysyłany jest plik uwierzytelniający i jeżeli wszystko z nim będzie w porządku to 
następnie wysyłany jest spakowany i zaszyfrowany plik JPK (utworzony w pierwszym kroku plik z rozszerzeniem .aes).

Jeżeli wysłanie się powiedzie to sprawdzany jest również status ale przeważnie plik nie będzie od razu przetworzony.
Aby moźna w następnym kroku sprawdzać status wkrypt zapisuje do pliku z rozszereniem .ref numer referencyjny dla sesji
(np. jpk1.ref).

## 4. Sprawdzenie statusu / pobranie UPO

> $ python wjpk.py status jpk1

W ostatnim kroku sprawdzamy status wysyłki a jeżeli nie ma błędów to pobierane jest równiez UPO.
Bramka sprawdza jedynie syntaktyczną poprawność przesłanego pliku JPK tzn. zgodność z odpowiednim schematem XSD.
Nie są wykonywane żadne dodatkowe sprawdzenia (np. sum kontrolnych w pliku).
