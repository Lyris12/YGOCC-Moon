--created by Slick, coded by Lyris
--Kronologistic Fault Hunter
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:RegisterSetCardString"Kronologistic"
	aux.AddSynchroMixProcedure(c,nil,nil,nil,aux.NonTuner(nil),1,99,s.mchk)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCondition(s.decon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(s.imval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetTarget(s.zetg)
	e3:SetOperation(s.zeop)
	c:RegisterEffect(e3)
end
function s.mchk(g)
	return g:IsExists(Card.IsType,1,nil,TYPE_DRIVE)
end
function s.descon(e)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local ct=#Duel.GetEngagedCards()
	if ct>0 and ct<=#g then Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0) end
	Duel.SetChainLimit(s.chlim)
end
function s.chlim(e)
	return not DRIVE_EFFECTS_TABLE[e]
end
function s.desop(e,tp)
	local ct=#Duel.GetEngagedCards()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Select(tp,ct,ct,nil)
	Duel.HintSelection(g)
	Duel.Destroy(g,REASON_EFFECT)
end
function s.imval(e,te)
	local c=te:GetOwner()
	local tp=te:GetOwnerPlayer()
	local chkp=tp==e:GetOwnerPlayer()
	if c:IsType(TYPE_DRIVE) then return not (c:IsSetCard"Kronologistic" and chkp) end
	if chkp then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not (g and g:IsContains(e:GetHandler()))
end
function s.zetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=#Duel.GetEngagedCards()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return ct>0 and ct<=#g end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,ct,0,0)
	Duel.SetChainLimit(s.chlim)
end
function s.zeop(e,tp)
	local g=Duel.GetEngagedCards()
	local ct=#g
	for tc in aux.Next(g) do tc:ChangeEnergy(0,tp,REASON_EFFECT,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local sg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Select(tp,ct,ct,nil)
	Duel.HintSelection(sg)
	if #sg<1 then return end
	Duel.BreakEffect()
	Duel.Destroy(sg,REASON_EFFECT)
end
