// This first example, maintaining tradition, prints a "Hello World" message.
// Furthermore it shows:
//     - Using the Sample utility functions as a base for the application
//     - Adding a Text element to the graphical user interface
//     - Subscribing to and handling of update events

#include "Scripts/Utilities/Sample.as"

void Start()
{
    SampleStart();

    LoadScene();

    SubscribeToEvents();
}

void LoadScene()
{
    scene_ = Scene();
    File loadFile(fileSystem.programDir + "main.xml", FILE_READ);
    scene_.LoadXML(loadFile);

    cameraNode = scene_.GetChild("PlayingPlane").GetChild("Player").GetChild("MainCamera");
    Camera@ camera = cameraNode.GetComponent("Camera");
    renderer.viewports[0] = Viewport(scene_, camera);
}

void SubscribeToEvents()
{
    // Subscribe HandleUpdate() function for processing update events
   // SubscribeToEvent("Update", "HandleUpdate");
}

// Create XML patch instructions for screen joystick layout specific to this sample app
String patchInstructions =
        "<patch>" +
        "    <add sel=\"/element/element[./attribute[@name='Name' and @value='Hat0']]\">" +
        "        <attribute name=\"Is Visible\" value=\"false\" />" +
        "    </add>" +
        "</patch>";
