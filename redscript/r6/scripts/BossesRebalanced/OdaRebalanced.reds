


@addField(OdaEmergencyListener)
private let m_odaComponent: ref<OdaComponent>;

@addMethod(OdaEmergencyListener)
public func SetOdaComponent(odaComponent: ref<OdaComponent>) -> Void {
  this.m_odaComponent = odaComponent;
}

@replaceMethod(OdaEmergencyListener)
public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
  this.CheckCustomPhase(oldValue, newValue, percToPoints);
}

@addMethod(OdaEmergencyListener)
public final func CheckCustomPhase(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
  if oldValue > 5.00 && newValue <= 5.00 {
    if !this.m_odaComponent.m_isCustomPhase1 {
      this.m_odaComponent.TriggerCustomPhase1();
      this.SetRoamingBehaviorAuthorization();
      return;
    };

    if !this.m_odaComponent.m_isCustomPhase2 {
      this.m_odaComponent.TriggerCustomPhase2();
      this.SetRoamingBehaviorAuthorization();
    };
  };
}

@addField(OdaComponent)
public let m_isCustomPhase1: Bool = false;

@addField(OdaComponent)
public let m_isCustomPhase2: Bool = false;

@replaceMethod(OdaComponent)
private final func OnGameAttach() -> Void {
  this.m_owner = this.GetOwner() as NPCPuppet;
  this.m_owner_id = this.m_owner.GetEntityID();
  this.m_odaAIComponent = this.m_owner.GetAIControllerComponent();
  this.m_actionBlackBoard = this.m_odaAIComponent.GetActionBlackboard();
  this.m_statPoolSystem = GameInstance.GetStatPoolsSystem(this.m_owner.GetGame());
  this.m_healthListener = new OdaEmergencyListener();
  this.m_healthListener.SetOdaComponent(this);
  this.m_healthListener.SetValue(70.00);
  this.m_healthListener.m_owner = this.m_owner;
  this.m_statPoolSystem.RequestRegisteringListener(Cast<StatsObjectID>(this.m_owner_id), gamedataStatPoolType.Health, this.m_healthListener);
  StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"Oda.Masked", this.m_owner_id);
  this.m_targetTrackerComponent = this.m_owner.GetTargetTrackerComponent();

  this.m_owner.MarkDisallowedDeath();
}

@addMethod(OdaComponent)
public final func TriggerCustomPhase1() {
  this.m_isCustomPhase1 = true;
  this.ResetHealthBar();
  this.m_owner.ScheduleAppearanceChange(n"oda_oda_mask_damage");
}

@addMethod(OdaComponent)
public final func TriggerCustomPhase2() {
  this.m_isCustomPhase2 = true;
  this.ResetHealthBar();
  this.m_owner.MarkAllowedDeath();
  SetFactValue(this.m_owner.GetGame(), n"q112_oda_mask_destroyed", 1);
}

@wrapMethod(OdaComponent)
protected cb func OnStatusEffectApplied(evt: ref<ApplyStatusEffectEvent>) -> Bool {
  wrappedMethod(evt);

  if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"Oda.OdaMantisPhase") {
    LogChannel(n"DEBUG", "Checking if on a new status applied if mantis is enabled");
    if !StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"BaseStatusEffect.CloakedOda") {
      LogChannel(n"DEBUG", "Now if mantis is enabled, ADD CLOAKED ALSO");
      StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"BaseStatusEffect.CloakedOda", this.m_owner.GetEntityID());
    };
  };

  if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"Oda.OdaSMGPhase") {
    LogChannel(n"DEBUG", "Checking if on a new status applied if smg is enabled");
    if StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"BaseStatusEffect.CloakedOda") {
      LogChannel(n"DEBUG", "Now if smg is enabled, DISABLE CLOAKED");
      StatusEffectHelper.RemoveStatusEffect(this.m_owner, t"BaseStatusEffect.CloakedOda");
    };
  };
}

@addMethod(OdaComponent)
private final func ResetHealthBar(opt recoverAmount: Float) -> Void {
  if (recoverAmount == 0.00) {
    recoverAmount = 100.00;
  };

  this.m_statPoolSystem = GameInstance.GetStatPoolsSystem(this.m_owner.GetGame());
  this.m_statPoolSystem.RequestChangingStatPoolValue(Cast<StatsObjectID>(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, recoverAmount, this.m_owner, true);
}
