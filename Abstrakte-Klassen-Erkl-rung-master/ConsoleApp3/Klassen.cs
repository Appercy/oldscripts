// 





public class Person // erstellt eine Klasse namens "Person"
{ // Variablen müssen beim erstellen der Klasse angegeben werden!
    public string Name { get; set; } // erstellt eine Variable in Person namens Name
    public int Alter { get; set; } // erstellt eine Variable namens Alter 

    public void SayHello() // Die Funktion SayHello() Wird erstellt, mit VOID
        // Void = Er gibt nichts zurück, 
        // wenn du jetzt zb string dahinschreibst, dann musst du in der funktion etwas dahin zurückgeben wo die funktion ausgeführt wird (bei uns in der hierwirdallesinderkonsoleausgefuehrt.cs)
        // und der bekommt dann das sozusagen was du ihm gibst direkt, 
    {
        Console.WriteLine("Hallo, mein Name ist " + Name + " und ich bin " + Alter + " Jahre alt.");
    }

    // bsp für getnme
    internal string NameBekommen(string Name) {  // heir kann man auch public hinschreiben, das macht für uns keinen starken unterschied
        return Name; // Gibt Name Zurück
    }

    internal int AlterBekommen() 
    {
        return Alter; // Gibt Alter zurück 
    }

    internal string NameBekommen()
    {
       return Name;
    }

    public int AlterHinzufuegen(int Alterzumhinzufuegen)
    {
        return Alterzumhinzufuegen + Alter;

    }


}

