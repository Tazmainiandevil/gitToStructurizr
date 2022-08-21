workspace {

    model {
        user = person "User"
        softwareSystem = softwareSystem "Other Software System" {
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
                background #c8c8c8
                color #000000
            }
            element "Person" {
                shape person
                background #0000ff
                color #ffffff
            }
        }
    }
}
