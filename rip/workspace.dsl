workspace "RIP" "Rechtsinformationsportal" {

    model {
        siteVisitor = person "Interessierter" "Besucher der Webseite"
        
        ris = softwareSystem "RIS" "Rechtsinformationssystem" "Existing System"
        apiClient = softwareSystem "API Client" "" "Existing System"

        rip = softwareSystem "RIP" "Rechtsinformationsportal" {
            backend = container "Backend" "Stellt Funktionalität via JSON/XML/HTTPS API bereit und rendert HTML." "Java, Spring MVC"
            webserver = container "Webserver" "Nimmt Anfragen entgegen, liefert statischen Content aus" "Nginx"
            database = container "Datenbank" "Datenhaltung für alle Arten von Rechtsinformationen" "PostgreSQL" "Database"
            portal = container "Portal" "" "HTML, CSS, JavaScript" "Web Browser"
        }

        # Relationships between people and software systems
        siteVisitor -> rip "Besucht"
        apiClient -> rip "Sendet Anfragen"
        
        # Relationships to/from containers
        siteVisitor -> portal "Besucht rechtsinformationsportal.de" "HTTPS"
        apiClient -> webserver "Sendet Anfragen" "HTTPS"
        portal -> webserver "Fragt Seite an"
        webserver -> portal "Liefert Seite aus"
        webserver -> backend "Leitet Anfragen weiter"
        backend -> webserver "Beantwortet Anfragen"
        backend -> ris "Importiert kontinuierlich Daten"
        backend -> database "Liest von und schreibt nach" "JDBC"
    }

    views {
        systemContext rip "SystemContext" "Rechtsinformationsportal" {
            include *
            autoLayout
        }

        container rip "Containers" {
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
        }
    }
}