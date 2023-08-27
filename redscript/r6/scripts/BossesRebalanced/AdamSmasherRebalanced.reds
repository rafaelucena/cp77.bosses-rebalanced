

@addMethod(AdamSmasherHealthChangeListener)
public func SetAdamSmasherComponent(adamSmasherComponent: ref<AdamSmasherComponent>) -> Void {
  this.m_adamSmasherComponent = adamSmasherComponent;
}

@replaceMethod(AdamSmasherHealthChangeListener)
public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
  this.CheckCustomPhase(oldValue, newValue, percToPoints);
}

@addMethod(AdamSmasherHealthChangeListener)
public final func CheckCustomPhase(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
  if oldValue > 5.00 && newValue <= 5.00 {
    if !this.m_adamSmasherComponent.m_isCustomPhase1 {
      this.m_adamSmasherComponent.TriggerCustomPhase1();

      if !StatusEffectSystem.ObjectHasStatusEffect(this.m_owner, t"AdamSmasher.Destroyed_Plate") {
        this.ApplySmashed();
      };
      this.DisableFrontPlate();
      this.EnableTorsoWeakspot();

      return;
    };

    if !this.m_adamSmasherComponent.m_isCustomPhase2 {
      this.m_adamSmasherComponent.TriggerCustomPhase2();

      this.ApplyPhase2();
      this.DisableTorsoWeakspot();
      this.DisableRightArm();
      this.EnableLauncherWeakspot();

      return;
    };

    if !this.m_adamSmasherComponent.m_isCustomPhase3 {
      this.m_adamSmasherComponent.TriggerCustomPhase3();

      this.ApplyPhase3();
      this.DisableLauncherWeakspot();
      this.EnableHeadWeakspot();
    };
  };
}

@addField(AdamSmasherComponent)
public let m_isCustomPhase1: Bool = false;

@addField(AdamSmasherComponent)
public let m_isCustomPhase2: Bool = false;

@addField(AdamSmasherComponent)
public let m_isCustomPhase3: Bool = false;

@wrapMethod(AdamSmasherComponent)
public final func OnGameAttach() -> Void {
  wrappedMethod();
  this.m_healthListener.SetAdamSmasherComponent(this);
  this.m_owner.MarkDisallowedDeath();
}

@addMethod(AdamSmasherComponent)
public final func TriggerCustomPhase1() {
  this.m_isCustomPhase1 = true;
  this.ResetHealthBar();
}

@addMethod(AdamSmasherComponent)
public final func TriggerCustomPhase2() {
  this.m_isCustomPhase2 = true;
  this.ResetHealthBar();
}

@addMethod(AdamSmasherComponent)
public final func TriggerCustomPhase3() {
  this.m_isCustomPhase3 = true;
  this.m_owner.MarkAllowedDeath();
  this.ResetHealthBar(50.00);
}

@addMethod(AdamSmasherComponent)
private final func ResetHealthBar(opt recoverAmount: Float) -> Void {
  if (recoverAmount == 0.00) {
    recoverAmount = 100.00;
  };

  this.m_statPoolSystem = GameInstance.GetStatPoolsSystem(this.m_owner.GetGame());
  this.m_statPoolSystem.RequestChangingStatPoolValue(Cast<StatsObjectID>(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, recoverAmount, this.m_owner, true);
}
