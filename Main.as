// This first example, maintaining tradition, prints a "Hello World" message.
// Furthermore it shows:
//     - Using the Sample utility functions as a base for the application
//     - Adding a Text element to the graphical user interface
//     - Subscribing to and handling of update events

#include "Scripts/Utilities/Sample.as"

void Start()
{
    // Execute the common startup for samples
    SampleStart();

    // Create "Hello World" Text
    LoadScene();
    log.Error("TEST");
    // Set the mouse mode to use in the sample
    SampleInitMouseMode(MM_FREE);
    // Finally, hook-up this HelloWorld instance to handle update events
    SubscribeToEvents();
}

void LoadScene()
{
    scene_ = Scene();
    File loadFile(fileSystem.programDir + "main.xml", FILE_READ);
    scene_.LoadXML(loadFile);

    cameraNode = scene_.GetChild("MainCamera");
    Camera@ camera = cameraNode.GetComponent("Camera");
    renderer.viewports[0] = Viewport(scene_, camera);
}

void SubscribeToEvents()
{
    // Subscribe HandleUpdate() function for processing update events
    SubscribeToEvent("Update", "HandleUpdate");
}

void HandleUpdate(StringHash eventType, VariantMap& eventData)
{
    // Do nothing for now, could be extended to eg. animate the display
}
// Create XML patch instructions for screen joystick layout specific to this sample app
String patchInstructions =
        "<patch>" +
        "    <add sel=\"/element/element[./attribute[@name='Name' and @value='Hat0']]\">" +
        "        <attribute name=\"Is Visible\" value=\"false\" />" +
        "    </add>" +
        "</patch>";
