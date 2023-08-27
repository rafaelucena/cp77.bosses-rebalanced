@addField(NPCPuppet)
public let m_isAllowedDeath: Bool = true;

@addMethod(NPCPuppet)
public final const func IsAllowedDeath() -> Bool {
  return this.m_isAllowedDeath;
}

@addMethod(NPCPuppet)
public final func MarkDisallowedDeath() -> Void {
  this.m_isAllowedDeath = false;
}

@addMethod(NPCPuppet)
public final func MarkAllowedDeath() -> Void {
  this.m_isAllowedDeath = true;
}

@replaceMethod(NPCPuppet)
private final func ProcessStatusEffectApplication(evt: ref<ApplyStatusEffectEvent>) -> Void {
  let newStatusEffectPrio: Float;
  let topPrioStatusEffectPrio: Float;
  let topProEffect: ref<StatusEffect>;
  super.OnStatusEffectApplied(evt);
  if (StatusEffectSystem.ObjectHasStatusEffectWithTag(this, n"Braindance") || StatusEffectSystem.ObjectHasStatusEffect(this, t"BaseStatusEffect.Drunk")) && NotEquals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.Defeated) {
    return;
  };
  if evt.staticData.AIData().ShouldProcessAIDataOnReapplication() && evt.staticData.GetID() == this.m_cachedStatusEffectAnim.GetID() {
    return;
  };
  if !evt.isNewApplication && !evt.staticData.AIData().ShouldProcessAIDataOnReapplication() {
    return;
  };
  if IsDefined(evt.staticData) && IsDefined(evt.staticData.AIData()) {
    newStatusEffectPrio = evt.staticData.AIData().Priority();
    topProEffect = StatusEffectHelper.GetTopPriorityEffect(this, evt.staticData.StatusEffectType().Type(), true);
    if IsDefined(topProEffect) {
      topPrioStatusEffectPrio = topProEffect.GetRecord().AIData().Priority();
    };
  };
  if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.Defeated) {
    if !(this.IsAllowedDeath()) {
      StatusEffectHelper.RemoveStatusEffect(this, t"BaseStatusEffect.Defeated");
      return;
    };

    if ScriptedPuppet.CanRagdoll(this) {
      this.QueueEvent(new UncontrolledMovementStartEvent());
    };
    this.TriggerDefeatedBehavior(evt);
  } else {
    if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.DefeatedWithRecover) {
      this.TriggerStatusEffectBehavior(evt, true);
    } else {
      if Equals(evt.staticData.StatusEffectType().Type(), gamedataStatusEffectType.UncontrolledMovement) {
        this.OnUncontrolledMovementStatusEffectAdded(evt);
      } else {
        if (newStatusEffectPrio > topPrioStatusEffectPrio || newStatusEffectPrio == topPrioStatusEffectPrio && !IsDefined(this.m_cachedStatusEffectAnim)) && StatusEffectHelper.CheckStatusEffectBehaviorPrereqs(this, evt.staticData) {
          if this.IsCrowd() && Equals(this.GetHighLevelStateFromBlackboard(), gamedataNPCHighLevelState.Fear) {
            return;
          };
          this.TriggerStatusEffectBehavior(evt);
        };
      };
    };
  };
  this.CacheStatusEffectAppliedByPlayer(evt);
}