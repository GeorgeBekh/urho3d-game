class TargetedCamera : ScriptObject
{
    Node@ target;
    Vector3 initialPosition;
    Vector3 targetInitialPosition;

    void DelayedStart()
    {
        Init();
        SubscribeToEvents();
    }

    void Init()
    {
        initialPosition = node.position;
        targetInitialPosition = target.position;
    }

    void SubscribeToEvents()
    {
        SubscribeToEvent("PostUpdate", "HandlePostUpdate");
    }

    void HandlePostUpdate()
    {
        node.position = initialPosition + (target.position - targetInitialPosition);
    }
}
