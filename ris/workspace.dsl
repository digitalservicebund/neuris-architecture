workspace "VeRIKA" "Verwirklichung Rechtsinformationssystem" {

    model {
        user = person "Dokumentar" "Nutzer der Fachanwendung"
        
        rip = softwareSystem "RIP" "Datenverwerter" "Existing System"
        bverfg = softwareSystem "BVerfG" "Datenlieferant" "Existing System"
        juris = softwareSystem "juris" "Datenverwerter" "Existing System"
        email = softwareSystem "Email" "Funktionspostfach" "Existing System"
        ftp = softwareSystem "FTP Server" "Speicherort für Push-Dienst" "Existing System"
        consumer = softwareSystem "Datenverwerter" "Allgemeine Schnittstelle (DES)" "Existing System"

        ris = softwareSystem "RIS" "Dokumentationsumgebung Datenhaltung" {
            singlePageApplication = container "Single-Page-Webanwendung" "Webapplikation Dokumentationsumgebung" "TypeScript, React" "Web Browser"
            backend = container "Backend/API" "Stellt Funktionalität via JSON/XML/HTTPS API bereit." "Java, Spring MVC" {
                documentSubscriber = component "Dokeinheiten-Subscriber" "Empfängt Dokeinheiten von Queue" "Spring Bean"
                documentRepository = component "Dokeinheiten Repository" "Hält Dokeinheiten aus Datenhaltung vor" "Spring Bean"
                apiConfigRepository = component "Schnittstellenkonfiguration" "Hält Exportprofile aus Konfiguration vor" "Spring Bean"
                apiController = component "API Controller" "Stellt Schnittstellen als Webservice bereit" "Spring Bean"
                downloadController = component "Downloads Controller" "Stellt Daten als Download bereit" "Spring Bean"
                securityComponent = component "Security Komponente" "Authentifizierung aller Anfragen mittels JWT" "Spring Bean"
                exportComponent = component "Exporter Komponente" "Bewerkstelligt Datenexport gemäss Schnittstellenkonfiguration (Filter)" "Spring Bean"
                dslInterpreter = component "DSL Interpreter" "Übersetzt Abfrage-DSL in tatsächliche Abfrage" "Spring Bean"
                xmlRenderer = component "XML Renderer" "Wandelt Dokeinheit in XML (DES) Repräsentation um" "Spring Bean"
                csvRenderer = component "CSV Renderer" "Wandelt Dokeinheit in CSV Repräsentation um" "Spring Bean"
                legalDocMlRenderer = component "LegalDocML Renderer" "Wandelt Dokeinheit in LegalDocML.de Repräsentation um" "Spring Bean"
                pdfRenderer = component "PDF Renderer" "Wandelt Dokeinheit in PDF Repräsentation um" "Spring Bean"
                wordDocRenderer = component "Word Renderer" "Wandelt Dokeinheit in Word Repräsentation um" "Spring Bean"
                protocolService = component "Protokoll-Komponente" "Erstellt und speichert Protokolle für Datenexport" "Spring Bean"
            }
            antiCorruptionLayer = container "Importer" "Import von Fremddaten und Übersetzung in Dokumentationseinheiten (Anti-Corruption Layer)" "Java, Spring MVC" {
                emailComponent = component "E-mail Komponente" "Liest Emails aus Funktionspostfach" "Spring Bean"
                ftpComponent = component "FTP Komponente" "Lädt Daten von FTP Speicherort" "Spring Bean"
                webCrawlerComponent = component "Webcrawler Komponente" "Extrahiert Daten von Webseiten" "Spring Bean"
                webServiceComponent = component "Webservice Komponente" "Funktionalität für die Abfrage von Webservices (REST, SPARQL)" "Package"
                webClient = component "Webclient" "Generischer HTTP-Client" "Spring Bean"
                sparqlClient = component "SPARQL Client" "Generischer SPARQL-Client" "Spring Bean"
                rssReaderComponent = component "RSS Komponente" "Empfängt Aktualisierungen von RSS-Diensten zur weiteren Verarbeitung" "Spring Bean"
                documentPublisher = component "Dokeinheit-Publisher" "Schreibt vereinheitlichte Dokeinheiten-Daten in Queue" "Spring Bean"
                jobSubscriber = component "Job-Subscriber" "Empfängt Importaufträge von Queue" "Spring Bean"
                jobManager = component "Jobverwaltung" "Delegation hereinkommender Importaufträge" "Spring Bean"
                scheduler = component "Scheduler" "Erzeugt periodisch Jobs" "Spring Bean"
                documentConverter = component "Dokumentenkonverter" "Konvertiert eingehende Datensätze in Dokumentationseinheiten" "Spring Bean"
                converterSchemaRepository = component "Konvertierungsschemata Repository" "Stellt Konvertierungsschemata aus Konfigurationsdatenbank bereit" "Spring Bean"
                rulesRepository = component "Verarbeitungsregelwerke Repository" "Stellt Verarbeitungsregelwerke aus Konfigurationsdatenbank bereit" "Spring Bean"
            }
            documentMessageQueue = container "Dokeinheiten Queue" "Vorhaltung von eingehenden Dokumentationseinheiten für asynchrone Verarbeitung" "RabbitMQ" "Message Queue"
            jobMessageQueue = container "Job Queue" "Vorhaltung von Datenübernahmejobs für asynchrone Verarbeitung" "RabbitMQ" "Message Queue"
            iam = container "IAM" "Single-Sign On mittels OAuth2 + JWT" "Java, Keycloak"
            database = container "Datenbank" "Datenhaltung für Dokumentationseinheiten" "PostgreSQL" "Database"
            configuration = container "Konfiguration" "Speichert Schnittstellenkonfigurationen (Verarbeitungsregeln, Konvertierungsschemata)" "PostgreSQL" "Database"
        }

        # Relationships between people and software systems
        user -> ris "Arbeitet in"

        # Relationships to/from containers
        user -> iam "Loggt sich ein" "HTTPS"
        user -> singlePageApplication "Sieht Aufgabenliste in" "HTTPS"
        singlePageApplication -> backend "Ruft API auf" "JSON/HTTPS"
        backend -> singlePageApplication "Liefert an Browser des Nutzers aus" "HTTPS"
        backend -> jobMessageQueue "Schreibt nach" "AMQP"
        backend -> rip "Stellt Daten bereit für"
        backend -> juris "Stellt Daten bereit für"
        bverfg -> backend "Stellt Daten bereit für"

        # Relationships to/from components
        # Backend
        documentRepository -> database "Liest von und schreibt nach" "JDBC"
        apiConfigRepository -> database "Liest von" "JDBC"
        documentSubscriber -> documentMessageQueue "Liest von" "AMQP"
        documentSubscriber -> documentRepository "Verwendet"
        apiController -> exportComponent "Verwendet"
        apiController -> xmlRenderer "Verwendet"
        apiController -> securityComponent "Verwendet"
        apiController -> consumer "Stellt Daten bereit für"
        downloadController -> exportComponent "Verwendet"
        downloadController -> xmlRenderer "Verwendet"
        downloadController -> csvRenderer "Verwendet"
        downloadController -> legalDocMlRenderer "Verwendet"
        downloadController -> pdfRenderer "Verwendet"
        downloadController -> wordDocRenderer "Verwendet"
        downloadController -> securityComponent "Verwendet"
        exportComponent -> documentRepository "Verwendet"
        exportComponent -> apiConfigRepository "Verwendet"
        exportComponent -> dslInterpreter "Verwendet"
        exportComponent -> protocolService "Verwendet"
        protocolService -> database "Schreibt nach"
        user -> downloadController "Fragt manuellen Export an"
        # Importer
        jobSubscriber -> jobMessageQueue "Liest von" "AMQP"
        jobSubscriber -> jobManager "Verwendet"
        jobManager -> emailComponent "Verwendet"
        jobManager -> ftpComponent "Verwendet"
        jobManager -> webCrawlerComponent "Verwendet"
        jobManager -> webServiceComponent "Verwendet"
        jobManager -> rssReaderComponent "Verwendet"
        jobManager -> documentConverter "Verwendet"
        jobManager -> converterSchemaRepository "Verwendet"
        jobManager -> rulesRepository "Verwendet"
        scheduler -> jobMessageQueue "Schreibt nach"
        emailComponent -> email "Liest von" "IMAP"
        ftpComponent -> ftp "Liest von" "FTPS"
        webCrawlerComponent -> webClient "Verwendet"
        webServiceComponent -> webClient "Verwendet"
        webServiceComponent -> sparqlClient "Verwendet"
        converterSchemaRepository -> configuration "Liest von"
        rulesRepository -> configuration "Liest von"
        documentPublisher -> documentMessageQueue "Schreibt nach" "AMQP"
        documentConverter -> documentPublisher "Verwendet"
    }

    views {
        systemContext ris "SystemContext" "Rechtsinformationssystem" {
            include *
            exclude ftp
            exclude email
            autoLayout
        }

        container ris "Containers" {
            include *
        }

        component antiCorruptionLayer "AclComponents" {
            include *
        }

        component backend "BackendComponents" {
            include *
        }

        styles {
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
            element "Existing System" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
            element "Web Browser" {
                shape WebBrowser
            }
            element "Database" {
                shape Cylinder
            }
            element "Message Queue" {
                shape Pipe
            }
            element "Component" {
                shape Component
                background #85bbf0
                color #000000
            }
        }
    }
    
}
