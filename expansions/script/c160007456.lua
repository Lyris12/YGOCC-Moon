--Neon Data Connector
local cid,id=GetID()
function cid.initial_effect(c)
	 aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
	aux.AddEvoluteProc(c,nil,6,cid.filter1,1)  
	--Conjoint Procedure
	aux.AddOrigConjointType(c)
	aux.EnableConjointAttribute(c,6) 

	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(cid.value)
	e1:SetCondition(cid.effcon)
	e1:SetLabel(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_XMATERIAL)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(cid.value)
		e2:SetCondition(cid.effcon)
		e2:SetLabel(1)
		c:RegisterEffect(e2)
  --pierce
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	e4:SetValue(cid.value)
	e4:SetCondition(cid.effcon)
	e4:SetLabel(2)
	c:RegisterEffect(e4)
   local e42=Effect.CreateEffect(c)
		e42:SetType(EFFECT_TYPE_XMATERIAL)
		e42:SetCode(EFFECT_PIERCE)
		e42:SetValue(cid.value)
		e42:SetCondition(cid.effcon)
		e42:SetLabel(2)
		c:RegisterEffect(e42)
   --change target
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(cid.effcon2)
	e3:SetTarget(cid.target)
	e3:SetOperation(cid.operation)
	e3:SetLabel(3)
	c:RegisterEffect(e3)
	--change target
	local e34=Effect.CreateEffect(c)
		e34:SetDescription(aux.Stringid(id,0))
		e34:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e34:SetCode(EVENT_ATTACK_ANNOUNCE)
		e34:SetCondition(cid.effcon2)
		e34:SetCountLimit(1,id)
		e34:SetTarget(cid.target)
		e34:SetOperation(cid.operation)
		e34:SetLabel(3)
		c:RegisterEffect(e34)
   --skip draw
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCondition(cid.effcon3)
	e5:SetLabel(4)
	e5:SetOperation(cid.skipop)
	c:RegisterEffect(e5)
  --skip draw
	local e55=Effect.CreateEffect(c)
		e55:SetDescription(aux.Stringid(id,0))
		e55:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_TRIGGER_F)
		e55:SetCode(EVENT_BATTLE_DESTROYING)
		e55:SetCondition(cid.effcon3)
		e55:SetLabel(4)
		e55:SetOperation(cid.skipop)
		c:RegisterEffect(e55)
end
function cid.filter1(c,ec,tp)
	return c:IsRace(RACE_THUNDER) or c:IsAttribute(ATTRIBUTE_WIND)
end
function cid.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>=e:GetLabel() and e:GetHandler():GetEC()>=e:GetLabel() and e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
function cid.effcon2(e,tp,eg,ep,ev,re,r,rp)
	 return ep~=tp and e:GetHandler():GetOverlayCount()>=e:GetLabel() and e:GetHandler():GetEC()>=e:GetLabel() and e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
function cid.effcon3(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsSummonType(SUMMON_TYPE_SPECIAL) and bc:IsType(TYPE_MONSTER) and e:GetHandler():GetOverlayCount()>=e:GetLabel() and e:GetHandler():GetEC()>=e:GetLabel() and e:GetHandler():GetOverlayGroup():IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
function cid.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function cid.value(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_REMOVED,0)*100
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	local at=Duel.GetAttacker()
	Duel.SetTargetCard(at)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
		   local bc=Duel.GetAttackTarget()
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,bc)
		if g:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(36708764,0))
			local tc=g:Select(tp,1,1,nil):GetFirst()
			local at=Duel.GetAttacker()
			if at:IsAttackable() and not at:IsImmuneToEffect(e) and not tc:IsImmuneToEffect(e) then
				Duel.CalculateDamage(at,tc)
			end
		end
end
function cid.skipop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetReset(RESET_PHASE+PHASE_DRAW+RESET_OPPO_TURN)
	Duel.RegisterEffect(e1,tp)
end