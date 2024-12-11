Console.WriteLine("Bitte Wählen sie Ihr bevorzugtes beispiel");
Console.WriteLine("1: Wie Klassen Funktionieren, (Klassen.cs)");
Console.WriteLine("2: Wie Abstrake Klassen und Vererbungen Funktionieren, (Abstract.cs)");
Console.WriteLine("3. Virtual, was ist das?");

int zahl = 1;
while (true)
{
    Console.WriteLine("Geben Sie eine Zahl zwischen 1 und 3 ein:");
    string eingabe = Console.ReadLine();

    if (int.TryParse(eingabe, out zahl))
    {
        if (zahl >= 1 && zahl <= 3)
        {
            // Die Benutzereingabe ist eine gültige Zahl zwischen 1 und 3
            break; // Die Schleife wird beendet
        }
        else
        {
            Console.WriteLine("Ungültige Eingabe. Bitte geben Sie eine Zahl zwischen 1 und 3 ein.");
        }
    }
    else
    {
        Console.WriteLine("Ungültige Eingabe. Bitte geben Sie eine Zahl ein.");
    }
}



switch (zahl)
{
    case 1:
        // Klassen.cs

        Person // Person wird geladen.. (von Klassen .cs)
        person1 = new Person(); // person wird erstellt
        person1.Name = "Lukas"; // Person bekommt den namen Lukas
        person1.Alter = 23; // Person bekommt das Alter 23
        person1.SayHello(); // Funktion SayHello() wird ausgeführt



        Console.WriteLine("Hier wird jetzt gezeigt das die return funktionen  funktionieren");
        Console.WriteLine(" ");
        Console.WriteLine(" ");
        Console.WriteLine("Der Name ist " + person1.NameBekommen() + " -- Zur Verfügung gestellt von Person.NameBekommen");
        Console.WriteLine(" ");
        Console.WriteLine("Das Alter ist " + person1.AlterBekommen() + " -- Zur Verfügung gestellt von Alter.Alterbekommen()");
        Console.WriteLine(" ");
        Console.WriteLine("Das ganze geht auch aunderstrum..");
        int zahl2 = 1;
        while (true)
        {
            Console.WriteLine("Geben Sie eine Zahl ein:");
            string eingabe2 = Console.ReadLine();

            if (int.TryParse(eingabe2, out zahl2))
            {
                break; // Die Schleife wird beendet  
            };
        }

        Console.WriteLine(zahl2 + "Wird zu" + person1.AlterBekommen() +  " in der Klasse hinzugefügt mit der Funktion AlterHinzufuegen(zahl)");
        Console.WriteLine(" ");
        int neuesalter = person1.AlterHinzufuegen(zahl2);
        Console.WriteLine("Die Neue zahl ist " + neuesalter);
      
        break;

    
            case 2:
        // Abstrakt .cs

        Auto // Auto von Abstract.cs geladen

        auto1 = new Auto(); // eine Neue Klasse Wird erstellt --> Fahrzeug --> Auto
        auto1.Name = "BMW"; // in Fahrzeug wird der Name gesetzt
        auto1.Drive(); // Auto.Drive() wird ausgeführt


  
        Fahrrad // Fahrrad wird Unten geladen
            fahrrad1 = new Fahrrad(); // eine Neue Klasse wird erstellt --> Fahrzeug --> Fahrrad
        fahrrad1.Name = "BMX"; // Fahrrad bekommt den namen BMX (wird in Fahrzeug gemacht)
        fahrrad1.Drive();  // Fahrrad.Drive() wird ausgeführt!
        break;


    case 3:
      

        break;

};

