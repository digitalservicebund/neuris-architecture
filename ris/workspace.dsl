workspace "VeRIKA" "Verwirklichung Rechtsinformationssystem" {

    model {
        user = person "Dokumentar" "Nutzer der Fachanwendung"
        
        rip = softwareSystem "RIP" "Datenverwerter" "Existing System"
        bverfg = softwareSystem "BVerfG" "Datenlieferant" "Existing System"
        juris = softwareSystem "juris" "Datenverwerter" "Existing System"
        email = softwareSystem "Email" "Funktionspostfach" "Existing System"
        ftp = softwareSystem "FTP Server" "Speicherort für Push-Dienst" "Existing System"

        ris = softwareSystem "RIS" "Dokumentationsumgebung Datenhaltung" {
            singlePageApplication = container "Single-Page-Webanwendung" "Webapplikation Dokumentationsumgebung" "TypeScript, React" "Web Browser"
            backend = container "Backend/API" "Stellt Funktionalität via JSON/XML/HTTPS API bereit." "Java, Spring MVC"
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
        backend -> documentMessageQueue "Liest von" "AMQP"
        backend -> jobMessageQueue "Schreibt nach" "AMQP"
        backend -> rip "Stellt Daten bereit für"
        backend -> juris "Stellt Daten bereit für"
        backend -> database "Liest von und schreibt nach" "JDBC"
        bverfg -> backend "Stellt Daten bereit für"

        # Relationships to/from components
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

        component antiCorruptionLayer "Components" {
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