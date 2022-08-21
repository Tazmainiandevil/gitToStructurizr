workspace {

    model {
        user = person "User"
        softwareSystem = softwareSystem "Basic Software System" {
            webapp = container "Web Application"
            database = container "Database"
         }

        user -> webapp "Uses"
        webapp -> database "Reads from and writes to"
    }

    views {
        systemContext softwareSystem "SystemContext" {
            include *
            autoLayout
        }

        styles {
            element "Software System" {
                background #0000ff
                color #ffffff
            }
            element "Person" {
                shape person
                background #00ffff
                color #000000
            }
        }
    }
}
