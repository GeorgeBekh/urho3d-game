class Exit : ScriptObject
{
    void Start()
    {
        SubscribeToEvents();
    }

    void SubscribeToEvents()
    {
        SubscribeToEvent(node, "NodeCollision", "HandleNodeCollision");
    }

    void HandleNodeCollision(StringHash eventType, VariantMap& eventData)
    {
        engine.Exit();
    }
}
