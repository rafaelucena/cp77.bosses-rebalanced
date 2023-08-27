//v1.61.1.0
public class SasquatchHealthChangeListener extends CustomValueStatPoolsListener {

  public let m_owner: wref<NPCPuppet>;

  public let m_player: wref<PlayerPuppet>;

  public let m_sasquatchComponent: wref<SasquatchComponent>;

  private let m_statPoolType: gamedataStatPoolType;

  private let m_statPoolSystem: ref<StatPoolsSystem>;

  public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    this.CheckPhase(oldValue, newValue, percToPoints);
  }

  public final func CheckPhase(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
    if oldValue > 5.00 && newValue <= 5.00 {
      if !this.m_sasquatchComponent.m_isCustomPhase1 {
        this.m_sasquatchComponent.TriggerCustomPhase1();
      };
    };
  }
}

@addField(SasquatchComponent)
private let m_statPoolSystem: ref<StatPoolsSystem>;

@addField(SasquatchComponent)
private let m_statPoolType: gamedataStatPoolType;

@addField(SasquatchComponent)
private let m_healthListener: ref<SasquatchHealthChangeListener>;

@addField(SasquatchComponent)
public let m_isCustomPhase1: Bool = false;

@replaceMethod(SasquatchComponent)
public final func OnGameAttach() -> Void {
  this.m_owner = this.GetOwner() as NPCPuppet;
  this.m_owner_id = this.m_owner.GetEntityID();
  this.m_statPoolSystem = GameInstance.GetStatPoolsSystem(this.m_owner.GetGame());
  this.m_healthListener = new SasquatchHealthChangeListener();
  this.m_healthListener.m_owner = this.m_owner;
  this.m_healthListener.m_player = this.GetPlayerSystem().GetLocalPlayerControlledGameObject() as PlayerPuppet;
  this.m_healthListener.m_sasquatchComponent = this;
  this.m_statPoolSystem.RequestRegisteringListener(Cast<StatsObjectID>(this.m_owner_id), gamedataStatPoolType.Health, this.m_healthListener);
  this.m_owner.MarkDisallowedDeath();
}

@addMethod(SasquatchComponent)
public final func OnGameDetach() -> Void {
  this.m_statPoolSystem.RequestUnregisteringListener(Cast<StatsObjectID>(this.m_owner_id), gamedataStatPoolType.Health, this.m_healthListener);
  this.m_healthListener = null;
}

@addMethod(SasquatchComponent)
public final func TriggerCustomPhase1() {
  this.m_isCustomPhase1 = true;
  this.ResetHealthBar();
  this.m_owner.MarkAllowedDeath();
  StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"Sasquatch.Phase1", this.m_owner.GetEntityID());
  StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"BaseStatusEffect.PainInhibitors", this.m_owner.GetEntityID());
  StatusEffectHelper.ApplyStatusEffect(this.m_owner, t"Sasquatch.Healing", this.m_owner.GetEntityID());
}

@addMethod(SasquatchComponent)
private final func ResetHealthBar(opt recoverAmount: Float) -> Void {
  if (recoverAmount == 0.00) {
    recoverAmount = 100.00;
  };

  this.m_statPoolSystem = GameInstance.GetStatPoolsSystem(this.m_owner.GetGame());
  this.m_statPoolSystem.RequestChangingStatPoolValue(Cast<StatsObjectID>(this.m_owner.GetEntityID()), gamedataStatPoolType.Health, recoverAmount, this.m_owner, true);
}
