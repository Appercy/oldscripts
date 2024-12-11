



// was abstract (zeile 25) macht ist, das die Hauptklasse Fahrzeug NICHT Definiert werden kann, hier ist ein beispiel dafür:
   // Fahrzeug meinauto1 = new Fahrzeug(); 
// die Obere zeile Wird nicht ausgeführt Weil sonst das Programm nicht Startet! entkommentier diese zeile (die 2 // weg) und dann kannst du das selber sehen das dein IDE (dein Visual Studio) einen Fehler ausgibt weil Fahrzeug Abtract ist,





public abstract class Fahrzeug{ // Erstellt die Abstrakte Klasse Fahrzeug

public string Name { get; set; } // Erstellt eine Variable Name, welche in allen Unterklassen Verwendet wird


    public abstract void Drive(); // erstellt eine Drive() Funktion welche den namenausgibt (in den Unterklassen!)
}


public class Auto:Fahrzeug // unterKlasse Fahrzeug wird erstellt
{

    public override void Drive() // Drive Funktion wird Definiert
    {
        Console.WriteLine("Das Auto ist ein " + Name); // Name von Fahrzeug wird benutzt!
    }


}


public class Fahrrad:Fahrzeug // unterKlasse Fahrrad wird erstellt!
{
    public override void Drive() // Drive Funktion wird definiert!
    {
        Console.WriteLine("Das Fahrrad ist ein " + Name + " "); // Name von Fahrzeug wird Benutzt!
    }

}





