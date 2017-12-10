const int CTRL_JUMP = 1;
const int CTRL_LEFT = 2;
const int CTRL_RIGHT = 4;
const int JUMP_FORCE = 5;

const float BRAKE_FORCE = 0.14;
const float JUMP_COOLDOWN = 0.5f;

class Player : ScriptObject
{
    RigidBody@ body;
    Controls controls;
    float jumpCooldown = 0.0f;
    bool onGround = false;

    void Start()
    {
        Init();
        SubscribeToEvents();
    }

    void Init()
    {
        body = node.GetComponent("RigidBody");
    }

    void SubscribeToEvents()
    {
        SubscribeToEvent("Update", "HandleUpdate");
    }

    void HandleUpdate()
    {
        controls.Set(CTRL_JUMP | CTRL_LEFT | CTRL_RIGHT , false);
        controls.Set(CTRL_JUMP, input.keyDown[KEY_UP] || input.keyDown[KEY_W]);
        controls.Set(CTRL_LEFT, input.keyDown[KEY_LEFT] || input.keyDown[KEY_A]);
        controls.Set(CTRL_RIGHT, input.keyDown[KEY_RIGHT] || input.keyDown[KEY_D]);
    }

    void FixedUpdate(float timeStep)
    {
        Vector3 moveDir = Vector3::ZERO;

        if (controls.IsDown(CTRL_LEFT)) {
            moveDir = Vector3::LEFT;
        }
        if (controls.IsDown(CTRL_RIGHT)) {
            moveDir = Vector3::RIGHT;
        }

        if (controls.IsDown(CTRL_JUMP) && OnGround() && jumpCooldown <= 0.0f)
        {
            body.ApplyImpulse(Vector3::UP * JUMP_FORCE);
            jumpCooldown = JUMP_COOLDOWN;
        }

        if (jumpCooldown > 0.0f) {
            jumpCooldown -= timeStep;
        }

        Vector3 velocity = body.linearVelocity;
        Vector3 planeVelocity(velocity.x, 0.0f, velocity.z);
        
        Vector3 brakeForce = -planeVelocity * BRAKE_FORCE;
        body.ApplyImpulse(moveDir + brakeForce);
    }

    void HandleNodeCollision(StringHash eventType, VariantMap& eventData)
    {
        VectorBuffer contacts = eventData["Contacts"].GetBuffer();

        while (!contacts.eof)
        {
            Vector3 contactPosition = contacts.ReadVector3();
            Vector3 contactNormal = contacts.ReadVector3();
            float contactDistance = contacts.ReadFloat();
            float contactImpulse = contacts.ReadFloat();

            // If contact is below node center and pointing up, assume it's a ground contact
            if (contactPosition.y < (node.worldPosition.y + 1.0f))
            {
                float level = contactNormal.y;
                if (level > 0.75) 
                    onGround = true;
            }
        }
    }

    bool OnGround()
    {
        RigidBody@[]@ contacts = body.collidingBodies;

        return contacts.length > 0;
    }
}
