--created & coded by Lyris, art by The-SixthLeafClover of DeviantArt
--機光襲雷竜－ホウロウ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x7c4),2,2,function(g) return g:GetClassCount(Card.GetLinkAttribute)==#g end)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.dop)
	c:RegisterEffect(e2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)
	local e3=e1:Clone()
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	c:RegisterEffect(e3)
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCode(EVENT_ATTACK_ANNOUNCE)
	e0:SetCondition(s.descon)
	e0:SetTarget(s.destg)
	e0:SetOperation(s.desop)
	c:RegisterEffect(e0)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return Duel.GetTurnPlayer()~=tp and c:IsFaceup() and Duel.GetAttackTarget()==c
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.NegateAttack()
	if c:IsRelateToEffect(e) and c:IsDestructable() then
		Duel.BreakEffect()
		Duel.Destroy(c,REASON_EFFECT)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_ONFIELD) then
		Duel.Hint(HINT_CARD,0,id)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
function s.filter2(c,e)
	return c:IsFaceup() and c:IsSetCard(0x7c4) and not c:IsImmuneToEffect(e)
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,e:GetHandler(),e)
	for tc in aux.Next(sg) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(function(e,te) return not (te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):IsContains(e:GetHandler())) and te:GetOwnerPlayer()~=e:GetOwnerPlayer() end)
		tc:RegisterEffect(e1)
	end
end
function s.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if c:GetPreviousControler()~=tp then seq=seq+16 end
	return c:IsPreviousPosition(POS_FACEUP) and c:IsSetCard(0x7c4)
	and c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
