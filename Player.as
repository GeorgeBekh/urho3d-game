const int CTRL_JUMP = 1;
const int CTRL_LEFT = 2;
const int CTRL_RIGHT = 4;
const int CTRL_INTERACT = 8;

const float BRAKE_FORCE = 0.14;

const int JUMP_FORCE = 5;
const float COOLDOWN_JUMP = 0.25f;
const float COOLDOWN_INTERACT = 0.25f;

class Player : ScriptObject
{
    RigidBody@ body;
    Node@ grabPoint;
    PhysicsWorld@ physicsWorld;

    Controls controls;
    bool onGround = false;
    Vector3 lookDirecrtion;

    float jumpCooldown = 0.0f;
    float interactCooldown = 0.0f;

    void DelayedStart()
    {
        Init();
        SubscribeToEvents();
    }

    void Init()
    {
        body = node.GetComponent("RigidBody");
        physicsWorld = node.scene.GetComponent("PhysicsWorld");
        grabPoint = node.GetChild("GrabPoint");
    }

    void SubscribeToEvents()
    {
        SubscribeToEvent("Update", "HandleUpdate");
    }

    void HandleUpdate()
    {
        physicsWorld.DrawDebugGeometry(true);
        controls.Set(CTRL_JUMP | CTRL_LEFT | CTRL_RIGHT , false);
        controls.Set(CTRL_JUMP, input.keyDown[KEY_UP] || input.keyDown[KEY_W]);
        controls.Set(CTRL_LEFT, input.keyDown[KEY_LEFT] || input.keyDown[KEY_A]);
        controls.Set(CTRL_RIGHT, input.keyDown[KEY_RIGHT] || input.keyDown[KEY_D]);
        controls.Set(CTRL_INTERACT, input.keyDown[KEY_E]);
    }

    void FixedUpdate(float timeStep)
    {
        Move();
        Jump();
        Interact();

        RefreshCooldowns(timeStep);
    }

    void Move()
    {
        Vector3 moveDir = Vector3::ZERO;

        if (controls.IsDown(CTRL_LEFT)) {
            moveDir = Vector3::LEFT;
        }
        if (controls.IsDown(CTRL_RIGHT)) {
            moveDir = Vector3::RIGHT;
        }

        Vector3 velocity = body.linearVelocity;
        Vector3 planeVelocity(velocity.x, 0.0f, velocity.z);
        
        Vector3 brakeForce = -planeVelocity * BRAKE_FORCE;
        body.ApplyImpulse(moveDir + brakeForce);
        

        if (planeVelocity.length > 0.25f) {
            if (planeVelocity.x > 0) {
                //node.rotation = Quaternion(0.0f, 0.0f, -90.0f);
                lookDirecrtion = Vector3::RIGHT;
            } else {
                //node.rotation = Quaternion(0.0f, 0.0f, 90.0f);
                lookDirecrtion = Vector3::LEFT;
            }
        }
    }

    void Jump()
    {
        if (controls.IsDown(CTRL_JUMP) && jumpCooldown <= 0.0f && OnGround())
        {
            body.ApplyImpulse(Vector3::UP * JUMP_FORCE);
            jumpCooldown = COOLDOWN_JUMP;
        }
    }

    void Interact()
    {
        if (controls.IsDown(CTRL_INTERACT) && interactCooldown <= 0.0f) {
            Ray ray = Ray(node.position, lookDirecrtion);
            PhysicsRaycastResult result = physicsWorld.RaycastSingle(ray, 10.0f);
            if (result.body !is null) {
               //MakeTransparent(result.body.node);
               result.body.ApplyImpulse(grabPoint.worldPosition - result.body.node.worldPosition);
            }
        }
    }

    void RefreshCooldowns(float timeStep)
    {
        if (jumpCooldown > 0.0f) {
            jumpCooldown -= timeStep;
        }
        if (interactCooldown > 0.0f) {
            interactCooldown -= timeStep;
        }
    }

    void MakeTransparent(Node node)
    {
        StaticModel@ model = node.GetComponent("StaticModel");
        Variant oldShader = model.materials[0].shaderParameters["MatDiffColor"];
        Variant shader;
        Vector4 newColor = oldShader.GetVector4();
        newColor.w /= 2;
        shader.FromString(oldShader.type, newColor.ToString()); //GetBuffer().size);
        model.materials[0].shaderParameters["MatDiffColor"] = shader;
    }

    bool OnGround()
    {
        Ray ray = Ray(node.position, Vector3::DOWN);
        PhysicsRaycastResult result = physicsWorld.RaycastSingle(ray, 10.0f);

        if (result.body !is null && result.distance <= 0.52f) {
            return true;
        }

        return false;
    }
}
